#!/usr/bin/env bash
# search.sh — search the wiki via FTS5.
#
# Usage:
#   wiki/scripts/search.sh "session compression"
#   wiki/scripts/search.sh -n 10 "drizzle orm"
#
# Auto-builds the index if missing. Returns top matches with snippet.

set -euo pipefail

LIMIT=5
while [ $# -gt 0 ]; do
  case "$1" in
    -n) LIMIT="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) break ;;
  esac
done

[ $# -ge 1 ] || { echo "usage: $0 [-n N] <query>" >&2; exit 2; }
QUERY="$*"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIKI="$(cd "$SCRIPT_DIR/.." && pwd)"
DB="$WIKI/.index/wiki.db"

if [ ! -e "$DB" ]; then
  echo "no index yet — building..." >&2
  bash "$SCRIPT_DIR/index.sh" >&2
fi

command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 1; }

DB="$DB" QUERY="$QUERY" LIMIT="$LIMIT" python3 - <<'PY'
import os, sqlite3, sys

conn = sqlite3.connect(os.environ["DB"])
query = os.environ["QUERY"]
limit = int(os.environ["LIMIT"])

# FTS5: split on whitespace, OR-combine, also try phrase match
terms = query.split()
fts_query = " OR ".join(terms) if terms else query

try:
    rows = conn.execute("""
      SELECT path, title,
             snippet(pages, 2, '«', '»', '…', 12) AS snip,
             bm25(pages) AS score
      FROM pages
      WHERE pages MATCH ?
      ORDER BY score
      LIMIT ?
    """, (fts_query, limit)).fetchall()
except sqlite3.OperationalError as e:
    print(f"query error: {e}", file=sys.stderr)
    sys.exit(1)

if not rows:
    print("no matches")
    sys.exit(0)

for path, title, snip, score in rows:
    print(f"\n{path}  ({title})")
    print(f"  {snip}")
PY
