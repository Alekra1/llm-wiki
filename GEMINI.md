# Agent instructions

This project uses an LLM wiki at `./wiki/` as its living context layer.

**On session start:** read `wiki/_snapshot.md` first (fast bootstrap), then
`wiki/_active/now.md` and recent entries from `wiki/log.md`. If unfamiliar with the
wiki conventions, also read `wiki/HOWTO.md`. Use `wiki/index.md` as your map to find
other pages.

**While working:** update the wiki immediately when anything significant happens — do not
batch updates for later. Triggers: a decision is made, a preference is stated, a pitfall
is found, a task changes. Write the `wiki/log.md` entry at the moment it happens, not at
session end. Use supersession, not deletion, for contradictions.

**On session end:** rewrite `wiki/_snapshot.md` to reflect current state if anything
changed this session. Run the lint checklist only when the user asks for it.
