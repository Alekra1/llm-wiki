---
name: wiki-snapshot
description: >-
  Rewrite wiki/_snapshot.md to reflect current project state. One page, ~30
  seconds to read. Use any time the snapshot needs refreshing mid-session.
---

# Wiki snapshot

Rewrite `wiki/_snapshot.md` from scratch to reflect the current state.

## What to include (one screen only)

```markdown
---
type: snapshot
---

# Project snapshot

**What**: <one sentence: what is this project and what does it do?>

**Current phase**: <e.g. "Phase 2 in progress", "MVP complete">

**Active task**: <the single thing being worked on right now>

**Immediate next steps** (in order):
1. <step 1>
2. <step 2>
3. <step 3>

**Critical context**:
- <key constraint or decision a fresh agent must not forget>
- <another critical fact — 3–5 bullets max>

**Key open questions** (see _active/open-questions.md):
- <unresolved question shaping design>
```

## Rules

- **Rewrite, don't append** — this file reflects current truth only.
- **One screen** — if it's longer than ~30 lines, cut until it fits.
- **No history** — log-style history belongs in `wiki/log.md`.
- After rewriting, append a log entry:
  ```
  ## [YYYY-MM-DD HH:MM] session-end | snapshot updated
  ```
