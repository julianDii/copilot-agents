# Snapshot: react-stale-closure
# Agent: react-ts-review
# Fixture: fixtures/react/stale_closure.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Two `useEffect` hooks storing values that are purely derived from props/state
- Both can be eliminated entirely — computed in render instead
- Risk: unnecessary re-renders, stale `taxAmount` if `TAX_RATE` ever becomes dynamic

## Major issues

1. **`total` is derived state — unnecessary `useEffect` + `useState`**
   - `total` is always `items.reduce(...)` — it depends only on `items` and never needs to be stored
   - Storing it in state causes an extra render cycle on every `items` change (render with old `total` → effect fires → setState → re-render with new `total`)
   - Fix: `const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0)`

2. **`taxAmount` is derived state + stale closure**
   - `taxAmount` depends only on `total` and `TAX_RATE` — both known at render time
   - `TAX_RATE` is missing from the dependency array — if it ever becomes a prop or state, `taxAmount` will be stale
   - Fix: `const taxAmount = total * TAX_RATE`

## Suggested patch

```tsx
export function CartSummary({ items }: { items: CartItem[] }) {
  const TAX_RATE = 0.2
  const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0)
  const taxAmount = total * TAX_RATE

  return (
    <div>
      <p>Subtotal: {total}</p>
      <p>Tax: {taxAmount}</p>
    </div>
  )
}
```

## Tests

```tsx
test('renders correct total and tax', () => {
  const items = [{ price: 10, quantity: 2 }, { price: 5, quantity: 1 }]
  render(<CartSummary items={items} />)
  expect(screen.getByText('Subtotal: 25')).toBeInTheDocument()
  expect(screen.getByText('Tax: 5')).toBeInTheDocument()
})

test('updates total when items change', () => {
  const { rerender } = render(<CartSummary items={[{ price: 10, quantity: 1 }]} />)
  rerender(<CartSummary items={[{ price: 20, quantity: 1 }]} />)
  expect(screen.getByText('Subtotal: 20')).toBeInTheDocument()
})

test('renders zero total for empty items', () => {
  render(<CartSummary items={[]} />)
  expect(screen.getByText('Subtotal: 0')).toBeInTheDocument()
})
```

