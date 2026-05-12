# llm-wiki

A markdown wiki template that gives LLM agents persistent, cross-session memory. Copy it into any project — agents read and write `wiki/` as a living brain that survives context resets and provider switches.

## Install

```bash
npx @alekra1/llm-wiki
```

This copies `wiki/` into your project, creates or appends to `CLAUDE.md`, and adds provider files (`AGENTS.md`, `GEMINI.md`, `.cursorrules`) if they don't exist.

Then install the Claude Code plugin for slash commands:
```
/plugin marketplace add Alekra1/llm-wiki
/plugin install wiki@llm-wiki
```

## What's included

| File/Dir | Purpose |
|---|---|
| `wiki/` | The wiki: snapshot, active tasks, decisions, preferences, pitfalls, workflows |
| `CLAUDE.md` | Agent instructions for Claude Code |
| `AGENTS.md` | Same for OpenAI Agents / Codex |
| `GEMINI.md` | Same for Gemini |
| `.cursorrules` | Same for Cursor |
| `.claude/` | CC plugin: SessionStart hook + `/wiki-lint`, `/wiki-update`, `/wiki-snapshot` |

## How it works

On session start, the agent reads `wiki/_snapshot.md` (~300 tokens, ~30 seconds) and picks up exactly where the last session ended. No summaries to maintain — the wiki is the memory.

Agents write to the wiki as they work: decisions in `wiki/decisions/`, preferences in `wiki/preferences/`, active tasks in `wiki/_active/`. Every change gets a line in `wiki/log.md`.

Read `wiki/HOWTO.md` for conventions.

## Slash commands (Claude Code plugin)

| Command | What it does |
|---|---|
| `/wiki-update` | Write a new wiki entry |
| `/wiki-lint` | Run the wiki health checklist |
| `/wiki-snapshot` | Refresh the snapshot mid-session |

## Provider support

Works with any LLM that can read files. Entry-point files (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`) contain identical instructions in each provider's expected format.
