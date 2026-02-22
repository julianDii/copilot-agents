# Agent & Instruction Evaluations

**EVALS VERSION: 1.0.0** — bump when adding fixtures, changing rubric, or updating snapshots after an intentional improvement.

This directory contains fixtures and test cases for evaluating agent quality and instruction compliance.

---

## How to run an eval

1. Open Copilot Chat and select the agent from the dropdown.
2. Attach the fixture file with `#` or the paperclip (📎).
3. Use the prompt listed in the test case.
4. Score the output against the rubric below.
5. If output is good, save it as a snapshot: `evals/snapshots/<fixture-name>.md`.
6. After any instruction or agent change, re-run the affected fixtures and `git diff` the snapshots.

---

## Rubric (score each criterion 0 or 1)

Apply to every agent run:

| # | Criterion | Pass condition |
|---|-----------|---------------|
| 1 | **Format adherence** | Output matches the strict format: Summary → Blockers → Majors → Minors → Patches → Tests → Questions |
| 2 | **Severity accuracy** | Blockers are genuine blockers; not everything is Major; nits are not inflated |
| 3 | **Precision** | Every finding cites the exact line, function, or pattern from the fixture — no vague claims |
| 4 | **No hallucination** | Agent does not invent functions, files, or issues not present in the fixture |
| 5 | **Completeness** | All expected findings from the test case table below are caught |
| 6 | **Constraint compliance** | Agent does not violate a "Never Do" rule (no invented code, no style inflation, ≤3 questions) |
| 7 | **Patch quality** | Suggested patches are minimal and correct — not broad refactors |
| 8 | **Test proposals** | Proposed tests are concrete (input → expected behaviour), not generic |

Score: **7–8 = passing** | **5–6 = needs attention** | **&lt;5 = regression**

---

### `code-review` agent

| Fixture | Prompt | Expected findings | Expected severity | Must NOT find | Snapshot | Last score |
|---------|--------|------------------|-------------------|---------------|----------|------------|
| `fixtures/general/bare_except.py` | Review this file. | Bare `except: pass` silently swallows errors | Blocker or Major | Style comments | `snapshots/general-bare-except.md` | 8/8 ✅ |
| `fixtures/general/eval_usage.py` | Review this file. | `eval()` used without sanitization | Blocker | | `snapshots/general-eval-usage.md` | 8/8 ✅ |
| `fixtures/general/no_issues.py` | Review this file. | No blockers or majors | — | Fabricated issues | `snapshots/general-no-issues.md` | 8/8 ✅ |
| `fixtures/general/missing_timeout.py` | Review this file. | HTTP request with no timeout | Major | | `snapshots/general-missing-timeout.md` | 7/8 ✅ |

### `django-review` agent

| Fixture | Prompt | Expected findings | Expected severity | Must NOT find | Snapshot | Last score |
|---------|--------|------------------|-------------------|---------------|----------|------------|
| `fixtures/django/n_plus_one.py` | Review this file. | N+1 query — `select_related` missing | Major | | `snapshots/django-n-plus-one.md` | 8/8 ✅ |
| `fixtures/django/idor_view.py` | Review this file. | IDOR — object fetched without ownership check | Blocker | | `snapshots/django-idor-view.md` | 8/8 ✅ |
| `fixtures/django/migration_not_null.py` | Review this file. | `NOT NULL` column added without `default` — will lock table | Blocker | | `snapshots/django-migration-not-null.md` | 8/8 ✅ |
| `fixtures/django/signal_business_logic.py` | Review this file. | Business logic in `post_save` signal | Major | | `snapshots/django-signal-business-logic.md` | 8/8 ✅ |
| `fixtures/django/debug_settings.py` | Review this file. | `DEBUG=True` in non-local settings | Blocker | | `snapshots/django-debug-settings.md` | 8/8 ✅ |
| `fixtures/django/csrf_exempt.py` | Review this file. | `@csrf_exempt` without justification on session-auth endpoint | Major | | `snapshots/django-csrf-exempt.md` | 8/8 ✅ |

### `react-ts-review` agent

| Fixture | Prompt | Expected findings | Expected severity | Must NOT find | Snapshot | Last score |
|---------|--------|------------------|-------------------|---------------|----------|------------|
| `fixtures/react/stale_closure.tsx` | Review this file. | Stale closure / derived state in `useEffect` | Major | | `snapshots/react-stale-closure.md` | 8/8 ✅ |
| `fixtures/react/xss_risk.tsx` | Review this file. | `dangerouslySetInnerHTML` with unsanitized user input | Blocker | | `snapshots/react-xss-risk.md` | 8/8 ✅ |
| `fixtures/react/missing_abort.tsx` | Review this file. | Async request not cancelled on unmount — race condition | Major | | `snapshots/react-missing-abort.md` | 8/8 ✅ |
| `fixtures/react/unstable_key.tsx` | Review this file. | List rendered with array index as key | Minor | | `snapshots/react-unstable-key.md` | 8/8 ✅ |
| `fixtures/react/unsafe_assertion.tsx` | Review this file. | Unsafe `as` type assertion on API response | Major | | `snapshots/react-unsafe-assertion.md` | 8/8 ✅ |
| `fixtures/react/no_issues.tsx` | Review this file. | No blockers or majors — component is correct | — | Fabricated issues | `snapshots/react-no-issues.md` | 8/8 ✅ |

### Global instructions compliance

These test the 9-section `global-copilot-instructions.md` without any agent attached.

| Test | Prompt | Expected behaviour | Pass condition | Snapshot | Last score |
|------|--------|-------------------|----------------|----------|------------|
| §1 Response format | "Explain how React Context works." | Code-first, no preamble, no summary at the end | No "Sure, here is…" opener | `snapshots/global-s1-response-format.md` | ✅ |
| §2 New dependency | "Add rate limiting to this Express route." | Lists the package + justifies why stdlib doesn't cover it | Does not silently `npm install` | `snapshots/global-s2-new-dependency.md` | ✅ |
| §2 New file | "Add a utility function for date formatting." | Asks for confirmation OR adds to existing file | Does not create a new file silently | `snapshots/global-s2-new-file.md` | ✅ |
| §4 Requirements | "I want to build a notification system." | Produces Assumptions list + milestones + risks | Contains "Assumptions" section | `snapshots/global-s4-requirements.md` | ✅ |
| §9 Commit message | "Write a commit message for adding login throttling." | Uses Conventional Commits format | Starts with `feat:` / `fix:` / etc. | `snapshots/global-s9-commit-message.md` | ✅ |

---

## Snapshot process

After a passing run, save the output:

```bash
# Create a snapshot of a passing run (paste output into the file)
mkdir -p evals/snapshots
# e.g. evals/snapshots/django-idor-view.md

# After changing an agent or instruction, re-run and diff:
git diff evals/snapshots/
```

Any diff in a snapshot after a change needs a conscious decision:

- **Intentional improvement** → update the snapshot and bump `VERSION`
- **Regression** → revert the instruction/agent change

