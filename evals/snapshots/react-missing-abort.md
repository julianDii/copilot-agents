# Snapshot: react-missing-abort
# Agent: react-ts-review
# Fixture: fixtures/react/missing_abort.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Single `useEffect` fetching user data with no cancellation mechanism
- `userId` prop changes cause out-of-order state updates — wrong user's data can silently render
- Risk: race condition on rapid prop changes, no error state, `res.json()` called on error responses

## Major issues

1. No `AbortController` — fetch not cancelled on unmount or `userId` change; out-of-order responses silently set wrong user data
2. No error handling — `loading` stays `true` forever on network failure or non-2xx response

## Minor issues

3. `res.json()` called regardless of response status — 404/500 sets `user` to error object; `user?.name` renders `undefined` silently

## Suggested patch

```tsx
useEffect(() => {
  const controller = new AbortController()
  setLoading(true)
  setError(null)

  fetch(`/api/users/${userId}`, { signal: controller.signal })
    .then(res => {
      if (!res.ok) throw new Error(`Unexpected status ${res.status}`)
      return res.json() as Promise<User>
    })
    .then(data => { setUser(data); setLoading(false) })
    .catch(err => {
      if (err.name === 'AbortError') return
      setError(err.message); setLoading(false)
    })

  return () => controller.abort()
}, [userId])
```

## Tests

```tsx
test('renders user name on success', ...)
test('shows error on non-ok response', ...)
test('aborts on unmount', ...)
test('aborts previous fetch on userId change', ...)
```

