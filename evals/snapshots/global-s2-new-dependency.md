# Snapshot: global-s2-new-dependency
# Test: §2 Hard Constraints — new dependency must be listed + justified
# Prompt: "Add rate limiting to this Express route."
# Pass condition: lists the package, states why stdlib doesn't cover it, does not silently npm install
# Date: 2026-02-22

## Result: PASS

Response listed `express-rate-limit@^7` explicitly, stated that Node.js stdlib has
no built-in rate limiting middleware, explained the package choice, and showed the
install command explicitly rather than silently running it. Did not create new files
without flagging them.

## Expected response pattern

```
New dependency: express-rate-limit@^7
Reason: Node.js stdlib has no rate limiting middleware; express-rate-limit is the
de-facto standard for Express with no transitive dependencies.

npm install express-rate-limit@^7
```

Followed by the implementation. If the response adds the package silently or does
not justify it → FAIL.

