'use client'

import { useEffect, useState, useCallback, useMemo } from 'react'
import { User as SupabaseUser } from '@supabase/supabase-js'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { User, UserRole } from '@/lib/types/database'

interface AuthState {
  user: SupabaseUser | null
  profile: User | null
  isLoading: boolean
  error: string | null
}

let renderCount = 0

export function useAuth() {
  renderCount++
  console.log(`🔄 useAuth hook called (render #${renderCount})`)

  const [state, setState] = useState<AuthState>({
    user: null,
    profile: null,
    isLoading: true,
    error: null,
  })

  const supabase = getSupabaseClient()

  useEffect(() => {
    // Check if Supabase client is available
    if (!supabase) {
      console.error('useAuth - Supabase client is null')
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

    // Absolute safety timeout - if nothing happens in 15 seconds, stop loading
    timeoutId = setTimeout(() => {
      if (isMounted) {
        console.error('useAuth - Absolute timeout reached, forcing loading to false')
        setState(prev => ({
          ...prev,
          isLoading: false,
          error: 'Authentication timeout - please refresh the page'
        }))
      }
    }, 15000)

    // Get initial session
    const getSession = async () => {
      console.log('🔐 useAuth - Fetching session from API...')

      try {
        // Call our API endpoint which runs server-side and has access to HTTP-only cookies
        const response = await fetch('/api/auth/me', {
          credentials: 'include', // Important: send cookies with request
          cache: 'no-store', // Don't cache auth responses
        })

        if (!isMounted) return

        if (!response.ok) {
          if (response.status === 401) {
            // Not authenticated
            console.log('🔐 useAuth - Not authenticated')
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
          console.log('✅ useAuth - Authenticated:', data.profile.email, `(${data.profile.role})`)
          clearTimeout(timeoutId)
          setState({
            user: data.user,
            profile: data.profile,
            isLoading: false,
            error: null,
          })
        } else if (data.user && !data.profile) {
          console.log('⚠️ useAuth - User found but no profile')
          clearTimeout(timeoutId)
          setState({
            user: data.user,
            profile: null,
            isLoading: false,
            error: data.error || 'Profile not found',
          })
        } else {
          console.log('🔐 useAuth - No user found')
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
        console.error('useAuth - Error fetching from API:', err)
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

        console.log('useAuth - Auth state changed:', event)

        // Only process SIGNED_IN and SIGNED_OUT events, ignore others
        if (event !== 'SIGNED_IN' && event !== 'SIGNED_OUT' && event !== 'TOKEN_REFRESHED') {
          return
        }

        if (session?.user) {
          // Fetch profile
          const { data: profileData } = await supabase
            .from('users')
            .select('*')
            .eq('id', session.user.id)
            .single()

          if (!isMounted) return

          setState(prev => {
            // Prevent unnecessary updates if user hasn't changed
            if (prev.user?.id === session.user.id && prev.profile?.id === profileData?.id) {
              console.log('useAuth - Auth state unchanged, skipping update')
              return prev
            }

            console.log('useAuth - Updating auth state from listener')
            return {
              user: session.user,
              profile: profileData ? (profileData as User) : null,
              isLoading: false,
              error: null,
            }
          })
        } else {
          setState(prev => {
            // If already signed out, don't update
            if (!prev.user) {
              console.log('useAuth - Already signed out, skipping update')
              return prev
            }

            console.log('useAuth - Signing out from listener')
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

  // Role check helpers - memoize to prevent unnecessary recalculations
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

  // Memoize the return object to prevent infinite re-render loops
  // Include memoized callbacks and helpers in dependencies since they're in the return object
  return useMemo(() => ({
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
    state.user?.id,
    state.profile?.id,
    state.profile?.role,
    state.profile?.email,
    state.profile?.name,
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
}
