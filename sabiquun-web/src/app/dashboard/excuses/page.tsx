'use client'

import { useEffect, useState, useCallback } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuth } from '@/lib/contexts/auth-context'
import type { ExcuseWithDetails, ExcuseStatus, ExcuseType } from '@/lib/types/database'
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
  AlertCircle,
  Thermometer,
  Plane,
  CloudRain,
} from 'lucide-react'

const PAGE_SIZE = 10

export default function ExcusesPage() {
  const { profile } = useAuth()
  const [excuses, setExcuses] = useState<ExcuseWithDetails[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>('pending')
  const [typeFilter, setTypeFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalCount, setTotalCount] = useState(0)

  // Dialog states
  const [selectedExcuse, setSelectedExcuse] = useState<ExcuseWithDetails | null>(null)
  const [dialogType, setDialogType] = useState<'view' | 'reject' | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const supabase = getSupabaseClient()

  const fetchExcuses = useCallback(async () => {
    setIsLoading(true)

    let query = supabase
      .from('excuses')
      .select(`
        *,
        user:users!excuses_user_id_fkey(id, name, email)
      `, { count: 'exact' })
      .order('created_at', { ascending: false })
      .range((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE - 1)

    if (statusFilter !== 'all') {
      query = query.eq('status', statusFilter)
    }

    if (typeFilter !== 'all') {
      query = query.eq('excuse_type', typeFilter)
    }

    const { data, count, error } = await query

    if (error) {
      console.error('Error fetching excuses:', error)
      toast.error('Failed to fetch excuses')
    } else {
      setExcuses(data as ExcuseWithDetails[] || [])
      setTotalCount(count || 0)
    }

    setIsLoading(false)
  }, [supabase, currentPage, statusFilter, typeFilter])

  useEffect(() => {
    fetchExcuses()
  }, [fetchExcuses])

  const handleApprove = async (excuse: ExcuseWithDetails) => {
    if (!profile) return
    setIsSubmitting(true)

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error } = await (supabase as any)
      .from('excuses')
      .update({
        status: 'approved',
        reviewed_by: profile.id,
        reviewed_at: new Date().toISOString(),
      })
      .eq('id', excuse.id)

    if (error) {
      toast.error('Failed to approve excuse')
    } else {
      toast.success('Excuse approved successfully')
      fetchExcuses()
    }

    setIsSubmitting(false)
  }

  const handleReject = async () => {
    if (!selectedExcuse || !profile || !rejectionReason) return
    setIsSubmitting(true)

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error } = await (supabase as any)
      .from('excuses')
      .update({
        status: 'rejected',
        reviewed_by: profile.id,
        reviewed_at: new Date().toISOString(),
        rejection_reason: rejectionReason,
      })
      .eq('id', selectedExcuse.id)

    if (error) {
      toast.error('Failed to reject excuse')
    } else {
      toast.success('Excuse rejected')
      fetchExcuses()
    }

    setIsSubmitting(false)
    setDialogType(null)
    setSelectedExcuse(null)
    setRejectionReason('')
  }

  const getStatusBadge = (status: ExcuseStatus) => {
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

  const getTypeBadge = (type: ExcuseType) => {
    const config = {
      sickness: { icon: Thermometer, label: 'Sickness', color: 'bg-red-100 text-red-700' },
      travel: { icon: Plane, label: 'Travel', color: 'bg-blue-100 text-blue-700' },
      raining: { icon: CloudRain, label: 'Raining', color: 'bg-gray-100 text-gray-700' },
    }

    const { icon: Icon, label, color } = config[type]

    return (
      <Badge variant="outline" className={`gap-1 ${color}`}>
        <Icon className="h-3 w-3" />
        {label}
      </Badge>
    )
  }

  const formatDateRange = (start: string, end: string) => {
    const startDate = new Date(start).toLocaleDateString()
    const endDate = new Date(end).toLocaleDateString()
    return startDate === endDate ? startDate : `${startDate} - ${endDate}`
  }

  const totalPages = Math.ceil(totalCount / PAGE_SIZE)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Excuse Management</h1>
          <p className="text-muted-foreground">
            Review and approve excuse requests from users
          </p>
        </div>
        <Button onClick={fetchExcuses} variant="outline" size="sm">
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
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
            <Select
              value={typeFilter}
              onValueChange={(value) => {
                setTypeFilter(value)
                setCurrentPage(1)
              }}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="sickness">Sickness</SelectItem>
                <SelectItem value="travel">Travel</SelectItem>
                <SelectItem value="raining">Raining</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Excuses Table */}
      <Card>
        <CardHeader>
          <CardTitle>Excuses ({totalCount})</CardTitle>
          <CardDescription>
            Review and process excuse requests
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Date Range</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Submitted</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i}>
                    <TableCell><Skeleton className="h-4 w-32" /></TableCell>
                    <TableCell><Skeleton className="h-5 w-20" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-32" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-40" /></TableCell>
                    <TableCell><Skeleton className="h-5 w-20" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                    <TableCell><Skeleton className="h-8 w-20 ml-auto" /></TableCell>
                  </TableRow>
                ))
              ) : excuses.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    <AlertCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>No excuses found</p>
                  </TableCell>
                </TableRow>
              ) : (
                excuses.map((excuse) => (
                  <TableRow key={excuse.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{excuse.user?.name}</div>
                        <div className="text-sm text-muted-foreground">{excuse.user?.email}</div>
                      </div>
                    </TableCell>
                    <TableCell>{getTypeBadge(excuse.excuse_type)}</TableCell>
                    <TableCell>
                      {formatDateRange(excuse.start_date, excuse.end_date)}
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate">
                      {excuse.reason || '-'}
                    </TableCell>
                    <TableCell>{getStatusBadge(excuse.status)}</TableCell>
                    <TableCell>
                      {new Date(excuse.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-right">
                      {excuse.status === 'pending' ? (
                        <div className="flex justify-end gap-2">
                          <Button
                            size="sm"
                            variant="default"
                            onClick={() => handleApprove(excuse)}
                            disabled={isSubmitting}
                          >
                            <CheckCircle2 className="h-4 w-4 mr-1" />
                            Approve
                          </Button>
                          <Button
                            size="sm"
                            variant="destructive"
                            onClick={() => {
                              setSelectedExcuse(excuse)
                              setDialogType('reject')
                            }}
                          >
                            <XCircle className="h-4 w-4 mr-1" />
                            Reject
                          </Button>
                        </div>
                      ) : (
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => {
                            setSelectedExcuse(excuse)
                            setDialogType('view')
                          }}
                        >
                          View
                        </Button>
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

      {/* View Dialog */}
      <Dialog open={dialogType === 'view'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Excuse Details</DialogTitle>
          </DialogHeader>
          {selectedExcuse && (
            <div className="space-y-4 py-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="text-muted-foreground">User:</span>
                  <p className="font-medium">{selectedExcuse.user?.name}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Type:</span>
                  <div className="mt-1">{getTypeBadge(selectedExcuse.excuse_type)}</div>
                </div>
                <div>
                  <span className="text-muted-foreground">Date Range:</span>
                  <p className="font-medium">
                    {formatDateRange(selectedExcuse.start_date, selectedExcuse.end_date)}
                  </p>
                </div>
                <div>
                  <span className="text-muted-foreground">Status:</span>
                  <div className="mt-1">{getStatusBadge(selectedExcuse.status)}</div>
                </div>
              </div>
              {selectedExcuse.reason && (
                <div>
                  <span className="text-sm text-muted-foreground">Reason:</span>
                  <p className="mt-1">{selectedExcuse.reason}</p>
                </div>
              )}
              {selectedExcuse.rejection_reason && (
                <div className="p-3 bg-destructive/10 rounded-lg">
                  <span className="text-sm font-medium text-destructive">Rejection Reason:</span>
                  <p className="mt-1 text-sm">{selectedExcuse.rejection_reason}</p>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogType(null)}>
              Close
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={dialogType === 'reject'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Excuse</DialogTitle>
            <DialogDescription>
              Provide a reason for rejecting this excuse request
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
              Reject Excuse
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
