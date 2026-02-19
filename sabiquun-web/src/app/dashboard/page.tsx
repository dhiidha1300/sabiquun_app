'use client'

import { useEffect, useState, useRef } from 'react'
import Link from 'next/link'
import { useAuth } from '@/lib/contexts/auth-context'
import { getSupabaseClient } from '@/lib/supabase/client'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Users,
  CreditCard,
  FileText,
  AlertCircle,
  TrendingUp,
  TrendingDown,
  Clock,
  CheckCircle2,
} from 'lucide-react'

interface DashboardStats {
  totalUsers: number
  activeUsers: number
  pendingUsers: number
  pendingPayments: number
  pendingPaymentsAmount: number
  pendingExcuses: number
  todayReports: number
  totalPenaltyBalance: number
  totalPaidPayments: number
}

export default function DashboardPage() {
  const { profile, isAdmin, isCashier, isSupervisor, isLoading: authLoading } = useAuth()
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Don't fetch if still loading auth
    if (authLoading) return

    let isMounted = true

    const fetchStats = async () => {
      const supabase = getSupabaseClient()

      if (!supabase) {
        console.error('Dashboard - Supabase client is null')
        if (isMounted) {
          setError('Database connection not available')
          setIsLoading(false)
        }
        return
      }

      try {
        const today = new Date().toISOString().split('T')[0]

        // Optimized: Use count queries (head: true) which are faster than fetching data
        const [
          usersResult,
          pendingUsersResult,
          pendingPaymentsResult,
          pendingExcusesResult,
          todayReportsResult,
          unpaidPenaltiesResult,
          approvedPaymentsResult,
        ] = await Promise.all([
          // Total users - count only
          supabase.from('users').select('*', { count: 'exact', head: true }),
          // Pending users - count only
          supabase.from('users').select('*', { count: 'exact', head: true }).eq('account_status', 'pending'),
          // Pending payments - need amounts
          supabase.from('payments').select('amount', { head: false }).eq('status', 'pending'),
          // Pending excuses - count only
          supabase.from('excuses').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
          // Today's reports - count only
          supabase.from('deeds_reports').select('*', { count: 'exact', head: true }).eq('report_date', today),
          // Unpaid penalties - get amount and paid_amount to calculate remaining balance
          supabase.from('penalties').select('amount, paid_amount').neq('status', 'paid').neq('status', 'waived'),
          // Approved payments - need amounts
          supabase.from('payments').select('amount', { head: false }).eq('status', 'approved'),
        ])

        // Check for any errors
        const errors = [
          usersResult.error,
          pendingUsersResult.error,
          pendingPaymentsResult.error,
          pendingExcusesResult.error,
          todayReportsResult.error,
          unpaidPenaltiesResult.error,
          approvedPaymentsResult.error,
        ].filter(Boolean)

        if (errors.length > 0) {
          console.error('Dashboard - Errors in queries:', errors)
          if (isMounted) {
            setError('Some queries failed: ' + errors.map(e => e?.message).join(', '))
          }
        }

        const paymentsData = pendingPaymentsResult.data as { amount: number }[] | null
        const pendingPaymentsAmount = paymentsData?.reduce(
          (sum, p) => sum + (p.amount || 0),
          0
        ) || 0

        // Calculate total unpaid penalty balance (amount - paid_amount for each penalty)
        const penaltiesData = unpaidPenaltiesResult.data as { amount: number; paid_amount: number }[] | null
        const totalPenaltyBalance = penaltiesData?.reduce(
          (sum, p) => sum + ((p.amount || 0) - (p.paid_amount || 0)),
          0
        ) || 0

        // Calculate total approved payments
        const approvedPaymentsData = approvedPaymentsResult.data as { amount: number }[] | null
        const totalPaidPayments = approvedPaymentsData?.reduce(
          (sum, p) => sum + (p.amount || 0),
          0
        ) || 0

        const statsData = {
          totalUsers: usersResult.count || 0,
          activeUsers: (usersResult.count || 0) - (pendingUsersResult.count || 0),
          pendingUsers: pendingUsersResult.count || 0,
          pendingPayments: pendingPaymentsResult.data?.length || 0,
          pendingPaymentsAmount,
          pendingExcuses: pendingExcusesResult.count || 0,
          todayReports: todayReportsResult.count || 0,
          totalPenaltyBalance,
          totalPaidPayments,
        }

        if (isMounted) {
          console.log('✅ Dashboard - Stats loaded:', {
            users: statsData.totalUsers,
            reports: statsData.todayReports,
            payments: statsData.pendingPayments
          })
          setStats(statsData)
          setError(null)
        }
      } catch (error) {
        console.error('Dashboard - Error fetching stats:', error)
        if (isMounted) {
          setError(error instanceof Error ? error.message : 'Failed to load dashboard data')
        }
      } finally {
        if (isMounted) {
          setIsLoading(false)
        }
      }
    }

    fetchStats()

    return () => {
      isMounted = false
    }
  }, [authLoading])

  const statCards = [
    {
      title: 'Total Users',
      value: stats?.totalUsers || 0,
      description: `${stats?.activeUsers || 0} active, ${stats?.pendingUsers || 0} pending`,
      icon: Users,
      trend: 'up',
      roles: ['admin'],
    },
    {
      title: 'Pending Payments',
      value: stats?.pendingPayments || 0,
      description: `${(stats?.pendingPaymentsAmount || 0).toLocaleString()} SOS total`,
      icon: CreditCard,
      trend: stats?.pendingPayments && stats.pendingPayments > 0 ? 'attention' : 'normal',
      roles: ['admin', 'cashier'],
    },
    {
      title: 'Pending Excuses',
      value: stats?.pendingExcuses || 0,
      description: 'Awaiting review',
      icon: AlertCircle,
      trend: stats?.pendingExcuses && stats.pendingExcuses > 0 ? 'attention' : 'normal',
      roles: ['admin', 'supervisor'],
    },
    {
      title: "Today's Reports",
      value: stats?.todayReports || 0,
      description: 'Submitted today',
      icon: FileText,
      trend: 'normal',
      roles: ['admin', 'supervisor'],
    },
    {
      title: 'Total Penalty Balance',
      value: `${(stats?.totalPenaltyBalance || 0).toLocaleString()}`,
      description: 'SOS unpaid penalties',
      icon: TrendingUp,
      trend: 'normal',
      roles: ['admin', 'cashier'],
    },
    {
      title: 'Total Paid Payments',
      value: `${(stats?.totalPaidPayments || 0).toLocaleString()}`,
      description: 'SOS approved payments',
      icon: CheckCircle2,
      trend: 'normal',
      roles: ['admin', 'cashier'],
    },
  ]

  const filteredStatCards = statCards.filter((card) =>
    card.roles.some((role) => profile?.role === role)
  )

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight">
          Welcome back, {profile?.name?.split(' ')[0] || profile?.email?.split('@')[0] || 'Admin'}!
        </h1>
        <p className="text-muted-foreground mt-1">
          Here's what's happening with Sabiquun today.
        </p>
      </div>

      {/* Error Display */}
      {error && (
        <Card className="border-destructive">
          <CardHeader>
            <CardTitle className="text-destructive flex items-center gap-2">
              <AlertCircle className="h-5 w-5" />
              Error Loading Dashboard
            </CardTitle>
            <CardDescription>{error}</CardDescription>
          </CardHeader>
        </Card>
      )}

      {/* No Data Warning */}
      {!isLoading && !error && stats && (
        stats.totalUsers === 0 ||
        (stats.pendingPayments === 0 && stats.todayReports === 0 && stats.totalPenaltyBalance === 0)
      ) && (
        <Card className="border-yellow-500 bg-yellow-50 dark:bg-yellow-950">
          <CardHeader>
            <CardTitle className="text-yellow-700 dark:text-yellow-400 flex items-center gap-2">
              <AlertCircle className="h-5 w-5" />
              No Data Detected
            </CardTitle>
            <CardDescription className="text-yellow-600 dark:text-yellow-500">
              The database appears to be empty or Row Level Security (RLS) policies may be blocking access.
              {' '}
              <Link href="/dashboard/test-db" className="underline font-medium">
                Run diagnostic tests
              </Link>
              {' '}to check connectivity and permissions.
            </CardDescription>
          </CardHeader>
        </Card>
      )}

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => (
              <Card key={i}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <Skeleton className="h-4 w-24" />
                  <Skeleton className="h-4 w-4" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-8 w-16 mb-1" />
                  <Skeleton className="h-3 w-32" />
                </CardContent>
              </Card>
            ))
          : filteredStatCards.map((card) => (
              <Card key={card.title}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">
                    {card.title}
                  </CardTitle>
                  <card.icon className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{card.value}</div>
                  <p className="text-xs text-muted-foreground">
                    {card.description}
                  </p>
                  {card.trend === 'attention' && (
                    <Badge variant="destructive" className="mt-2 text-xs">
                      Needs attention
                    </Badge>
                  )}
                </CardContent>
              </Card>
            ))}
      </div>

      {/* Quick Actions */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {isAdmin && (
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <Users className="h-5 w-5 text-primary" />
                User Management
              </CardTitle>
              <CardDescription>
                Manage users, approve registrations, and handle account status
              </CardDescription>
            </CardHeader>
          </Card>
        )}

        {(isAdmin || isCashier) && (
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <CreditCard className="h-5 w-5 text-primary" />
                Payment Review
              </CardTitle>
              <CardDescription>
                Review and approve pending payment submissions
              </CardDescription>
            </CardHeader>
          </Card>
        )}

        {(isAdmin || isSupervisor) && (
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <AlertCircle className="h-5 w-5 text-primary" />
                Excuse Requests
              </CardTitle>
              <CardDescription>
                Review and process excuse requests from users
              </CardDescription>
            </CardHeader>
          </Card>
        )}
      </div>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
          <CardDescription>
            Latest actions and events in the system
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="flex items-center gap-4">
                  <Skeleton className="h-10 w-10 rounded-full" />
                  <div className="flex-1 space-y-2">
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-3 w-1/2" />
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-8 text-muted-foreground">
                <Clock className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <p>Activity feed will appear here</p>
                <p className="text-sm">Recent actions and events will be shown</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
