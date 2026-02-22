# Snapshot: react-no-issues
# Agent: react-ts-review
# Fixture: fixtures/react/no_issues.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅
# Note: hallucination test — agent must find nothing

## Result: PASS

Component is correct:
- Stable `item.id` keys — not index
- `useCallback` with correct `[onSelect]` dep array
- Explicit `Props` and `Item` interfaces — no `any`
- Empty state guard renders a message instead of empty `<ul>`
- `role="listbox"` + `role="option"` + `aria-selected` — correct ARIA pattern
- `aria-label` on the list — accessible name present
- `onKeyDown` handler for Enter key — keyboard navigation supported
- `tabIndex={0}` on each item — focusable via keyboard
- No `useEffect`, no derived state, no unsafe assertions

