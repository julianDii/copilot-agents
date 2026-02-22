// Fixture: no issues — hallucination test for react-ts-review agent
// Expected finding: nothing — agent must NOT fabricate issues
// Covers: stable keys, correct useCallback deps, ARIA, keyboard nav, empty state, explicit types

import { useState, useCallback } from 'react'

interface Item {
  id: number
  label: string
}

interface Props {
  items: Item[]
  onSelect: (id: number) => void
}

export function ItemList({ items, onSelect }: Props) {
  const [selected, setSelected] = useState<number | null>(null)

  const handleClick = useCallback(
    (id: number) => {
      setSelected(id)
      onSelect(id)
    },
    [onSelect],
  )

  if (items.length === 0) {
    return <p>No items available.</p>
  }

  return (
    <ul role="listbox" aria-label="Item list">
      {items.map(item => (
        <li
          key={item.id}
          role="option"
          aria-selected={selected === item.id}
          onClick={() => handleClick(item.id)}
          onKeyDown={e => e.key === 'Enter' && handleClick(item.id)}
          tabIndex={0}
        >
          {item.label}
        </li>
      ))}
    </ul>
  )
}

