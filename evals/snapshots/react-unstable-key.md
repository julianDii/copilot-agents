# Snapshot: react-unstable-key
# Agent: react-ts-review
# Fixture: fixtures/react/unstable_key.tsx
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Filtered list uses array index as React key
- Index keys on filtered/sorted lists cause React to reuse the wrong DOM nodes
- Risk: incorrect UI state (checkboxes, inputs, animations) when tasks are completed, reordered, or added

## Minor issues

1. **`key={index}` on a filtered list — unstable key**
   - After `.filter(t => !t.done)`, the index no longer corresponds to the original item identity
   - Completing task at index 0 shifts all remaining indices — React reuses DOM nodes incorrectly
   - Concrete scenario: if `<li>` contained an `<input>`, the input value would visually shift to the wrong task after filtering
   - Fix: `key={task.id}` — use the stable, unique identity

## Suggested patch

```tsx
export function TaskList({ tasks }: { tasks: Task[] }) {
  return (
    <ul>
      {tasks
        .filter(t => !t.done)
        .map((task) => (
          <li key={task.id}>{task.title}</li>
        ))}
    </ul>
  )
}
```

## Tests

```tsx
test('renders only incomplete tasks', () => {
  const tasks = [
    { id: 1, title: 'Buy milk', done: false },
    { id: 2, title: 'Walk dog', done: true },
    { id: 3, title: 'Read book', done: false },
  ]
  render(<TaskList tasks={tasks} />)
  expect(screen.getByText('Buy milk')).toBeInTheDocument()
  expect(screen.queryByText('Walk dog')).toBeNull()
  expect(screen.getByText('Read book')).toBeInTheDocument()
})

test('renders empty list without error', () => {
  render(<TaskList tasks={[]} />)
  expect(document.querySelectorAll('li')).toHaveLength(0)
})
```

