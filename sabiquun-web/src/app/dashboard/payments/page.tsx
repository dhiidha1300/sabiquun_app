'use client'

import { useEffect, useState, useCallback } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuth } from '@/lib/contexts/auth-context'
import type { PaymentWithDetails, PaymentStatus } from '@/lib/types/database'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { toast } from 'sonner'
import {
  Search,
  RefreshCw,
  Loader2,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  XCircle,
  Clock,
  CreditCard,
  DollarSign,
} from 'lucide-react'

const PAGE_SIZE = 10

export default function PaymentsPage() {
  const { profile } = useAuth()
  const [payments, setPayments] = useState<PaymentWithDetails[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('pending')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalCount, setTotalCount] = useState(0)

  // Stats
  const [stats, setStats] = useState({
    pendingCount: 0,
    pendingAmount: 0,
    approvedCount: 0,
    approvedAmount: 0,
  })

  // Dialog states
  const [selectedPayment, setSelectedPayment] = useState<PaymentWithDetails | null>(null)
  const [dialogType, setDialogType] = useState<'approve' | 'reject' | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const fetchStats = useCallback(async () => {
    const supabase = getSupabaseClient()
    if (!supabase) return

    const [pendingResult, approvedResult] = await Promise.all([
      supabase.from('payments').select('amount').eq('status', 'pending'),
      supabase.from('payments').select('amount').eq('status', 'approved'),
    ])

    const pendingData = pendingResult.data as { amount: number }[] | null
    const approvedData = approvedResult.data as { amount: number }[] | null

    setStats({
      pendingCount: pendingData?.length || 0,
      pendingAmount: pendingData?.reduce((sum, p) => sum + p.amount, 0) || 0,
      approvedCount: approvedData?.length || 0,
      approvedAmount: approvedData?.reduce((sum, p) => sum + p.amount, 0) || 0,
    })
  }, [])

  const fetchPayments = useCallback(async () => {
    setIsLoading(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      setIsLoading(false)
      return
    }

    let query = supabase
      .from('payments')
      .select(`
        *,
        user:users!user_id(
          id,
          name,
          email,
          user_statistics(current_penalty_balance)
        )
      `, { count: 'exact' })
      .order('created_at', { ascending: false })
      .range((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE - 1)

    if (statusFilter !== 'all') {
      query = query.eq('status', statusFilter)
    }

    if (searchQuery) {
      // Search by reference number
      query = query.ilike('reference_number', `%${searchQuery}%`)
    }

    const { data, count, error } = await query

    if (error) {
      console.error('Error fetching payments:', error)
      toast.error('Failed to fetch payments')
    } else {
      setPayments(data as PaymentWithDetails[] || [])
      setTotalCount(count || 0)
    }

    setIsLoading(false)
  }, [currentPage, searchQuery, statusFilter])

  useEffect(() => {
    fetchPayments()
    fetchStats()
  }, [fetchPayments, fetchStats])

  const handleApprove = async () => {
    if (!selectedPayment || !profile) return
    setIsSubmitting(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      toast.error('Database connection not available')
      setIsSubmitting(false)
      return
    }

    try {
      // FIFO Payment Application Process (matching Flutter implementation)

      // 1. Get payment details
      const paymentId = selectedPayment.id
      const userId = selectedPayment.user_id
      let remainingAmount = selectedPayment.amount

      // 2. Get unpaid and partially_paid penalties ordered by date (FIFO - oldest first)
      const { data: penalties, error: penaltiesError } = await supabase
        .from('penalties')
        .select('id, amount, paid_amount, status, date_incurred')
        .eq('user_id', userId)
        .in('status', ['unpaid', 'partially_paid'])
        .order('date_incurred', { ascending: true })

      if (penaltiesError) {
        throw new Error(`Failed to fetch penalties: ${penaltiesError.message}`)
      }

      // 3. Apply payment to penalties using FIFO
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      for (const penalty of (penalties || []) as any[]) {
        if (remainingAmount <= 0) break

        const penaltyAmount = penalty.amount
        const paidAmount = penalty.paid_amount || 0
        const penaltyRemaining = penaltyAmount - paidAmount

        // Calculate how much to apply to this penalty
        const amountToApply = Math.min(remainingAmount, penaltyRemaining)

        // Create penalty_payment junction record
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error: junctionError } = await (supabase as any)
          .from('penalty_payments')
          .insert({
            payment_id: paymentId,
            penalty_id: penalty.id,
            amount_applied: amountToApply,
          })

        if (junctionError) {
          throw new Error(`Failed to create penalty payment link: ${junctionError.message}`)
        }

        // Update penalty with new paid amount and status
        const newPaidAmount = paidAmount + amountToApply
        let newStatus: string
        if (newPaidAmount >= penaltyAmount) {
          newStatus = 'paid'
        } else if (newPaidAmount > 0) {
          newStatus = 'partially_paid'
        } else {
          newStatus = 'unpaid'
        }

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error: updateError } = await (supabase as any)
          .from('penalties')
          .update({
            paid_amount: newPaidAmount,
            status: newStatus,
          })
          .eq('id', penalty.id)

        if (updateError) {
          throw new Error(`Failed to update penalty: ${updateError.message}`)
        }

        remainingAmount -= amountToApply
      }

      // 4. Update payment status to approved
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { error: paymentError } = await (supabase as any)
        .from('payments')
        .update({
          status: 'approved',
          reviewed_by: profile.id,
          reviewed_at: new Date().toISOString(),
        })
        .eq('id', paymentId)

      if (paymentError) {
        throw new Error(`Failed to update payment status: ${paymentError.message}`)
      }

      // 5. Recalculate user statistics (current_penalty_balance)
      // Get all penalties for the user
      const { data: allPenalties } = await supabase
        .from('penalties')
        .select('amount, paid_amount')
        .eq('user_id', userId)

      if (allPenalties) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const totalIncurred = (allPenalties as any[]).reduce((sum, p) => sum + (p.amount || 0), 0)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const totalPaid = (allPenalties as any[]).reduce((sum, p) => sum + (p.paid_amount || 0), 0)
        const currentBalance = totalIncurred - totalPaid

        // Update user_statistics
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        await (supabase as any)
          .from('user_statistics')
          .update({
            total_penalties_paid: totalPaid,
            current_penalty_balance: currentBalance,
            updated_at: new Date().toISOString(),
          })
          .eq('user_id', userId)
      }

      // 6. Log audit trail
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await (supabase as any).from('audit_logs').insert({
        action_type: 'payment_approved',
        performed_by: profile.id,
        user_id: userId,
        entity_type: 'payment',
        entity_id: paymentId,
        reason: 'Payment approved and applied to penalties using FIFO',
        description: `Payment of ${selectedPayment.amount} SOS approved and applied to penalties`,
      })

      toast.success('Payment approved and applied to penalties successfully')
      fetchPayments()
      fetchStats()
    } catch (error) {
      console.error('Error approving payment:', error)
      toast.error(error instanceof Error ? error.message : 'Failed to approve payment')
    } finally {
      setIsSubmitting(false)
      setDialogType(null)
      setSelectedPayment(null)
    }
  }

  const handleReject = async () => {
    if (!selectedPayment || !profile || !rejectionReason.trim()) {
      toast.error('Please provide a rejection reason')
      return
    }
    setIsSubmitting(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      toast.error('Database connection not available')
      setIsSubmitting(false)
      return
    }

    try {
      const paymentId = selectedPayment.id
      const userId = selectedPayment.user_id

      // Update payment status to rejected
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { error: paymentError } = await (supabase as any)
        .from('payments')
        .update({
          status: 'rejected',
          reviewed_by: profile.id,
          reviewed_at: new Date().toISOString(),
          rejection_reason: rejectionReason.trim(),
        })
        .eq('id', paymentId)

      if (paymentError) {
        throw new Error(`Failed to reject payment: ${paymentError.message}`)
      }

      // Log audit trail
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await (supabase as any).from('audit_logs').insert({
        action_type: 'payment_rejected',
        performed_by: profile.id,
        user_id: userId,
        entity_type: 'payment',
        entity_id: paymentId,
        reason: rejectionReason.trim(),
        description: `Payment of ${selectedPayment.amount} SOS rejected`,
      })

      toast.success('Payment rejected')
      fetchPayments()
      fetchStats()
    } catch (error) {
      console.error('Error rejecting payment:', error)
      toast.error(error instanceof Error ? error.message : 'Failed to reject payment')
    } finally {
      setIsSubmitting(false)
      setDialogType(null)
      setSelectedPayment(null)
      setRejectionReason('')
    }
  }

  const getStatusBadge = (status: PaymentStatus) => {
    const config = {
      pending: { variant: 'secondary' as const, icon: Clock, label: 'Pending' },
      approved: { variant: 'default' as const, icon: CheckCircle2, label: 'Approved' },
      rejected: { variant: 'destructive' as const, icon: XCircle, label: 'Rejected' },
    }

    const { variant, icon: Icon, label } = config[status]

    return (
      <Badge variant={variant} className="gap-1">
        <Icon className="h-3 w-3" />
        {label}
      </Badge>
    )
  }

  const totalPages = Math.ceil(totalCount / PAGE_SIZE)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Payment Review</h1>
          <p className="text-muted-foreground">
            Review and approve payment submissions
          </p>
        </div>
        <Button onClick={() => { fetchPayments(); fetchStats() }} variant="outline" size="sm">
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh
        </Button>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Payments</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.pendingCount}</div>
            <p className="text-xs text-muted-foreground">
              {stats.pendingAmount.toLocaleString()} SOS total
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Approved This Month</CardTitle>
            <CheckCircle2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.approvedCount}</div>
            <p className="text-xs text-muted-foreground">
              {stats.approvedAmount.toLocaleString()} SOS total
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by reference number..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value)
                  setCurrentPage(1)
                }}
                className="pl-9"
              />
            </div>
            <Select
              value={statusFilter}
              onValueChange={(value) => {
                setStatusFilter(value)
                setCurrentPage(1)
              }}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="approved">Approved</SelectItem>
                <SelectItem value="rejected">Rejected</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Payments Table */}
      <Card>
        <CardHeader>
          <CardTitle>Payments ({totalCount})</CardTitle>
          <CardDescription>
            Review and process payment submissions
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Method</TableHead>
                <TableHead>Reference</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i}>
                    <TableCell><Skeleton className="h-4 w-32" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-20" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-16" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                    <TableCell><Skeleton className="h-5 w-20" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                    <TableCell><Skeleton className="h-8 w-20 ml-auto" /></TableCell>
                  </TableRow>
                ))
              ) : payments.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    No payments found
                  </TableCell>
                </TableRow>
              ) : (
                payments.map((payment) => (
                  <TableRow key={payment.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{payment.user?.name}</div>
                        <div className="text-sm text-muted-foreground">{payment.user?.email}</div>
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">
                      {payment.amount.toLocaleString()} SOS
                    </TableCell>
                    <TableCell>{payment.payment_method || 'Unknown'}</TableCell>
                    <TableCell className="font-mono text-sm">
                      {payment.reference_number || '-'}
                    </TableCell>
                    <TableCell>{getStatusBadge(payment.status)}</TableCell>
                    <TableCell>
                      {new Date(payment.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-right">
                      {payment.status === 'pending' && (
                        <div className="flex justify-end gap-2">
                          <Button
                            size="sm"
                            variant="default"
                            onClick={() => {
                              setSelectedPayment(payment)
                              setDialogType('approve')
                            }}
                          >
                            <CheckCircle2 className="h-4 w-4 mr-1" />
                            Approve
                          </Button>
                          <Button
                            size="sm"
                            variant="destructive"
                            onClick={() => {
                              setSelectedPayment(payment)
                              setDialogType('reject')
                            }}
                          >
                            <XCircle className="h-4 w-4 mr-1" />
                            Reject
                          </Button>
                        </div>
                      )}
                      {payment.status === 'rejected' && payment.rejection_reason && (
                        <span className="text-sm text-muted-foreground">
                          {payment.rejection_reason}
                        </span>
                      )}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between mt-4">
              <p className="text-sm text-muted-foreground">
                Showing {(currentPage - 1) * PAGE_SIZE + 1} to{' '}
                {Math.min(currentPage * PAGE_SIZE, totalCount)} of {totalCount}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <span className="text-sm">
                  Page {currentPage} of {totalPages}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                >
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Approve Dialog */}
      <Dialog open={dialogType === 'approve'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Approve Payment</DialogTitle>
            <DialogDescription>
              Confirm approval of this payment submission
            </DialogDescription>
          </DialogHeader>
          {selectedPayment && (
            <div className="space-y-4 py-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="text-muted-foreground">User:</span>
                  <p className="font-medium">{selectedPayment.user?.name}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Amount:</span>
                  <p className="font-medium">{selectedPayment.amount.toLocaleString()} SOS</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Method:</span>
                  <p className="font-medium">{selectedPayment.payment_method}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Reference:</span>
                  <p className="font-medium font-mono">{selectedPayment.reference_number}</p>
                </div>
              </div>
              <div className="p-3 bg-muted rounded-lg">
                <p className="text-sm">
                  <strong>Current Balance:</strong> {selectedPayment.user?.user_statistics?.current_penalty_balance?.toLocaleString() || 0} SOS
                </p>
                <p className="text-sm">
                  <strong>After Approval:</strong>{' '}
                  {Math.max(0, (selectedPayment.user?.user_statistics?.current_penalty_balance || 0) - selectedPayment.amount).toLocaleString()} SOS
                </p>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogType(null)}>
              Cancel
            </Button>
            <Button onClick={handleApprove} disabled={isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Approve Payment
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={dialogType === 'reject'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Payment</DialogTitle>
            <DialogDescription>
              Provide a reason for rejecting this payment
            </DialogDescription>
          </DialogHeader>
          <div className="py-4 space-y-4">
            <div className="space-y-2">
              <Label>Rejection Reason</Label>
              <Textarea
                placeholder="Enter reason for rejection..."
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                rows={3}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogType(null)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleReject}
              disabled={isSubmitting || !rejectionReason}
            >
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Reject Payment
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
