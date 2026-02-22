// Fixture: stale closure / derived state in useEffect
// Expected finding: Major — derived state stored unnecessarily in state,
//                   useEffect with missing dependency

import { useState, useEffect } from 'react'

interface CartItem {
  price: number
  quantity: number
}

export function CartSummary({ items }: { items: CartItem[] }) {
  const [total, setTotal] = useState(0)
  const [taxAmount, setTaxAmount] = useState(0)
  const TAX_RATE = 0.2

  // derived state — should be computed directly in render
  useEffect(() => {
    setTotal(items.reduce((sum, i) => sum + i.price * i.quantity, 0))
  }, [items])

  // stale closure — TAX_RATE missing from deps
  useEffect(() => {
    setTaxAmount(total * TAX_RATE)
  }, [total]) // TAX_RATE missing from dependency array

  return (
    <div>
      <p>Subtotal: {total}</p>
      <p>Tax: {taxAmount}</p>
    </div>
  )
}

