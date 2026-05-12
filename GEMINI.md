# Agent instructions

This project uses an LLM wiki at `./wiki/` as its living context layer.

**On session start:** read `wiki/HOWTO.md`, `wiki/index.md`, `wiki/_active/now.md`,
and recent entries from `wiki/log.md`.

**While working:** update the wiki per `wiki/HOWTO.md`. Use supersession, not deletion,
for contradictions. Add a `log.md` entry for each wiki change.

**On session end:** run the lint checklist from `wiki/HOWTO.md §Lint`, propose prunes
to the user, apply on approval, and append a session summary to `wiki/log.md`.
