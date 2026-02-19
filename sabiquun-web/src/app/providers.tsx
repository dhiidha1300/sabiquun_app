'use client'

import { AuthProvider } from '@/lib/contexts/auth-context'
import { ReactNode } from 'react'

export function Providers({ children }: { children: ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>
}
