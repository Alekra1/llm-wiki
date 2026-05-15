#!/usr/bin/env bash
# index.sh — builds a SQLite FTS5 index of all wiki pages.
#
# Markdown stays the source of truth. The index is regenerable and gitignored
# (wiki/.index/ is in .gitignore). Delete it any time; re-run to rebuild.
#
# Usage:  wiki/scripts/index.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIKI="$(cd "$SCRIPT_DIR/.." && pwd)"

command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 1; }

WIKI="$WIKI" python3 - <<'PY'
import os, sqlite3, sys
from pathlib import Path

wiki = Path(os.environ["WIKI"])
index_dir = wiki / ".index"
index_dir.mkdir(exist_ok=True)
db_path = index_dir / "wiki.db"
if db_path.exists():
    db_path.unlink()

conn = sqlite3.connect(db_path)
conn.execute("""
  CREATE VIRTUAL TABLE pages USING fts5(
    path UNINDEXED,
    title,
    body,
    tokenize = 'porter unicode61'
  )
""")

count = 0
skip_rel_prefixes = (".index/",)
skip_exact = {"_active/pending-log.md"}

for f in wiki.rglob("*.md"):
    rel = str(f.relative_to(wiki))
    if any(rel.startswith(p) for p in skip_rel_prefixes):
        continue
    if rel in skip_exact:
        continue
    try:
        body = f.read_text(errors="replace")
    except Exception as e:
        print(f"skip {rel}: {e}", file=sys.stderr)
        continue
    # Skip YAML frontmatter, then take first markdown heading
    title = ""
    lines = body.splitlines()
    i = 0
    if lines and lines[0].strip() == "---":
        i = 1
        while i < len(lines) and lines[i].strip() != "---":
            i += 1
        i += 1  # past closing ---
    while i < len(lines):
        s = lines[i].strip()
        if s.startswith("#"):
            title = s.lstrip("# ").strip()
            break
        i += 1
    title = title or rel
    conn.execute(
        "INSERT INTO pages(path, title, body) VALUES (?, ?, ?)",
        (rel, title, body),
    )
    count += 1

conn.commit()
conn.close()
print(f"indexed {count} pages → {db_path}")
PY
