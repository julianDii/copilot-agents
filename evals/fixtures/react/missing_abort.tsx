// Fixture: async request not cancelled on unmount — race condition
// Expected finding: Major — fetch not aborted on unmount, can set state on unmounted component

import { useState, useEffect } from 'react'

interface User {
  id: number
  name: string
}

export function UserProfile({ userId }: { userId: number }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // No AbortController — fetch continues after unmount or userId change
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)     // can fire on unmounted component
        setLoading(false)
      })
  }, [userId])

  if (loading) return <p>Loading...</p>
  return <p>{user?.name}</p>
}

