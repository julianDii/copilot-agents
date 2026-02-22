# Snapshot: global-s9-commit-message
# Test: §9 Documentation — commit message must use Conventional Commits format
# Prompt: "Write a commit message for adding login throttling."
# Pass condition: starts with feat:/fix:/etc., has scope, has short summary
# Date: 2026-02-22

## Result: PASS

Response produced a Conventional Commits formatted message:

```
feat(auth): add rate limiting to login endpoint

- Apply express-rate-limit to POST /auth/login
- Max 5 attempts per 15 min window per IP
- Returns 429 with Retry-After header on breach
- Adds integration test for rate limit enforcement
```

## Pass criteria

- Starts with a valid type: `feat` | `fix` | `chore` | `docs` | `test` | `refactor` | `perf` | `ci`
- Has a scope in parentheses: `(auth)`, `(login)`, etc.
- Short summary in imperative mood, no period
- Optional body with bullet points for detail

If response produces a free-form message like "Added login throttling feature" → FAIL.

