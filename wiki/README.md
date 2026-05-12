# Project Wiki

This directory is the project's living knowledge base — its brain alongside the code body.

It is maintained entirely by the LLM agent. **You do not need to edit it yourself.**
Read it freely; let the agent write it.

---

## What's in here

| Path | Purpose |
|------|---------|
| `HOWTO.md` | Agent schema — how the wiki is read, written, and linted |
| `EXAMPLES.md` | Canonical format examples for each page type |
| `index.md` | Catalog of all pages (agent-maintained) |
| `log.md` | Chronological session log — append-only |
| `preferences/` | Your preferences for communication, tools, and code style |
| `workflows/` | How recurring tasks are done in this project |
| `decisions/` | Technical and design decisions with full reasoning traces |
| `pitfalls/` | Known failure modes and their fixes |
| `architecture/` | Structural knowledge that takes effort to re-derive |
| `_active/` | Current task and open questions — volatile, pruned often |

---

## How to adopt this in another project

1. Copy this entire `wiki/` directory into your project's root.
2. Copy the provider entry files from the repo root (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `GEMINI.md`) to your project's root.
3. Clear the placeholder example content, keeping directory structure and frontmatter templates.
4. Start a new session. The agent will read the entry file automatically and bootstrap from the wiki.

---

## What NOT to do

- Don't manually edit `log.md` — it is append-only and the agent owns it.
- Don't delete pages to "fix" outdated information — tell the agent; it uses supersession.
- Don't store raw source documents here — the wiki holds synthesized knowledge only.
- Don't write pages yourself — tell the agent what was decided and let it write the page.
