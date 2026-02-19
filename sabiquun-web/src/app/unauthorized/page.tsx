'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { ShieldX, ArrowLeft, Home, LogOut } from 'lucide-react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useState } from 'react'

export default function UnauthorizedPage() {
  const router = useRouter()
  const [isLoggingOut, setIsLoggingOut] = useState(false)

  const handleLogout = async () => {
    setIsLoggingOut(true)
    const supabase = getSupabaseClient()
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }
  return (
    <div className="min-h-screen flex items-center justify-center bg-muted/30 px-4">
      <div className="w-full max-w-md">
        <Card className="text-center">
          <CardHeader>
            <div className="mx-auto w-16 h-16 rounded-full bg-destructive/10 flex items-center justify-center mb-4">
              <ShieldX className="h-8 w-8 text-destructive" />
            </div>
            <CardTitle className="text-2xl font-bold">Access Denied</CardTitle>
            <CardDescription>
              You don't have permission to access the admin panel.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-sm text-muted-foreground">
              The admin panel is only accessible to users with Admin, Supervisor, or Cashier roles.
              If you believe this is an error, please contact your system administrator.
            </p>

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <Link href="/">
                <Button variant="outline" className="w-full sm:w-auto">
                  <Home className="mr-2 h-4 w-4" />
                  Go Home
                </Button>
              </Link>
              <Button
                onClick={handleLogout}
                disabled={isLoggingOut}
                className="w-full sm:w-auto"
              >
                <LogOut className="mr-2 h-4 w-4" />
                {isLoggingOut ? 'Signing out...' : 'Sign Out & Try Again'}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
