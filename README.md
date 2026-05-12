# llm-wiki

Gives LLM agents persistent, cross-session memory — a markdown wiki that agents read and write as a living brain. Survives context resets and provider switches. Zero tooling required.

## Install

**Step 1 — scaffold the wiki into your project:**

```bash
npx @alekra1/llm-wiki
```

This copies `wiki/` into your project, creates or appends to `CLAUDE.md`, and adds provider files (`AGENTS.md`, `GEMINI.md`, `.cursorrules`) if they don't already exist. Safe to run on existing projects — never overwrites.

**Step 2 — install the Claude Code plugin** (slash commands + session hooks):

```
/plugin marketplace add Alekra1/llm-wiki
/plugin install wiki@llm-wiki
```

**Step 3 — fill in the snapshot:**

Open `wiki/_snapshot.md` and replace the placeholders with your project's current state. This is what the agent reads first every session.

That's it. Start a Claude Code session.

---

## How it works

On session start, the SessionStart hook fires automatically and the agent reads `wiki/_snapshot.md` — one page, ~300 tokens, ~30 seconds. It picks up exactly where the last session ended.

As you work, the agent writes to the wiki: decisions in `wiki/decisions/`, preferences in `wiki/preferences/`, current task in `wiki/_active/`. Every change gets a line in `wiki/log.md`.

At session end, a Stop hook checks whether `wiki/log.md` was updated. If not, it prints a reminder in the terminal. The next SessionStart automatically catches any gaps from the previous session.

---

## Wiki structure

```
wiki/
├── _snapshot.md          ← read first every session (~300 tokens)
├── _active/
│   ├── now.md            ← current task and blockers
│   └── open-questions.md ← unresolved questions
├── decisions/            ← technical and design decisions
├── preferences/          ← user preferences (style, tools, communication)
├── workflows/            ← repeatable processes
├── pitfalls/             ← known traps and how to avoid them
├── architecture/         ← system overviews
├── index.md              ← catalog of all pages
├── log.md                ← append-only session log
├── HOWTO.md              ← full wiki conventions
└── EXAMPLES.md           ← format examples for each page type
```

---

## Slash commands (Claude Code)

Installed by the CC plugin.

| Command | What it does |
|---|---|
| `/wiki-update` | Write a structured wiki entry (routes to correct location automatically) |
| `/wiki-snapshot` | Rewrite `_snapshot.md` to reflect current state |
| `/wiki-lint` | Run the wiki health checklist — orphans, stale pages, contradictions, duplicates |

---

## Provider support

`npx @alekra1/llm-wiki` installs entry-point files for every major provider:

| File | Provider |
|---|---|
| `CLAUDE.md` | Claude Code |
| `AGENTS.md` | OpenAI Agents, Codex |
| `GEMINI.md` | Gemini |
| `.cursorrules` | Cursor |

Each file contains identical wiki instructions in the format that provider expects. The CC plugin (slash commands + hooks) is Claude Code only — other providers use the wiki via file reads without the plugin.

---

## Existing projects

`npx @alekra1/llm-wiki` is conflict-safe:

- `wiki/` — skipped if it already exists
- `CLAUDE.md` — wiki block appended if not already present, never overwritten
- `AGENTS.md`, `GEMINI.md`, `.cursorrules` — created only if absent

The CC plugin installs alongside your existing `.claude/settings.json` without touching it.

---

## Conventions

Read `wiki/HOWTO.md` for the full conventions: page format, supersession rules, log format, index discipline, snapshot discipline, and lint checklist.
