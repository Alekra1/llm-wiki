# Agent instructions

This project uses an LLM wiki at `./wiki/` as its living context layer.

**On session start:** read `wiki/_snapshot.md` first (fast bootstrap), then
`wiki/_active/now.md` and recent entries from `wiki/log.md`. If unfamiliar with the
wiki conventions, also read `wiki/HOWTO.md`. Drill into other pages only as needed.

**While working:** update the wiki per `wiki/HOWTO.md`. Use supersession, not deletion,
for contradictions. Add a `log.md` entry for each wiki change.

**On session end:** rewrite `wiki/_snapshot.md` to reflect current state if anything changed this session. Run `/wiki-lint` only when the user asks for it.

**Slash commands**: `/wiki-update` — write a wiki entry; `/wiki-lint` — run the lint
checklist; `/wiki-snapshot` — refresh the snapshot mid-session. Hooks in
`.claude/settings.json` automate the session-start reads and session-end prompt.

**If you are a subagent** (spawned via API, orchestration tool, or CI — not an
interactive CC session): hooks will not fire. Treat these instructions as your hooks.
Read `wiki/_snapshot.md` at the start of your first response. Write updates to the wiki
before your final response. Append a `log.md` entry for any wiki change made.
