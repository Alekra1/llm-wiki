#!/usr/bin/env bash
# session-end-capture.sh — drafts a wiki log candidate from the session transcript.
#
# Wired as a SessionEnd hook in .claude/settings.json. Reads CC's hook JSON from
# stdin, extracts last user messages + recent tool calls from the transcript,
# appends a candidate entry to wiki/_active/pending-log.md.
#
# The candidate is reviewed and promoted to log.md by the agent on the next
# session, not written to log.md directly — that preserves the wiki's principle
# that every log entry is intentional.
#
# Anti-loop: emits the JSON response Claude Code expects so it never triggers
# another model turn. SessionEnd fires once per session (unlike Stop, which
# fires after every model response and loops — see wiki/pitfalls/stop-hook.md).

set -euo pipefail

# Read hook payload from stdin
PAYLOAD="$(cat || true)"

# Emit the no-loop response on every exit path
trap 'printf "%s\n" "{\"continue\":true,\"suppressOutput\":true}"' EXIT

# Require jq for transcript parsing; degrade gracefully if missing
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

CWD="$(printf '%s' "$PAYLOAD" | jq -r '.cwd // empty')"
SESSION_ID="$(printf '%s' "$PAYLOAD" | jq -r '.session_id // empty')"
TRANSCRIPT="$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // empty')"
REASON="$(printf '%s' "$PAYLOAD" | jq -r '.reason // "end"')"

# Only operate inside the working directory and only if the wiki exists there
[ -n "$CWD" ] || exit 0
[ -d "$CWD/wiki" ] || exit 0
[ -n "$TRANSCRIPT" ] || exit 0
[ -r "$TRANSCRIPT" ] || exit 0

PENDING="$CWD/wiki/_active/pending-log.md"
mkdir -p "$(dirname "$PENDING")"
touch "$PENDING"

# Idempotency: skip if this session already has a draft
if [ -n "$SESSION_ID" ] && grep -qF "session_id: $SESSION_ID" "$PENDING" 2>/dev/null; then
  exit 0
fi

NOW="$(date '+%Y-%m-%d %H:%M')"
DATE_ONLY="$(date '+%Y-%m-%d')"

# Extract last 5 user prompts (truncated) — these are the most likely seeds for
# decisions / pitfalls / preferences. Single-line, 200 chars max.
USER_MSGS="$(
  jq -r 'select(.type=="user") | .message.content
         | if type=="string" then .
           elif type=="array" then map(select(.type=="text") | .text) | join(" ")
           else "" end' "$TRANSCRIPT" 2>/dev/null \
  | grep -v '^$' \
  | tail -5 \
  | sed 's/[[:space:]]\+/ /g' \
  | cut -c1-200 \
  | sed 's/^/- /' || true
)"

# Extract files touched via Write/Edit tool calls (deduped, last 20)
FILES_TOUCHED="$(
  jq -r 'select(.type=="assistant") | .message.content // []
         | if type=="array" then
             map(select(.type=="tool_use" and (.name=="Write" or .name=="Edit" or .name=="NotebookEdit"))
                 | .input.file_path // .input.notebook_path // empty)
             | .[]
           else empty end' "$TRANSCRIPT" 2>/dev/null \
  | awk '!seen[$0]++' \
  | tail -20 \
  | sed 's/^/- /' || true
)"

# Append draft. Format mirrors wiki/log.md entries so promotion is a copy-paste.
{
  echo ""
  echo "## [$NOW] CANDIDATE | session-end draft (reason: $REASON)"
  echo "<!-- session_id: $SESSION_ID -->"
  echo ""
  echo "**Auto-captured.** Review and either promote to \`log.md\` with proper category"
  echo "(decision / pitfall / preference / workflow / active / session-end), or delete."
  echo ""
  if [ -n "$USER_MSGS" ]; then
    echo "**Recent user prompts:**"
    echo ""
    echo "$USER_MSGS"
    echo ""
  fi
  if [ -n "$FILES_TOUCHED" ]; then
    echo "**Files modified:**"
    echo ""
    echo "$FILES_TOUCHED"
    echo ""
  fi
} >> "$PENDING"

exit 0
