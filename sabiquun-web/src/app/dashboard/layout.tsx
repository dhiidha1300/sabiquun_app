'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/lib/contexts/auth-context'
import { DashboardSidebar } from '@/components/dashboard/sidebar'
import { DashboardHeader } from '@/components/dashboard/header'
import { SidebarProvider, SidebarInset } from '@/components/ui/sidebar'
import { Toaster } from '@/components/ui/sonner'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'

function DashboardContent({
  children,
}: {
  children: React.ReactNode
}) {
  const { user, profile, isLoading, error } = useAuth()
  const router = useRouter()
  const [loadingTimeout, setLoadingTimeout] = useState(false)

  useEffect(() => {
    console.log('Dashboard Layout - Auth State:', { user: !!user, profile: !!profile, isLoading, error })

    if (!isLoading && !user) {
      console.log('No user found, redirecting to login')
      router.push('/login')
    }
  }, [user, isLoading, router, profile, error])

  // Set timeout to prevent infinite loading
  useEffect(() => {
    const timeout = setTimeout(() => {
      if (isLoading) {
        setLoadingTimeout(true)
      }
    }, 10000) // 10 second timeout

    return () => clearTimeout(timeout)
  }, [isLoading])

  if (isLoading) {
    if (loadingTimeout) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4">
          <div className="w-full max-w-md space-y-4">
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                {error || 'Loading is taking longer than expected. This might be due to a connection issue.'}
              </AlertDescription>
            </Alert>
            <div className="flex gap-2">
              <Button onClick={() => router.push('/login')} variant="outline" className="flex-1">
                Back to Login
              </Button>
              <Button onClick={() => window.location.reload()} className="flex-1">
                Retry
              </Button>
            </div>
          </div>
        </div>
      )
    }

    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
          <p className="text-muted-foreground">Loading your dashboard...</p>
        </div>
      </div>
    )
  }

  if (!user || !profile) {
    // Show error if we have a user but no profile
    if (user && !profile) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4">
          <div className="w-full max-w-md space-y-4">
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                {error || 'Failed to load user profile. Your account may not be set up correctly.'}
              </AlertDescription>
            </Alert>
            <div className="flex gap-2">
              <Button onClick={() => router.push('/login')} variant="outline" className="flex-1">
                Back to Login
              </Button>
              <Button onClick={() => window.location.reload()} className="flex-1">
                Retry
              </Button>
            </div>
          </div>
        </div>
      )
    }
    return null
  }

  console.log('Dashboard Layout - Rendering dashboard with profile:', profile.email, profile.role)

  return (
    <SidebarProvider>
      <DashboardSidebar user={profile} />
      <SidebarInset>
        <DashboardHeader user={profile} />
        <main className="flex-1 p-6">
          {children}
        </main>
      </SidebarInset>
      <Toaster />
    </SidebarProvider>
  )
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <DashboardContent>{children}</DashboardContent>
}
