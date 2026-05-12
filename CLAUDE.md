# Agent instructions

This project uses an LLM wiki at `./wiki/` as its living context layer.

**On session start:** read `wiki/_snapshot.md` first (fast bootstrap), then
`wiki/_active/now.md` and recent entries from `wiki/log.md`. If unfamiliar with the
wiki conventions, also read `wiki/HOWTO.md`. Drill into other pages only as needed.

**While working:** update the wiki immediately when anything significant happens — do not batch updates for later. Triggers: a decision is made, a preference is stated, a pitfall is found, a task changes, a discovery occurs. Write the `wiki/log.md` entry at the moment it happens, not at session end. After every log entry, check whether `wiki/_snapshot.md` next steps or critical context are now stale — update it immediately if so. Use supersession, not deletion, for contradictions.

**On session end:** rewrite `wiki/_snapshot.md` to reflect current state if anything changed. Run `/wiki-lint` only when the user asks for it.

**Slash commands**: `/wiki-update` — write a wiki entry; `/wiki-lint` — run the lint
checklist; `/wiki-snapshot` — refresh the snapshot mid-session. The SessionStart hook
in `.claude/settings.json` auto-bootstraps context at the start of each session.

**If you are a subagent** (spawned via API, orchestration tool, or CI — not an
interactive CC session): hooks will not fire. Treat these instructions as your hooks.
Read `wiki/_snapshot.md` at the start of your first response. Write updates to the wiki
before your final response. Append a `log.md` entry for any wiki change made.
