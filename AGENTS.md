# Agent instructions

This project uses an LLM wiki at `./wiki/` as its living context layer.

**On session start:** read `wiki/_snapshot.md` first (fast bootstrap), then `wiki/HOWTO.md`,
`wiki/index.md`, `wiki/_active/now.md`, and recent entries from `wiki/log.md`.

**While working:** update the wiki per `wiki/HOWTO.md`. Use supersession, not deletion,
for contradictions. Add a `log.md` entry for each wiki change.

**On session end:** rewrite `wiki/_snapshot.md` to reflect current state, offer to run
the lint checklist (`/wiki-lint`), apply approved changes, and append a session summary
to `wiki/log.md`.

**Slash commands** (Claude Code): `/wiki-update` — write a wiki entry; `/wiki-lint` — run
the lint checklist; `/wiki-snapshot` — refresh the snapshot mid-session.
