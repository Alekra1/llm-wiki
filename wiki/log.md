# Session log

Append-only. Never edit or delete existing entries.

Format: `## [YYYY-MM-DD HH:MM] <type> | <description>`
Types: `init`, `preference`, `decision`, `workflow`, `pitfall`, `architecture`, `active`, `lint`, `session-end`

Grep recent: `grep "^## \[" wiki/log.md | tail -10`

---

## [YYYY-MM-DD HH:MM] init | wiki initialized

Wiki structure created from llm-wiki template. Ready for project-specific content to be added as the project develops. Next session: read HOWTO.md and index.md to bootstrap.
