'use client'

import { useEffect, useState } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuth } from '@/lib/contexts/auth-context'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart'
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
  Legend,
} from 'recharts'
import {
  Users,
  TrendingUp,
  CreditCard,
  FileText,
  AlertCircle,
  CheckCircle2,
  DollarSign,
  Activity,
} from 'lucide-react'

interface AnalyticsData {
  totalUsers: number
  activeUsers: number
  pendingUsers: number
  totalReports: number
  todayReports: number
  totalPayments: number
  pendingPayments: number
  approvedPaymentsAmount: number
  totalPenaltyBalance: number
  pendingExcuses: number
  usersByRole: { name: string; value: number }[]
  usersByStatus: { name: string; value: number }[]
  reportsLast7Days: { date: string; count: number }[]
  paymentsLast7Days: { date: string; amount: number }[]
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']

export default function AnalyticsPage() {
  const { isAdmin, isCashier, isSupervisor } = useAuth()
  const [data, setData] = useState<AnalyticsData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const supabase = getSupabaseClient()

  useEffect(() => {
    const fetchAnalytics = async () => {
      setIsLoading(true)

      try {
        // Fetch all stats in parallel
        const [
          usersResult,
          activeUsersResult,
          pendingUsersResult,
          reportsResult,
          todayReportsResult,
          paymentsResult,
          pendingPaymentsResult,
          approvedPaymentsResult,
          balanceResult,
          pendingExcusesResult,
          roleStatsResult,
          statusStatsResult,
        ] = await Promise.all([
          supabase.from('users').select('id', { count: 'exact', head: true }),
          supabase.from('users').select('id', { count: 'exact', head: true }).eq('account_status', 'active'),
          supabase.from('users').select('id', { count: 'exact', head: true }).eq('account_status', 'pending'),
          supabase.from('deeds_reports').select('id', { count: 'exact', head: true }),
          supabase.from('deeds_reports').select('id', { count: 'exact', head: true })
            .eq('report_date', new Date().toISOString().split('T')[0]),
          supabase.from('payments').select('id', { count: 'exact', head: true }),
          supabase.from('payments').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
          supabase.from('payments').select('amount').eq('status', 'approved'),
          supabase.from('penalties').select('amount, paid_amount').neq('status', 'paid').neq('status', 'waived'),
          supabase.from('excuses').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
          supabase.from('users').select('role'),
          supabase.from('users').select('account_status'),
        ])

        // Process role stats
        const roleCounts: Record<string, number> = {}
        const roleData = roleStatsResult.data as { role: string }[] | null
        roleData?.forEach((u) => {
          roleCounts[u.role] = (roleCounts[u.role] || 0) + 1
        })
        const usersByRole = Object.entries(roleCounts).map(([name, value]) => ({
          name: name.charAt(0).toUpperCase() + name.slice(1),
          value,
        }))

        // Process status stats
        const statusCounts: Record<string, number> = {}
        const statusData = statusStatsResult.data as { account_status: string }[] | null
        statusData?.forEach((u) => {
          const status = u.account_status.replace('_', ' ')
          statusCounts[status] = (statusCounts[status] || 0) + 1
        })
        const usersByStatus = Object.entries(statusCounts).map(([name, value]) => ({
          name: name.charAt(0).toUpperCase() + name.slice(1),
          value,
        }))

        // Generate last 7 days data (mock for now - would need proper queries)
        const reportsLast7Days = Array.from({ length: 7 }, (_, i) => {
          const date = new Date()
          date.setDate(date.getDate() - (6 - i))
          return {
            date: date.toLocaleDateString('en-US', { weekday: 'short' }),
            count: Math.floor(Math.random() * 50) + 10,
          }
        })

        const paymentsLast7Days = Array.from({ length: 7 }, (_, i) => {
          const date = new Date()
          date.setDate(date.getDate() - (6 - i))
          return {
            date: date.toLocaleDateString('en-US', { weekday: 'short' }),
            amount: Math.floor(Math.random() * 500000) + 100000,
          }
        })

        const approvedPaymentsData = approvedPaymentsResult.data as { amount: number }[] | null
        const approvedPaymentsAmount = approvedPaymentsData?.reduce(
          (sum, p) => sum + (p.amount || 0),
          0
        ) || 0

        // Calculate total unpaid penalty balance (amount - paid_amount for each penalty)
        const penaltiesData = balanceResult.data as { amount: number; paid_amount: number }[] | null
        const totalPenaltyBalance = penaltiesData?.reduce(
          (sum, p) => sum + ((p.amount || 0) - (p.paid_amount || 0)),
          0
        ) || 0

        setData({
          totalUsers: usersResult.count || 0,
          activeUsers: activeUsersResult.count || 0,
          pendingUsers: pendingUsersResult.count || 0,
          totalReports: reportsResult.count || 0,
          todayReports: todayReportsResult.count || 0,
          totalPayments: paymentsResult.count || 0,
          pendingPayments: pendingPaymentsResult.count || 0,
          approvedPaymentsAmount,
          totalPenaltyBalance,
          pendingExcuses: pendingExcusesResult.count || 0,
          usersByRole,
          usersByStatus,
          reportsLast7Days,
          paymentsLast7Days,
        })
      } catch (error) {
        console.error('Error fetching analytics:', error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchAnalytics()
  }, [supabase])

  const StatCard = ({
    title,
    value,
    description,
    icon: Icon,
    trend,
  }: {
    title: string
    value: string | number
    description: string
    icon: React.ComponentType<{ className?: string }>
    trend?: 'up' | 'down'
  }) => (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <p className="text-xs text-muted-foreground flex items-center gap-1">
          {trend === 'up' && <TrendingUp className="h-3 w-3 text-green-500" />}
          {trend === 'down' && <TrendingUp className="h-3 w-3 text-red-500 rotate-180" />}
          {description}
        </p>
      </CardContent>
    </Card>
  )

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Analytics Dashboard</h1>
          <p className="text-muted-foreground">
            Overview of system metrics and performance
          </p>
        </div>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Card key={i}>
              <CardHeader className="pb-2">
                <Skeleton className="h-4 w-24" />
              </CardHeader>
              <CardContent>
                <Skeleton className="h-8 w-16 mb-1" />
                <Skeleton className="h-3 w-32" />
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Analytics Dashboard</h1>
        <p className="text-muted-foreground">
          Overview of system metrics and performance
        </p>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {isAdmin && (
          <>
            <StatCard
              title="Total Users"
              value={data?.totalUsers || 0}
              description={`${data?.activeUsers || 0} active users`}
              icon={Users}
              trend="up"
            />
            <StatCard
              title="Pending Approvals"
              value={data?.pendingUsers || 0}
              description="Users awaiting approval"
              icon={AlertCircle}
            />
          </>
        )}

        {(isAdmin || isSupervisor) && (
          <>
            <StatCard
              title="Today's Reports"
              value={data?.todayReports || 0}
              description={`${data?.totalReports || 0} total reports`}
              icon={FileText}
            />
            <StatCard
              title="Pending Excuses"
              value={data?.pendingExcuses || 0}
              description="Awaiting review"
              icon={AlertCircle}
            />
          </>
        )}

        {(isAdmin || isCashier) && (
          <>
            <StatCard
              title="Pending Payments"
              value={data?.pendingPayments || 0}
              description={`${data?.totalPayments || 0} total payments`}
              icon={CreditCard}
            />
            <StatCard
              title="Total Approved"
              value={`${(data?.approvedPaymentsAmount || 0).toLocaleString()} SOS`}
              description="All time approved payments"
              icon={CheckCircle2}
            />
            <StatCard
              title="Total Balance"
              value={`${(data?.totalPenaltyBalance || 0).toLocaleString()} SOS`}
              description="Outstanding penalty balance"
              icon={DollarSign}
            />
          </>
        )}
      </div>

      {/* Charts */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Reports Chart */}
        {(isAdmin || isSupervisor) && (
          <Card>
            <CardHeader>
              <CardTitle>Reports - Last 7 Days</CardTitle>
              <CardDescription>Daily report submissions</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer
                config={{
                  count: {
                    label: "Reports",
                    color: "hsl(var(--primary))",
                  },
                }}
                className="h-[300px]"
              >
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={data?.reportsLast7Days}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <Bar dataKey="count" fill="hsl(var(--primary))" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        )}

        {/* Payments Chart */}
        {(isAdmin || isCashier) && (
          <Card>
            <CardHeader>
              <CardTitle>Payments - Last 7 Days</CardTitle>
              <CardDescription>Daily payment amounts (SOS)</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer
                config={{
                  amount: {
                    label: "Amount (SOS)",
                    color: "hsl(var(--primary))",
                  },
                }}
                className="h-[300px]"
              >
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={data?.paymentsLast7Days}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis tickFormatter={(value) => `${(value / 1000).toFixed(0)}k`} />
                    <ChartTooltip
                      content={<ChartTooltipContent />}
                      formatter={(value: number) => [`${value.toLocaleString()} SOS`, 'Amount']}
                    />
                    <Line
                      type="monotone"
                      dataKey="amount"
                      stroke="hsl(var(--primary))"
                      strokeWidth={2}
                      dot={{ fill: 'hsl(var(--primary))' }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        )}

        {/* Users by Role */}
        {isAdmin && (
          <Card>
            <CardHeader>
              <CardTitle>Users by Role</CardTitle>
              <CardDescription>Distribution of user roles</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer
                config={{
                  value: {
                    label: "Users",
                  },
                }}
                className="h-[300px]"
              >
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={data?.usersByRole}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {data?.usersByRole.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <Legend />
                  </PieChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        )}

        {/* Users by Status */}
        {isAdmin && (
          <Card>
            <CardHeader>
              <CardTitle>Users by Status</CardTitle>
              <CardDescription>Distribution of account statuses</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer
                config={{
                  value: {
                    label: "Users",
                  },
                }}
                className="h-[300px]"
              >
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={data?.usersByStatus}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {data?.usersByStatus.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <Legend />
                  </PieChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}
