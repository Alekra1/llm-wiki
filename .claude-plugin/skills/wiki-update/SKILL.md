---
name: wiki-update
description: >-
  Write a structured update to the wiki. Determines the correct location,
  creates or edits the page, updates wiki/index.md if it's a new page, and
  appends a log entry. Use when a decision is made, preference stated, workflow
  established, pitfall found, or active state changes.
---

# Wiki update

Apply a structured update to the wiki. Follow the routing table below.

## Routing table

| Signal | Target |
|--------|--------|
| User states a preference | `wiki/preferences/<topic>.md` |
| Technical or design decision made | `wiki/decisions/<topic>.md` |
| Workflow repeats more than once | `wiki/workflows/<topic>.md` |
| Something broke and fix is understood | `wiki/pitfalls/<area>.md` |
| Architecture insight | `wiki/architecture/<topic>.md` |
| Current task / blockers changed | `wiki/_active/now.md` |
| Unresolved question | `wiki/_active/open-questions.md` |

## Rules

- **Prefer editing over creating**: if a page on this topic exists, edit it.
- **New page**: add it to `wiki/index.md` immediately.
- **Contradictions**: never delete old content — use the supersession block
  format from `wiki/HOWTO.md`.
- **Frontmatter**: every page needs `type:`.

## After writing

Append to `wiki/log.md`:
```
## [YYYY-MM-DD HH:MM] <type> | <short description>

Optional 1-2 sentence detail.
```

Types: `init`, `preference`, `decision`, `workflow`, `pitfall`, `architecture`, `active`, `lint`, `session-end`
