# Snapshot: react-unsafe-assertion
# Agent: react-ts-review
# Fixture: fixtures/react/unsafe_assertion.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- API response cast directly to `UserProfile` with no runtime validation
- Role check for admin access is based on unvalidated server data
- Risk: compromised API or MITM attack returns `role: 'admin'` → full admin access granted

## Major issues

1. **Unsafe `as UserProfile` cast — no runtime validation**
   - `data as UserProfile` is a compile-time assertion only — TypeScript erases it at runtime
   - If the API returns `{ role: 'administrator' }` or omits `role` entirely, `profile.role === 'admin'` silently evaluates to `false` — no error, wrong behaviour
   - If the API is compromised, it can return `{ role: 'admin' }` for any user — the check passes
   - Fix: validate the response shape at runtime with `zod` before trusting it

2. **No error handling on `fetchProfile`**
   - Network failure or non-2xx response leaves `profile` as `null` indefinitely with no feedback to the user
   - Fix: add error state

## Suggested patch

```tsx
import { z } from 'zod'

const UserProfileSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
})

type UserProfile = z.infer<typeof UserProfileSchema>

async function fetchProfile(userId: number): Promise<UserProfile> {
  const res = await fetch(`/api/users/${userId}`)
  if (!res.ok) throw new Error(`Unexpected status ${res.status}`)
  const data = await res.json()
  return UserProfileSchema.parse(data) // throws ZodError if shape is wrong
}
```

## Tests

```tsx
test('grants admin access when role is admin', async () => {
  vi.stubGlobal('fetch', () =>
    Promise.resolve({ ok: true, json: () => Promise.resolve(
      { id: 1, name: 'Alice', email: 'a@b.com', role: 'admin' }
    )})
  )
  render(<AdminPanel userId={1} />)
  await waitFor(() => expect(screen.getByText('Admin controls here')).toBeInTheDocument())
})

test('denies access when role is user', async () => {
  vi.stubGlobal('fetch', () =>
    Promise.resolve({ ok: true, json: () => Promise.resolve(
      { id: 2, name: 'Bob', email: 'b@c.com', role: 'user' }
    )})
  )
  render(<AdminPanel userId={2} />)
  await waitFor(() => expect(screen.getByText('Access denied')).toBeInTheDocument())
})

test('rejects invalid role from API', async () => {
  vi.stubGlobal('fetch', () =>
    Promise.resolve({ ok: true, json: () => Promise.resolve(
      { id: 3, name: 'Eve', email: 'e@f.com', role: 'superuser' } // not in enum
    )})
  )
  render(<AdminPanel userId={3} />)
  await waitFor(() => expect(screen.getByText(/error/i)).toBeInTheDocument())
})
```

