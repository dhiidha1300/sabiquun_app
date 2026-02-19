'use client'

import Link from 'next/link'
import { useAuth } from '@/lib/contexts/auth-context'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { UserX, ArrowLeft, Home, LogOut } from 'lucide-react'

export default function AccountInactivePage() {
  const { signOut, profile } = useAuth()

  const handleSignOut = async () => {
    await signOut()
    window.location.href = '/login'
  }

  const getStatusMessage = () => {
    switch (profile?.account_status) {
      case 'pending':
        return 'Your account is pending approval. Please wait for an administrator to approve your account.'
      case 'suspended':
        return 'Your account has been suspended. Please contact an administrator for more information.'
      case 'auto_deactivated':
        return 'Your account has been automatically deactivated due to high penalty balance. Please clear your balance to reactivate.'
      case 'deleted':
        return 'Your account has been deleted. Please contact an administrator if you believe this is an error.'
      default:
        return 'Your account is not active. Please contact an administrator for assistance.'
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-muted/30 px-4">
      <div className="w-full max-w-md">
        <Card className="text-center">
          <CardHeader>
            <div className="mx-auto w-16 h-16 rounded-full bg-orange-500/10 flex items-center justify-center mb-4">
              <UserX className="h-8 w-8 text-orange-500" />
            </div>
            <CardTitle className="text-2xl font-bold">Account Inactive</CardTitle>
            <CardDescription>
              Your account is currently not active
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-sm text-muted-foreground">
              {getStatusMessage()}
            </p>

            {profile?.account_status === 'auto_deactivated' && (
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-sm font-medium">Current Balance</p>
                <p className="text-2xl font-bold text-destructive">
                  {((profile as any).user_statistics?.current_penalty_balance || 0).toLocaleString()} SOS
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  Contact the cashier to clear your balance
                </p>
              </div>
            )}

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <Link href="/">
                <Button variant="outline" className="w-full sm:w-auto">
                  <Home className="mr-2 h-4 w-4" />
                  Go Home
                </Button>
              </Link>
              <Button onClick={handleSignOut} variant="destructive" className="w-full sm:w-auto">
                <LogOut className="mr-2 h-4 w-4" />
                Sign Out
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
