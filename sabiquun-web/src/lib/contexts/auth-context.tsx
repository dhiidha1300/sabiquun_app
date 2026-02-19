'use client'

import { createContext, useContext, useEffect, useState, useCallback, useMemo, ReactNode } from 'react'
import { User as SupabaseUser } from '@supabase/supabase-js'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { User, UserRole } from '@/lib/types/database'

interface AuthState {
  user: SupabaseUser | null
  profile: User | null
  isLoading: boolean
  error: string | null
}

interface AuthContextType extends AuthState {
  signIn: (email: string, password: string) => Promise<{ error?: any; data?: any }>
  signOut: () => Promise<{ error: any | null }>
  resetPassword: (email: string) => Promise<{ error: any }>
  isAdmin: boolean
  isSupervisor: boolean
  isCashier: boolean
  isElevated: boolean
  hasRole: (roles: UserRole[]) => boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    profile: null,
    isLoading: true,
    error: null,
  })

  const supabase = getSupabaseClient()

  useEffect(() => {
    console.log('🔐 AuthProvider - Initializing...')

    if (!supabase) {
      console.error('AuthProvider - Supabase client is null')
      setState({
        user: null,
        profile: null,
        isLoading: false,
        error: 'Supabase not configured',
      })
      return
    }

    let isMounted = true
    let timeoutId: NodeJS.Timeout

    // Absolute safety timeout
    timeoutId = setTimeout(() => {
      if (isMounted) {
        console.error('AuthProvider - Timeout reached')
        setState(prev => ({
          ...prev,
          isLoading: false,
          error: 'Authentication timeout - please refresh the page'
        }))
      }
    }, 15000)

    // Get initial session
    const getSession = async () => {
      console.log('🔐 AuthProvider - Fetching session from API...')

      try {
        const response = await fetch('/api/auth/me', {
          credentials: 'include',
          cache: 'no-store',
        })

        if (!isMounted) return

        if (!response.ok) {
          if (response.status === 401) {
            console.log('🔐 AuthProvider - Not authenticated')
            clearTimeout(timeoutId)
            setState({
              user: null,
              profile: null,
              isLoading: false,
              error: null,
            })
            return
          }

          throw new Error(`API error: ${response.status}`)
        }

        const data = await response.json()

        if (!isMounted) return

        if (data.user && data.profile) {
          console.log('✅ AuthProvider - Authenticated:', data.profile.email, `(${data.profile.role})`)
          clearTimeout(timeoutId)
          setState({
            user: data.user,
            profile: data.profile,
            isLoading: false,
            error: null,
          })
        } else if (data.user && !data.profile) {
          console.log('⚠️ AuthProvider - User found but no profile')
          clearTimeout(timeoutId)
          setState({
            user: data.user,
            profile: null,
            isLoading: false,
            error: data.error || 'Profile not found',
          })
        } else {
          console.log('🔐 AuthProvider - No user found')
          clearTimeout(timeoutId)
          setState({
            user: null,
            profile: null,
            isLoading: false,
            error: null,
          })
        }
      } catch (err) {
        if (!isMounted) return
        console.error('AuthProvider - Error fetching from API:', err)
        clearTimeout(timeoutId)
        setState({
          user: null,
          profile: null,
          isLoading: false,
          error: err instanceof Error ? err.message : 'Failed to authenticate',
        })
      }
    }

    getSession()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!isMounted) return

        console.log('AuthProvider - Auth state changed:', event)

        // Only process SIGNED_IN and SIGNED_OUT events
        if (event !== 'SIGNED_IN' && event !== 'SIGNED_OUT' && event !== 'TOKEN_REFRESHED') {
          return
        }

        if (session?.user) {
          const { data: profileData } = await supabase
            .from('users')
            .select('*')
            .eq('id', session.user.id)
            .single()

          if (!isMounted) return

          setState(prev => {
            if (prev.user?.id === session.user.id && prev.profile?.id === profileData?.id) {
              console.log('AuthProvider - Auth state unchanged, skipping update')
              return prev
            }

            console.log('AuthProvider - Updating auth state from listener')
            return {
              user: session.user,
              profile: profileData ? (profileData as User) : null,
              isLoading: false,
              error: null,
            }
          })
        } else {
          setState(prev => {
            if (!prev.user) {
              console.log('AuthProvider - Already signed out, skipping update')
              return prev
            }

            console.log('AuthProvider - Signing out from listener')
            return {
              user: null,
              profile: null,
              isLoading: false,
              error: null,
            }
          })
        }
      }
    )

    return () => {
      isMounted = false
      clearTimeout(timeoutId)
      subscription.unsubscribe()
    }
  }, [])

  const signIn = useCallback(async (email: string, password: string) => {
    const client = getSupabaseClient()
    if (!client) return { error: { message: 'Supabase not configured' } }

    setState(prev => ({ ...prev, isLoading: true, error: null }))

    const { data, error } = await client.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      setState(prev => ({ ...prev, isLoading: false, error: error.message }))
      return { error }
    }

    return { data }
  }, [])

  const signOut = useCallback(async () => {
    const client = getSupabaseClient()
    if (!client) return { error: { message: 'Supabase not configured' } }

    setState(prev => ({ ...prev, isLoading: true }))

    const { error } = await client.auth.signOut()

    if (error) {
      setState(prev => ({ ...prev, isLoading: false, error: error.message }))
      return { error }
    }

    setState({
      user: null,
      profile: null,
      isLoading: false,
      error: null,
    })

    return { error: null }
  }, [])

  const resetPassword = useCallback(async (email: string) => {
    const client = getSupabaseClient()
    if (!client) return { error: { message: 'Supabase not configured' } }

    const { error } = await client.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    })

    return { error }
  }, [])

  // Role check helpers
  const isAdmin = useMemo(() => state.profile?.role === 'admin', [state.profile?.role])
  const isSupervisor = useMemo(() => state.profile?.role === 'supervisor', [state.profile?.role])
  const isCashier = useMemo(() => state.profile?.role === 'cashier', [state.profile?.role])
  const isElevated = useMemo(
    () => ['admin', 'supervisor', 'cashier'].includes(state.profile?.role || ''),
    [state.profile?.role]
  )

  const hasRole = useCallback((roles: UserRole[]) => {
    return roles.includes(state.profile?.role as UserRole)
  }, [state.profile?.role])

  const value = useMemo(() => ({
    user: state.user,
    profile: state.profile,
    isLoading: state.isLoading,
    error: state.error,
    signIn,
    signOut,
    resetPassword,
    isAdmin,
    isSupervisor,
    isCashier,
    isElevated,
    hasRole,
  }), [
    state.user,
    state.profile,
    state.isLoading,
    state.error,
    signIn,
    signOut,
    resetPassword,
    isAdmin,
    isSupervisor,
    isCashier,
    isElevated,
    hasRole,
  ])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
