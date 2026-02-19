'use client'

import { useEffect, useState } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuth } from '@/lib/contexts/auth-context'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import {
  FileText,
  Search,
  Calendar,
  Eye,
  Edit,
  Download,
  Filter,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react'
import { Textarea } from '@/components/ui/textarea'

interface Report {
  id: string
  user_id: string
  report_date: string
  total_deeds: number
  sunnah_count: number
  faraid_count: number
  status: string
  submitted_at: string
  user: {
    name: string
    email: string
    user_statistics: {
      current_penalty_balance: number
    }
  }
}

interface DeedEntry {
  id: string
  deed_value: number
  deed_template: {
    deed_name: string
    category: string
    value_type: string
  }
}

interface UserSummary {
  user_id: string
  user_name: string
  user_email: string
  total_reports: number
  total_deeds: number
  average_deeds: number
  compliance_percentage: number
  current_penalty_balance: number
  expected_reports: number
}

export default function ReportsManagementPage() {
  const { profile } = useAuth()

  const [reports, setReports] = useState<Report[]>([])
  const [userSummaries, setUserSummaries] = useState<UserSummary[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isSummaryLoading, setIsSummaryLoading] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const reportsPerPage = 20
  const [activeTab, setActiveTab] = useState('reports')

  // View/Edit Dialog
  const [selectedReport, setSelectedReport] = useState<Report | null>(null)
  const [deedEntries, setDeedEntries] = useState<DeedEntry[]>([])
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isEditMode, setIsEditMode] = useState(false)
  const [editReason, setEditReason] = useState('')
  const [editedValues, setEditedValues] = useState<Record<string, number>>({})

  const isAdmin = profile?.role === 'admin'

  useEffect(() => {
    fetchReports()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPage, statusFilter, searchQuery, startDate, endDate])

  useEffect(() => {
    if (activeTab === 'summary') {
      fetchUserSummaries()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab, searchQuery, startDate, endDate])

  const fetchReports = async () => {
    setIsLoading(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      setIsLoading(false)
      return
    }

    try {
      let query = supabase
        .from('deeds_reports')
        .select(
          `
          id,
          user_id,
          report_date,
          total_deeds,
          sunnah_count,
          faraid_count,
          status,
          submitted_at,
          user:users!inner(
            name,
            email,
            user_statistics(current_penalty_balance)
          )
        `,
          { count: 'exact' }
        )
        .order('report_date', { ascending: false })
        .range((currentPage - 1) * reportsPerPage, currentPage * reportsPerPage - 1)

      // Apply filters
      if (statusFilter !== 'all') {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        query = (query as any).eq('status', statusFilter)
      }

      if (searchQuery) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        query = (query as any).or(
          `user.name.ilike.%${searchQuery}%,user.email.ilike.%${searchQuery}%`
        )
      }

      if (startDate) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        query = (query as any).gte('report_date', startDate)
      }

      if (endDate) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        query = (query as any).lte('report_date', endDate)
      }

      const { data, error, count } = await query

      if (error) throw error

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setReports((data || []) as any)
      setTotalPages(Math.ceil((count || 0) / reportsPerPage))
    } catch (error) {
      console.error('Error fetching reports:', error)
      toast.error('Failed to load reports')
    } finally {
      setIsLoading(false)
    }
  }

  const fetchUserSummaries = async () => {
    setIsSummaryLoading(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      setIsSummaryLoading(false)
      return
    }

    try {
      // Calculate date range for expected reports
      let dateRangeStart = startDate
      let dateRangeEnd = endDate || new Date().toISOString().split('T')[0]

      // If no date range specified, use last 30 days
      if (!startDate && !endDate) {
        const thirtyDaysAgo = new Date()
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
        dateRangeStart = thirtyDaysAgo.toISOString().split('T')[0]
      }

      // Calculate expected number of reports in date range
      const start = new Date(dateRangeStart || new Date())
      const end = new Date(dateRangeEnd)
      const daysDiff = Math.floor((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1
      const expectedReports = daysDiff > 0 ? daysDiff : 1

      // Fetch all reports with date filter
      let reportsQuery = supabase
        .from('deeds_reports')
        .select(`
          user_id,
          total_deeds,
          user:users!inner(
            id,
            name,
            email,
            user_statistics(current_penalty_balance)
          )
        `)
        .eq('status', 'submitted')

      if (dateRangeStart) {
        reportsQuery = reportsQuery.gte('report_date', dateRangeStart)
      }
      if (dateRangeEnd) {
        reportsQuery = reportsQuery.lte('report_date', dateRangeEnd)
      }

      if (searchQuery) {
        reportsQuery = reportsQuery.or(
          `user.name.ilike.%${searchQuery}%,user.email.ilike.%${searchQuery}%`
        )
      }

      const { data: reportsData, error: reportsError } = await reportsQuery

      if (reportsError) throw reportsError

      // Group by user and calculate statistics
      const userMap = new Map<string, UserSummary>()

      reportsData?.forEach((report: any) => {
        const userId = report.user_id
        const user = report.user

        if (!userMap.has(userId)) {
          userMap.set(userId, {
            user_id: userId,
            user_name: user.name,
            user_email: user.email,
            total_reports: 0,
            total_deeds: 0,
            average_deeds: 0,
            compliance_percentage: 0,
            current_penalty_balance: user.user_statistics?.current_penalty_balance || 0,
            expected_reports: expectedReports,
          })
        }

        const summary = userMap.get(userId)!
        summary.total_reports += 1
        summary.total_deeds += report.total_deeds || 0
      })

      // Calculate averages and compliance
      const summaries: UserSummary[] = Array.from(userMap.values()).map(summary => ({
        ...summary,
        average_deeds: summary.total_reports > 0
          ? Math.round((summary.total_deeds / summary.total_reports) * 10) / 10
          : 0,
        compliance_percentage: Math.round((summary.total_reports / expectedReports) * 100),
      }))

      // Sort by compliance (worst first)
      summaries.sort((a, b) => a.compliance_percentage - b.compliance_percentage)

      setUserSummaries(summaries)
    } catch (error) {
      console.error('Error fetching user summaries:', error)
      toast.error('Failed to load user summaries')
    } finally {
      setIsSummaryLoading(false)
    }
  }

  const fetchReportDetails = async (reportId: string) => {
    const supabase = getSupabaseClient()
    if (!supabase) return

    try {
      const { data, error } = await supabase
        .from('deed_entries')
        .select(
          `
          id,
          deed_value,
          deed_template_id,
          deed_template:deed_templates(deed_name, category, value_type, sort_order)
        `
        )
        .eq('report_id', reportId)
        .order('deed_template_id', { ascending: true })

      if (error) throw error

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setDeedEntries((data || []) as any)

      // Initialize edited values
      const initialValues: Record<string, number> = {}
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ;(data || []).forEach((entry: any) => {
        initialValues[entry.id] = entry.deed_value
      })
      setEditedValues(initialValues)
    } catch (error) {
      console.error('Error fetching report details:', error)
      toast.error('Failed to load report details')
    }
  }

  const handleViewReport = async (report: Report) => {
    setSelectedReport(report)
    await fetchReportDetails(report.id)
    setIsViewDialogOpen(true)
    setIsEditMode(false)
    setEditReason('')
  }

  const handleEditReport = () => {
    if (!isAdmin) {
      toast.error('Only admins can edit reports')
      return
    }
    setIsEditMode(true)
  }

  const handleSaveEdit = async () => {
    if (!selectedReport || !isAdmin) return

    if (!editReason.trim()) {
      toast.error('Please provide a reason for editing this report')
      return
    }

    const supabase = getSupabaseClient()
    if (!supabase) {
      toast.error('Database connection not available')
      return
    }

    try {
      // Update deed entries
      for (const [entryId, newValue] of Object.entries(editedValues)) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error } = await (supabase as any)
          .from('deed_entries')
          .update({ deed_value: newValue })
          .eq('id', entryId)

        if (error) throw error
      }

      // Recalculate totals
      let newTotal = 0
      let newSunnah = 0
      let newFaraid = 0

      deedEntries.forEach((entry) => {
        const value = editedValues[entry.id] || 0
        newTotal += value
        if (entry.deed_template.category === 'sunnah') {
          newSunnah += value
        } else {
          newFaraid += value
        }
      })

      // Update report
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { error: updateError } = await (supabase as any)
        .from('deeds_reports')
        .update({
          total_deeds: newTotal,
          sunnah_count: newSunnah,
          faraid_count: newFaraid,
        })
        .eq('id', selectedReport.id)

      if (updateError) throw updateError

      // Log audit entry
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await (supabase as any).from('audit_logs').insert({
        action: 'report_edited',
        performed_by: profile?.id,
        user_affected: selectedReport.user_id,
        details: {
          report_id: selectedReport.id,
          report_date: selectedReport.report_date,
          reason: editReason,
          old_values: deedEntries.map((e) => ({ id: e.id, value: e.deed_value })),
          new_values: Object.entries(editedValues).map(([id, value]) => ({ id, value })),
        },
      })

      toast.success('Report updated successfully')
      setIsViewDialogOpen(false)
      setIsEditMode(false)
      fetchReports()
    } catch (error) {
      console.error('Error updating report:', error)
      toast.error('Failed to update report')
    }
  }

  const handleExport = () => {
    if (activeTab === 'reports') {
      // Export daily reports
      const csv = [
        ['Date', 'User', 'Total Deeds', 'Fara\'id', 'Sunnah', 'Unpaid Penalty (SOS)', 'Status', 'Submitted At'],
        ...reports.map((r) => [
          r.report_date,
          r.user.name,
          r.total_deeds,
          r.faraid_count,
          r.sunnah_count,
          r.user?.user_statistics?.current_penalty_balance || 0,
          r.status,
          r.submitted_at || 'N/A',
        ]),
      ]
        .map((row) => row.join(','))
        .join('\n')

      const blob = new Blob([csv], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `reports-${new Date().toISOString().split('T')[0]}.csv`
      a.click()
      window.URL.revokeObjectURL(url)

      toast.success('Reports exported successfully')
    } else {
      // Export user summary
      const csv = [
        ['User Name', 'Email', 'Reports Submitted', 'Expected Reports', 'Total Deeds', 'Avg Deeds/Day', 'Compliance %', 'Unpaid Penalty (SOS)'],
        ...userSummaries.map((s) => [
          s.user_name,
          s.user_email,
          s.total_reports,
          s.expected_reports,
          s.total_deeds,
          s.average_deeds,
          s.compliance_percentage,
          s.current_penalty_balance,
        ]),
      ]
        .map((row) => row.join(','))
        .join('\n')

      const blob = new Blob([csv], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `user-summary-${new Date().toISOString().split('T')[0]}.csv`
      a.click()
      window.URL.revokeObjectURL(url)

      toast.success('User summary exported successfully')
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Reports Management</h1>
          <p className="text-muted-foreground mt-1">
            View and manage user daily deed reports
          </p>
        </div>
        <Button onClick={handleExport} variant="outline">
          <Download className="mr-2 h-4 w-4" />
          Export {activeTab === 'reports' ? 'Reports' : 'Summary'}
        </Button>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList>
          <TabsTrigger value="reports">Daily Reports</TabsTrigger>
          <TabsTrigger value="summary">User Summary</TabsTrigger>
        </TabsList>

        <TabsContent value="reports" className="space-y-6">
          {/* Filters */}
          <Card>
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <Filter className="h-5 w-5" />
            Filters
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Search */}
            <div className="space-y-2">
              <Label>Search User</Label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Name or email..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>

            {/* Status Filter */}
            <div className="space-y-2">
              <Label>Status</Label>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="draft">Draft</SelectItem>
                  <SelectItem value="submitted">Submitted</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Start Date */}
            <div className="space-y-2">
              <Label>From Date</Label>
              <Input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
              />
            </div>

            {/* End Date */}
            <div className="space-y-2">
              <Label>To Date</Label>
              <Input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Reports Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Daily Reports
          </CardTitle>
          <CardDescription>
            {reports.length} report(s) found
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-12 w-full" />
              ))}
            </div>
          ) : reports.length === 0 ? (
            <div className="text-center py-12 text-muted-foreground">
              <FileText className="mx-auto h-12 w-12 mb-3 opacity-50" />
              <p>No reports found</p>
            </div>
          ) : (
            <>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>User</TableHead>
                      <TableHead>Total</TableHead>
                      <TableHead>Fara&apos;id</TableHead>
                      <TableHead>Sunnah</TableHead>
                      <TableHead>Unpaid Penalty</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Submitted</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {reports.map((report) => (
                      <TableRow key={report.id}>
                        <TableCell className="font-medium">
                          <div className="flex items-center gap-2">
                            <Calendar className="h-4 w-4 text-muted-foreground" />
                            {new Date(report.report_date).toLocaleDateString()}
                          </div>
                        </TableCell>
                        <TableCell>
                          <div>
                            <p className="font-medium">{report.user.name}</p>
                            <p className="text-sm text-muted-foreground">{report.user.email}</p>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant={report.total_deeds >= 10 ? 'default' : 'destructive'}>
                            {report.total_deeds}/10
                          </Badge>
                        </TableCell>
                        <TableCell>{report.faraid_count}/5</TableCell>
                        <TableCell>{report.sunnah_count}/5</TableCell>
                        <TableCell>
                          <Badge variant={
                            (report.user?.user_statistics?.current_penalty_balance || 0) > 0
                              ? 'destructive'
                              : 'secondary'
                          }>
                            {(report.user?.user_statistics?.current_penalty_balance || 0).toLocaleString()} SOS
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge variant={report.status === 'submitted' ? 'default' : 'secondary'}>
                            {report.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-sm text-muted-foreground">
                          {report.submitted_at
                            ? new Date(report.submitted_at).toLocaleString()
                            : 'N/A'}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex items-center justify-end gap-2">
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => handleViewReport(report)}
                            >
                              <Eye className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>

              {/* Pagination */}
              <div className="flex items-center justify-between mt-4">
                <p className="text-sm text-muted-foreground">
                  Page {currentPage} of {totalPages}
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
            </>
          )}
        </CardContent>
      </Card>
        </TabsContent>

        <TabsContent value="summary" className="space-y-6">
          {/* Filters - Same as reports tab but without status filter */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <Filter className="h-5 w-5" />
                Filters
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* Search */}
                <div className="space-y-2">
                  <Label>Search User</Label>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Name or email..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-9"
                    />
                  </div>
                </div>

                {/* Start Date */}
                <div className="space-y-2">
                  <Label>From Date</Label>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                  />
                </div>

                {/* End Date */}
                <div className="space-y-2">
                  <Label>To Date</Label>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* User Summary Table */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                User Summary Report
              </CardTitle>
              <CardDescription>
                {userSummaries.length} user(s) found
              </CardDescription>
            </CardHeader>
            <CardContent>
              {isSummaryLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Skeleton key={i} className="h-12 w-full" />
                  ))}
                </div>
              ) : userSummaries.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <FileText className="mx-auto h-12 w-12 mb-3 opacity-50" />
                  <p>No user data found for the selected date range</p>
                </div>
              ) : (
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>User</TableHead>
                        <TableHead className="text-right">Reports Submitted</TableHead>
                        <TableHead className="text-right">Total Deeds</TableHead>
                        <TableHead className="text-right">Avg Deeds/Day</TableHead>
                        <TableHead className="text-right">Compliance %</TableHead>
                        <TableHead className="text-right">Unpaid Penalty</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {userSummaries.map((summary) => (
                        <TableRow key={summary.user_id}>
                          <TableCell>
                            <div>
                              <p className="font-medium">{summary.user_name}</p>
                              <p className="text-sm text-muted-foreground">{summary.user_email}</p>
                            </div>
                          </TableCell>
                          <TableCell className="text-right">
                            <Badge variant="outline">
                              {summary.total_reports}/{summary.expected_reports}
                            </Badge>
                          </TableCell>
                          <TableCell className="text-right font-medium">
                            {summary.total_deeds}
                          </TableCell>
                          <TableCell className="text-right">
                            <Badge variant={summary.average_deeds >= 10 ? 'default' : 'secondary'}>
                              {summary.average_deeds}
                            </Badge>
                          </TableCell>
                          <TableCell className="text-right">
                            <Badge
                              variant={
                                summary.compliance_percentage >= 90
                                  ? 'default'
                                  : summary.compliance_percentage >= 70
                                  ? 'secondary'
                                  : 'destructive'
                              }
                            >
                              {summary.compliance_percentage}%
                            </Badge>
                          </TableCell>
                          <TableCell className="text-right">
                            <Badge
                              variant={
                                summary.current_penalty_balance > 0 ? 'destructive' : 'secondary'
                              }
                            >
                              {summary.current_penalty_balance.toLocaleString()} SOS
                            </Badge>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* View/Edit Report Dialog */}
      <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditMode ? 'Edit Report' : 'View Report Details'}
            </DialogTitle>
            <DialogDescription>
              {selectedReport &&
                `Report for ${selectedReport.user.name} on ${new Date(
                  selectedReport.report_date
                ).toLocaleDateString()}`}
            </DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="space-y-6">
              {/* Summary */}
              <div className="grid grid-cols-3 gap-4">
                <Card>
                  <CardHeader className="pb-3">
                    <CardDescription>Total Deeds</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">{selectedReport.total_deeds}/10</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-3">
                    <CardDescription>Fara&apos;id</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">{selectedReport.faraid_count}/5</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-3">
                    <CardDescription>Sunnah</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">{selectedReport.sunnah_count}/5</p>
                  </CardContent>
                </Card>
              </div>

              {/* Deed Entries */}
              <div>
                <h3 className="font-semibold mb-3">Deed Breakdown</h3>
                <div className="space-y-2">
                  {deedEntries.map((entry) => (
                    <div
                      key={entry.id}
                      className="flex items-center justify-between p-3 border rounded-lg"
                    >
                      <div className="flex items-center gap-3">
                        <Badge variant={entry.deed_template.category === 'faraid' ? 'default' : 'secondary'}>
                          {entry.deed_template.category}
                        </Badge>
                        <span className="font-medium">{entry.deed_template.deed_name}</span>
                      </div>
                      {isEditMode ? (
                        <Input
                          type="number"
                          min="0"
                          max="1"
                          step={entry.deed_template.value_type === 'fractional' ? '0.1' : '1'}
                          value={editedValues[entry.id] || 0}
                          onChange={(e) =>
                            setEditedValues({
                              ...editedValues,
                              [entry.id]: parseFloat(e.target.value) || 0,
                            })
                          }
                          className="w-24"
                        />
                      ) : (
                        <span className="font-bold">{entry.deed_value}</span>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              {/* Edit Reason */}
              {isEditMode && (
                <div className="space-y-2">
                  <Label>Reason for Edit (Required)</Label>
                  <Textarea
                    placeholder="Enter reason for editing this report..."
                    value={editReason}
                    onChange={(e) => setEditReason(e.target.value)}
                    rows={3}
                  />
                </div>
              )}
            </div>
          )}

          <DialogFooter>
            {!isEditMode ? (
              <>
                <Button variant="outline" onClick={() => setIsViewDialogOpen(false)}>
                  Close
                </Button>
                {isAdmin && (
                  <Button onClick={handleEditReport}>
                    <Edit className="mr-2 h-4 w-4" />
                    Edit Report
                  </Button>
                )}
              </>
            ) : (
              <>
                <Button
                  variant="outline"
                  onClick={() => {
                    setIsEditMode(false)
                    setEditReason('')
                  }}
                >
                  Cancel
                </Button>
                <Button onClick={handleSaveEdit}>Save Changes</Button>
              </>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
