#!/usr/bin/env bash
# compress-log.sh — archives old log.md entries into wiki/log/archive/YYYY-MM.md
#
# Entries are recognized by the heading pattern:  ## [YYYY-MM-DD HH:MM] ...
#
# Anything older than --days (default 30) is moved to wiki/log/archive/YYYY-MM.md
# and the active log.md gets a single summary line per archived month.
#
# Manual trigger — don't automate. You want to eyeball what gets archived.
#
# Usage:
#   wiki/scripts/compress-log.sh [--days N] [--threshold N] [--dry-run]
#
#   --days N        Archive entries older than N days. Default 30.
#   --threshold N   Skip archival if log.md has fewer than N lines. Default 500.
#   --dry-run       Print what would happen, change nothing.

set -euo pipefail

DAYS=30
THRESHOLD=500
DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --days) DAYS="$2"; shift 2 ;;
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Locate wiki root (script lives in wiki/scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIKI="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG="$WIKI/log.md"
ARCHIVE_DIR="$WIKI/log/archive"

[ -r "$LOG" ] || { echo "no log.md at $LOG" >&2; exit 1; }

# Rough token estimate: English markdown ≈ 3 bytes per token
fmt_size() {
  local bytes="$1" tok=$(( $1 / 3 ))
  if [ "$bytes" -ge 1024 ]; then
    printf '%dKB / ~%d tokens' "$(( bytes / 1024 ))" "$tok"
  else
    printf '%dB / ~%d tokens' "$bytes" "$tok"
  fi
}

LINES=$(wc -l < "$LOG")
BYTES=$(wc -c < "$LOG")
echo "log.md: $LINES lines, $(fmt_size "$BYTES")"
echo "threshold: $THRESHOLD lines"
if [ "$LINES" -lt "$THRESHOLD" ]; then
  PCT=$(( LINES * 100 / THRESHOLD ))
  echo "Status: OK — $PCT% of line threshold. No action needed."
  echo "Action: recompress when log.md exceeds $THRESHOLD lines."
  exit 0
fi
echo "Status: above threshold — proceeding with archive plan."

CUTOFF="$(date -d "$DAYS days ago" '+%Y-%m-%d' 2>/dev/null || date -v-"${DAYS}"d '+%Y-%m-%d')"
echo "cutoff date: $CUTOFF  (archive entries dated < $CUTOFF)"

mkdir -p "$ARCHIVE_DIR"

# Pass over log.md, partitioning by:
#   - inside an entry that is OLDER than cutoff → goes to archive bucket for that YYYY-MM
#   - inside an entry NEWER than cutoff (or header before first entry) → stays
#
# Entry header pattern: ## [YYYY-MM-DD HH:MM]
TMP_KEEP="$(mktemp)"
TMP_ARCHIVE_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_KEEP" "$TMP_ARCHIVE_DIR"' EXIT

awk -v cutoff="$CUTOFF" -v keep="$TMP_KEEP" -v archdir="$TMP_ARCHIVE_DIR" '
  BEGIN { bucket = keep; mode = "keep" }
  /^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
    # Parse YYYY-MM-DD
    match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
    date = substr($0, RSTART, RLENGTH)
    ym = substr(date, 1, 7)
    if (date < cutoff) {
      mode = "archive"
      bucket = archdir "/" ym ".md"
    } else {
      mode = "keep"
      bucket = keep
    }
  }
  { print >> bucket }
' "$LOG"

# Counts
ARCHIVED_FILES=$(find "$TMP_ARCHIVE_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l)
if [ "$ARCHIVED_FILES" -eq 0 ]; then
  echo "nothing to archive (no entries older than $DAYS days)"
  exit 0
fi

# Report
echo
echo "Plan:"
for f in "$TMP_ARCHIVE_DIR"/*.md; do
  [ -e "$f" ] || continue
  ym=$(basename "$f" .md)
  count=$(grep -c '^## \[' "$f" || echo 0)
  echo "  $ym: $count entries → $ARCHIVE_DIR/$ym.md"
done
echo
NEW_LINES=$(wc -l < "$TMP_KEEP")
NEW_BYTES=$(wc -c < "$TMP_KEEP")
echo "log.md after archive: $LINES → $NEW_LINES lines, $(fmt_size "$BYTES") → $(fmt_size "$NEW_BYTES")"

if [ "$DRY" -eq 1 ]; then
  echo
  echo "[dry-run] no files changed"
  exit 0
fi

# Apply: append/merge each YM file to archive dir, then rewrite log.md
for f in "$TMP_ARCHIVE_DIR"/*.md; do
  [ -e "$f" ] || continue
  ym=$(basename "$f" .md)
  dest="$ARCHIVE_DIR/$ym.md"
  if [ ! -e "$dest" ]; then
    printf '# Log archive — %s\n\n' "$ym" > "$dest"
  fi
  cat "$f" >> "$dest"
done

# Rebuild log.md: prologue from TMP_KEEP + reference lines to archives + remainder
{
  # If TMP_KEEP starts with a header line, no prologue change needed.
  # Insert archive references before the first remaining entry.
  prologue_end=$(awk '/^## \[/ { print NR; exit }' "$TMP_KEEP")
  if [ -z "$prologue_end" ]; then
    cat "$TMP_KEEP"
    echo
  else
    head -n "$((prologue_end - 1))" "$TMP_KEEP"
  fi

  for f in "$TMP_ARCHIVE_DIR"/*.md; do
    [ -e "$f" ] || continue
    ym=$(basename "$f" .md)
    count=$(grep -c '^## \[' "$f" || echo 0)
    echo
    echo "## [$ym] $count entries archived → log/archive/$ym.md"
  done

  if [ -n "${prologue_end:-}" ]; then
    echo
    tail -n +"$prologue_end" "$TMP_KEEP"
  fi
} > "$LOG.tmp"

mv "$LOG.tmp" "$LOG"
echo
echo "done. log.md is now $(wc -l < "$LOG") lines."
echo "archived files: $ARCHIVE_DIR"
