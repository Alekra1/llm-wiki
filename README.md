# llm-wiki

A markdown wiki template that gives LLM agents persistent, cross-session memory. Copy it into any project — agents read and write `wiki/` as a living brain that survives context resets and provider switches.

## What's included

- **`wiki/`** — the wiki itself: snapshot, active tasks, decisions, preferences, pitfalls, workflows, architecture
- **`CLAUDE.md`** — agent instructions for Claude Code (points agents to the wiki)
- **`AGENTS.md`** — same for OpenAI Agents, Codex, etc.
- **`GEMINI.md`** — same for Gemini
- **`.cursorrules`** — same for Cursor
- **`.claude/`** — Claude Code plugin: SessionStart hook + `/wiki-lint`, `/wiki-update`, `/wiki-snapshot` slash commands. Pre-configured permissions so wiki edits don't require approval prompts.

## Setup

1. Copy this repo's contents into your project root (merge with existing files if needed):
   ```
   cp -r llm-wiki/. your-project/
   ```

2. Fill in `wiki/_snapshot.md` with your project's current state.

3. Start a Claude Code session — the SessionStart hook bootstraps context automatically.

## How it works

On session start, the agent reads `wiki/_snapshot.md` (~30 seconds, ~300 tokens) and picks up exactly where the last session ended. No summaries to maintain, no context to reconstruct — the wiki is the memory.

Agents write to the wiki as they work: decisions go in `wiki/decisions/`, preferences in `wiki/preferences/`, active tasks in `wiki/_active/`. Every change gets a line in `wiki/log.md`.

Read `wiki/HOWTO.md` for the full conventions.

## Slash commands (Claude Code)

| Command | What it does |
|---|---|
| `/wiki-update` | Write a new wiki entry |
| `/wiki-lint` | Run the wiki health checklist |
| `/wiki-snapshot` | Refresh the snapshot mid-session |

## Provider support

Works with any LLM that can read files. The entry-point files (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`) contain identical instructions in the format each provider expects.
