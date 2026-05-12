# Examples

Canonical format examples for each wiki page type.
Copy these as starting points; replace the placeholder content.

---

## Decision page

File: `decisions/auth-strategy.md`

    ---
    type: decision
    date: 2026-04-15
    status: active
    ---

    # Auth strategy

    Avoids: [pitfalls/auth](../pitfalls/auth.md)

    - 2026-04-15 — chose JWT (anticipated microservices split; stateless tokens fit that model)
    - 2026-05-11 [SUPERSEDES above] — reverted to sessions + Redis. Reason: microservices split
      was deprioritised; monolith for the foreseeable future. JWT added complexity (key rotation,
      revocation) without benefit. Cookies + Redis are simpler and fully sufficient.

---

## Preference page

File: `preferences/tools.md`

    ---
    type: preference
    ---

    # Tools preferences

    - 2026-05-11 — use pnpm as package manager (faster installs, consistent lockfiles)
    - 2026-05-20 [SUPERSEDES above] — switched to bun. Reason: bun's runtime speed matters
      for this project's test suite; pnpm lockfile had repeated sync issues across machines.

---

## Workflow page

File: `workflows/deploy.md`

    ---
    type: workflow
    ---

    # Deploy workflow

    1. Run `pnpm test` — confirm all passing.
    2. If schema changed: run `pnpm db:migrate` (check `git diff HEAD~1 -- migrations/`).
    3. Push to `main` — CI deploys to staging automatically.
    4. Verify staging at staging.example.com.
    5. Tag release: `git tag v<semver> && git push --tags`.
    6. CI promotes to production on tags automatically.

    Pitfall: step 2 is easy to skip when no migration file is obviously new. Always check.

---

## Pitfall page

File: `pitfalls/build.md`

    ---
    type: pitfall
    date: 2026-05-11
    status: open
    ---

    # Build failures

    ## Schema not migrated before build

    Addressed by: [decisions/deploy-checklist](../decisions/deploy-checklist.md)

    Symptom: build fails with "column X does not exist"
    Fix: `pnpm db:migrate` then retry build
    Root cause: type-check step queries the live schema; stale schema causes type errors.

    ## Port conflict on dev start

    Symptom: `EADDRINUSE :::3000`
    Fix: `lsof -ti:3000 | xargs kill` then restart
    Root cause: prior dev server not cleanly stopped.

---

## Log entries

File: `log.md` (append-only)

    ## [2026-05-11 10:30] init | wiki initialized

    Starting wiki. Populated starter pages. Active task: set up authentication flow.

    ## [2026-05-11 14:22] decision | reverted JWT to sessions

    See decisions/auth-strategy.md for full reasoning trace.

    ## [2026-05-11 17:45] pitfall | build fails when migrations not applied

    Added entry to pitfalls/build.md.

    ## [2026-05-11 18:00] session-end | lint clean, 0 issues

    No changes applied. Wiki state confirmed current.

---

## Active task page

File: `_active/now.md`

    ---
    type: active
    ---

    # Current work

    ## Active task

    Implementing the password reset flow. Email sending works; token validation endpoint
    in progress. Blocked on: deciding token expiry (1h vs 24h — see open-questions.md).

    ## Context for next session

    - File: `src/auth/reset.ts` — main implementation
    - File: `src/email/templates/reset.html` — email template, done
    - Decision needed: token expiry duration (open question)
    - Do not restart the work on JWT — that decision is settled (see decisions/auth-strategy.md)
