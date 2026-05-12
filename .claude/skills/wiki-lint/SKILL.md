---
name: wiki-lint
description: >-
  Run the wiki lint checklist. Checks for orphans, stale pages, contradictions,
  duplicates, empty templates, and stale active items. Proposes all changes —
  applies only on user approval. Use at session end or any time the wiki needs
  a health check.
---

# Wiki lint

Run the 6-step lint checklist from `wiki/HOWTO.md §Lint` in order.
Propose all changes to the user. Apply only on explicit approval.

## Steps

1. **Orphans** — list every `.md` file under `wiki/` not in `wiki/index.md`
   (exclude: README.md, HOWTO.md, EXAMPLES.md, any file named EXAMPLE.md).
   Propose: add to index, or delete.

2. **Stale pages** — pages whose content appears outdated relative to current
   project state (decisions reversed, tasks completed, architecture changed).
   Propose: update content or archive.

3. **Contradictions** — scan pages in the same category for opposing claims
   without a supersession block.
   Propose: merge using the supersession format from HOWTO.md.

4. **Duplicates** — find two pages covering the same concept.
   Propose: merge into one, redirect the other.

5. **Empty templates** — pages whose content is only frontmatter + comment
   blocks with no real content.
   Propose: fill in or delete.

6. **Stale active items** — items in `_active/` that appear resolved.
   Propose: remove or graduate to `decisions/` or `workflows/`.

## After lint

After proposing and applying approved changes:
- Rewrite `wiki/_snapshot.md` to reflect current state (if not already done
  this session).
- Append a `session-end` entry to `wiki/log.md`:
  ```
  ## [YYYY-MM-DD HH:MM] session-end | lint + snapshot updated
  ```
