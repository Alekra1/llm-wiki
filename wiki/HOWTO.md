---
purpose: agent-facing schema — read this before any other wiki file
version: 1.0
---

# Wiki HOWTO

This wiki is the project's living context layer — preferences, decisions, workflows,
pitfalls, and active state accumulated across sessions and providers.

You maintain it. The human reads it. Read this file first; follow its rules exactly.

---

## Session start

Read in this order on every new session:

1. `wiki/_snapshot.md` — compressed current-state summary; read this first for fast bootstrap
2. `wiki/_active/now.md` — current task, blockers, in-flight state
3. Last 10 entries of `wiki/log.md` — what happened recently

Use `wiki/index.md` as your map to find other pages as needed. Read `wiki/HOWTO.md` only
if you are unfamiliar with the wiki conventions.

---

## During the session: when to write

Write to the wiki for **rules** — facts expected to hold across future sessions.
Do NOT write **observations** (one-off events, current conversation state) unless they
recur or the user explicitly elevates them.

| Signal | Where to write |
|--------|----------------|
| User states a preference ("I prefer X") | `preferences/` |
| A technical or design decision is made | `decisions/<topic>.md` |
| A workflow repeats more than once | `workflows/<topic>.md` |
| Something breaks and the fix is understood | `pitfalls/<area>.md` |
| Architecture insight that took effort to derive | `architecture/` |
| Current task / in-flight state changes | `_active/now.md` |
| Any of the above | also append to `log.md`; update `index.md` if new page |

**preferences/ vs decisions/**: use `preferences/` for *how the agent should behave* (tone, verbosity, tool choices). Use `decisions/` for *what the project should do* (architecture, library choices, data model). When a toolchain choice affects both (e.g. "use pnpm"), write a `decisions/` entry as the primary source; only add a `preferences/` entry if it also changes agent behavior (e.g. always use pnpm in commands).

**Closely related stack choices**: when a user states multiple related tech choices in one conversation (e.g. React + Vite + pnpm + Express), you may group them in a single `decisions/stack.md` rather than creating four thin files. The anti-bloat rule against `stack.md` applies to catch-all files that grow without discipline — a focused initial stack declaration is fine.

---

## The supersession rule (most important)

When new knowledge **contradicts** existing knowledge, **never delete the old entry**.
Append a dated revision block below it.

The reasoning trace — why we changed our mind — is the most valuable part of this wiki.

**Format:**

```
- YYYY-MM-DD — [original claim] ([original reasoning])
- YYYY-MM-DD [SUPERSEDES above] — [new claim]. Reason: [why we changed].
```

Multiple supersessions stack chronologically. The most recent entry reflects current truth.
Reading all entries shows how the project's thinking evolved.

**Same-session supersession**: if the user changes their mind within the same session, write only the final decision. Do not write the initial choice and immediately supersede it — that produces noise. The log entry can note the change: "user revised during session from X to Y."

**Read-before-write rule**: always read the current on-disk version of a file immediately before writing it — even if you read it earlier in the session. Another agent may have written it since. If the file now contains content you did not see, apply supersession rather than overwriting.

---

## Page format

Every wiki page uses lightweight YAML frontmatter:

```yaml
---
type: preference | decision | workflow | pitfall | architecture | active | snapshot
supersedes: <optional: path to prior page if this replaces another entirely>
---
```

---

## Index discipline

`index.md` is the canonical catalog. Every page must appear there.

- When you **create** a page: add it to `index.md` immediately.
- When you **rename or delete** a page: update `index.md` immediately.

Format: `- [Page Title](relative/path.md) — one-line summary`

**Excluded from index tracking** (do not list, do not flag as orphans during lint):
- `wiki/README.md` — human-facing intro, not a content page
- `wiki/HOWTO.md` and `wiki/EXAMPLES.md` — schema files, listed separately under §Schema
- Any file named `EXAMPLE.md` — these are format templates, not content

---

## Log discipline

`log.md` is append-only. Never edit or delete existing entries.
Every wiki write gets a log entry.

**Write immediately, not at session end.** The moment a decision is made, a preference stated, a pitfall found, or a task changes — write the log entry then. Do not accumulate updates and batch them later. Batching leads to missed entries when context runs out or sessions end unexpectedly.

**Format:**

```
## [YYYY-MM-DD HH:MM] <type> | <short description>

Optional 1-2 sentence detail if the change was complex.
```

`HH:MM` is approximate — use your best estimate of the current time, or omit and use `00:00` if unknown.

Types: `init`, `preference`, `decision`, `workflow`, `pitfall`, `architecture`, `active`, `lint`, `session-end`

The prefix `## [YYYY-MM-DD` makes entries grep-able:
```
grep "^## \[" wiki/log.md | tail -10
```

---

## Snapshot discipline

`_snapshot.md` is the L1 fast-bootstrap. Rewrite it at the end of every session.

**What belongs in the snapshot** (keep it to one screen):
- What the project is (one sentence)
- Current phase and active task
- Immediate next steps (3–5 ordered items)
- Critical constraints a fresh agent must not forget (3–5 bullets)
- Key open questions (link to `_active/open-questions.md` for detail)

**Rules**:
- Rewrite from scratch each time — do not append. It reflects current truth only.
- No log-style history; that belongs in `log.md`.
- If nothing changed this session, leave content as-is — git tracks when the file last changed.

---

## Lint (session end / on request)

When asked to lint the wiki, run this checklist in order:

1. **Orphans** — pages not listed in `index.md`. Propose: add to index or delete.
2. **Stale pages** — pages whose content appears outdated relative to current project state. Propose: update or archive.
3. **Contradictions** — pages in the same category making opposing claims without supersession. Propose: merge with supersession block.
4. **Duplicates** — overlapping content across separate pages. Propose: merge into one.
5. **Empty templates** — placeholder pages never filled in. Propose: fill or delete.
6. **Stale active items** — items in `_active/` that appear resolved. Propose: remove or graduate to `decisions/` or `workflows/`.

**Propose all changes. Apply only on user approval.**
After lint: rewrite `_snapshot.md` to reflect current state, then append a `session-end` entry to `log.md`.

---

## Non-CC environments

If slash commands (`/wiki-lint`, `/wiki-update`, `/wiki-snapshot`) are unavailable (Cursor, Gemini, Copilot, raw API), use these manual equivalents:

- Instead of `/wiki-update`: "Update the wiki with this decision per wiki/HOWTO.md routing table."
- Instead of `/wiki-lint`: "Run the 6-step lint checklist from wiki/HOWTO.md §Lint and report findings."
- Instead of `/wiki-snapshot`: "Rewrite wiki/_snapshot.md to reflect current project state."

Session-start and session-end hooks will not fire. The agent must follow the startup read sequence and end-of-session writes manually, guided by CLAUDE.md or AGENTS.md.

---

## Multi-agent safety

The wiki is designed for **one agent with exclusive access**. Concurrent agents are unsafe because:
- `decisions/` files: last writer silently overwrites; supersession rule requires reading before writing
- `index.md`: stale-read/write-back race can silently delete other agents' entries
- `log.md`: append-only; the only file safe for concurrent writes

If multiple agents write to the wiki:
1. Apply the **read-before-write rule** strictly — read the file immediately before writing it.
2. Include an agent identifier in log entries: `[agent-A] decision | ...`
3. If you detect a conflict in a decisions/ file, apply supersession rather than overwriting.

---

## Anti-bloat principles

- Prefer editing existing pages over creating new ones.
- One page per concept — never two pages on the same topic.
- For `decisions/`: one file per discrete decision, named by noun (`decisions/orm.md`, `decisions/auth-strategy.md`). Do not create a catch-all `decisions/stack.md`.
- `_active/` is volatile: prune aggressively; nothing stays there more than a few sessions.
- When a blocker in `_active/now.md` resolves into a settled decision, remove it from the blockers list and create the corresponding `decisions/` page.
- When unsure whether to write: if it won't matter in a month, skip it.
- A page with many stacked supersessions is a candidate for a clean rewrite — propose it during lint.
