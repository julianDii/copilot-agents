// Fixture: unsafe type assertion on API response
// Expected finding: Major — casting API response without runtime validation,
//                   role check based on unvalidated data is a security risk

import { useState, useEffect } from 'react'

interface UserProfile {
  id: number
  name: string
  email: string
  role: 'admin' | 'user'
}

async function fetchProfile(userId: number): Promise<UserProfile> {
  const res = await fetch(`/api/users/${userId}`)
  const data = await res.json()
  return data as UserProfile // no runtime validation — trusts API shape blindly
}

export function AdminPanel({ userId }: { userId: number }) {
  const [profile, setProfile] = useState<UserProfile | null>(null)

  useEffect(() => {
    fetchProfile(userId).then(setProfile)
  }, [userId])

  // role check based on unvalidated data — attacker can return role: 'admin'
  if (profile?.role === 'admin') {
    return <div>Admin controls here</div>
  }
  return <div>Access denied</div>
}

