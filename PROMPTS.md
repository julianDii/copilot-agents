# Prompt Guide

Practical prompts for getting the most out of the agents and global instructions in this repo.

## How to attach an agent

Agents live in `.github/agents/` and are available in the Copilot Chat dropdown in both IDEs automatically.

**JetBrains** — select the agent from the chat mode/agent dropdown at the start of a conversation.

**VS Code** — type `@` in Copilot Chat and select the agent from the dropdown.

---

## Context patterns

Agents have `tools: [codebase]` and can search the workspace autonomously. Attaching the primary file explicitly still gives faster, more focused results — the agent then uses the codebase tool to chase related files (models, serializers, types) on its own.

### Single file review

```text
[attach file with # or 📎]
Review this file. Focus on auth and input validation.
```

### Selected function

```text
[select code in editor]
Review this function only. What are the failure modes?
```

### Pull request diff

```text
[paste output of: git diff main...HEAD]
Review this diff. Flag blockers and majors only.
```

### Error or failing test

```text
[paste stack trace]
[attach the relevant file]
This test is failing. Give me a ranked hypothesis list.
```

### Multi-file review

```text
[attach file A with #]
[attach file B with #]
Review the interaction between these two files.
Focus on the transaction boundary.
```

---

## General Code Review — `code-review.agent.md`

Use when you want a language-agnostic review focused on correctness, security, and reliability.

### Review the current file

```text
Review this file. Focus on correctness, security, and any missing error handling.
```

### Review a specific function

```text
Review the `processPayment` function only. What are the failure modes and what tests are missing?
```

### Review a diff / PR

```text
Here is my PR diff: [paste diff]
Review for blockers and majors only. Skip style and nits.
```

### Security-focused pass

```text
Do a security-only review of this file. Look for injection, auth issues, secrets in logs, and unsafe dependencies.
```

### Propose missing tests

```text
Based on this code, what tests are missing? Give me concrete test cases covering happy path, edge cases, and failure modes.
```

### Prototype vs production

```text
This is a prototype, not production code. Do a light review — flag only correctness and security blockers.
```

---

## Django Review — `django-review.agent.md`

Use for Django / Django REST Framework code: models, views, serializers, querysets, migrations.

### Review a DRF view or viewset

```text
Review this DRF ViewSet. Check authorization, queryset scoping, serializer validation, and N+1 queries.
```

### Check for IDOR vulnerabilities

```text
Review this view for IDOR. Can a user access or modify another user's data by guessing an ID?
```

### ORM performance review

```text
Review the ORM queries in this file. Identify N+1 problems and suggest select_related/prefetch_related fixes.
```

### Serializer review

```text
Review this serializer. Check for missing validation, exposed sensitive fields, and cross-field constraints.
```

### Transaction safety

```text
Review this multi-step write operation. Is it wrapped correctly in a transaction? Are there race conditions?
Are any external side effects (emails, webhooks) happening inside the transaction that should use on_commit?
```

### Migration review

```text
Review this Django migration. Is it safe to run on a live database with zero downtime?
Flag any locking risks, missing indexes, or data integrity issues.
```

### Full Django PR review

```text
Review this Django PR. Cover: authorization, ORM performance, input validation, transaction safety, and security.
Produce the standard output: summary → blockers → majors → minors → patches → tests → questions.
```

---

## React + TypeScript Review — `react-ts-review.agent.md`

Use for React components, custom hooks, and TypeScript-heavy frontend code.

### Review a component

```text
Review this React component. Focus on state correctness, effect dependencies, and missing loading/error states.
```

### Check hooks for stale closures

```text
Review the useEffect hooks in this file. Are the dependency arrays correct? Any stale closure risks?
```

### Async and race condition review

```text
Review the async logic in this component. Can requests come back out of order?
Is there double-submit protection? Are requests cancelled on unmount?
```

### Type safety review

```text
Review the TypeScript types in this file. Flag any `any`, unsafe assertions, and unhandled union cases.
For API response types, should we be validating with zod or similar?
```

### Performance review

```text
Review this component for unnecessary re-renders. What should be memoized with useMemo or useCallback?
Are there unstable props being passed to child components?
```

### Security review

```text
Review this component for XSS risks. Is any untrusted data rendered as HTML?
Are user-supplied URLs being used unsafely in src/href?
```

### Full frontend PR review

```text
Review this React/TypeScript PR. Cover: state correctness, type safety, async races, security, performance, and accessibility basics.
Produce the standard output: summary → blockers → majors → minors → patches → tests → questions.
```

---

## Global Instructions — Prompts That Activate Specific Sections

These work in any context without attaching an agent file — the global instructions are always active.

### Requirements & Design (section 4)

```text
I want to build [feature]. What are your assumptions and open questions?
Then give me a plan with milestones, risks, and acceptance criteria.
```

### Implementation (section 5)

```text
Implement [feature]. Follow existing patterns in the codebase.
Include input validation, error handling, and explicit types.
```

### Testing (section 6)

```text
What tests should I write for this change?
Cover happy path, boundary cases, and failure cases.
If there's auth involved, include negative authorization tests.
```

### Debugging (section 8)

```text
This is failing: [describe symptom or paste error].
Give me a ranked hypothesis list with what evidence to check and the fastest way to verify each.
```

### PR description (section 9)

```text
Write a PR description for this change.
Include: intent, key changes, user impact, risks, how to test, and rollback plan.
```

---

## Power Combos

Multi-agent and multi-step workflows.

### Full-stack PR review

```text
[attach django-review agent]
Review the backend changes in this PR.
```

Then in a follow-up:

```text
[attach react-ts-review agent]
Review the frontend changes in the same PR.
```

### Design → implement → test in one thread

```text
I want to add rate limiting to the login endpoint.
First give me assumptions and a design plan (section 4).
Once we agree, implement it (section 5).
Then tell me what tests to write (section 6).
```

### Incident triage → fix → PR

```text
Users are reporting [symptom]. Give me a hypothesis list ranked by likelihood.
[after identifying cause]
Implement the fix with the minimal safe change.
[after fix]
Write the PR description including the incident summary and rollback plan.
```

---

## References

Links that informed the agents — useful when going deeper on a finding.

### General Engineering

| Topic | URL |
|-------|-----|
| Google Engineering Practices | <https://google.github.io/eng-practices/> |
| Google Code Review Guidelines | <https://google.github.io/eng-practices/review/reviewer/looking-for.html> |
| Practical Test Pyramid | <https://martinfowler.com/articles/practical-test-pyramid.html> |
| Site Reliability Engineering | <https://sre.google/sre-book/table-of-contents/> |
| OWASP Top 10 | <https://owasp.org/www-project-top-ten/> |
| OWASP Cheat Sheet Series | <https://cheatsheetseries.owasp.org/> |
| OpenTelemetry Concepts | <https://opentelemetry.io/docs/concepts/observability-primer/> |

### Django / DRF

| Topic | URL |
|-------|-----|
| DRF Permissions | <https://www.django-rest-framework.org/api-guide/permissions/> |
| DRF Serializers | <https://www.django-rest-framework.org/api-guide/serializers/> |
| DRF Testing | <https://www.django-rest-framework.org/api-guide/testing/> |
| Django ORM Optimization | <https://docs.djangoproject.com/en/stable/topics/db/optimization/> |
| Django Transactions | <https://docs.djangoproject.com/en/stable/topics/db/transactions/> |
| Django Security | <https://docs.djangoproject.com/en/stable/topics/security/> |
| Django Migrations | <https://docs.djangoproject.com/en/stable/topics/migrations/> |
| pytest-django | <https://pytest-django.readthedocs.io/en/latest/> |
| Fixing N+1 in DRF | <https://hakibenita.com/django-rest-framework-slow> |
| on\_commit patterns | <https://hakibenita.com/django-atomic-requests-and-on-commit> |

### React / TypeScript

| Topic | URL |
|-------|-----|
| React Hooks reference | <https://react.dev/reference/react/hooks> |
| A Complete Guide to useEffect | <https://overreacted.io/a-complete-guide-to-useeffect/> |
| TypeScript Handbook | <https://www.typescriptlang.org/docs/handbook/intro.html> |
| Re-renders guide | <https://www.developerway.com/posts/react-re-renders-guide> |
| TanStack Query | <https://tkdodo.eu/blog/practical-react-query> |
| Zod | <https://zod.dev/> |
| React Testing Library | <https://testing-library.com/docs/react-testing-library/intro/> |
| Common RTL Mistakes | <https://kentcdodds.com/blog/common-mistakes-with-react-testing-library> |
| WCAG 2.1 Quick Reference | <https://www.w3.org/WAI/WCAG21/quickref/> |
| ARIA Authoring Practices | <https://www.w3.org/WAI/ARIA/apg/patterns/> |
