'use client'

import { useEffect, useState, useCallback } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { User, UserRole, AccountStatus } from '@/lib/types/database'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
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
  MoreHorizontal,
  UserCheck,
  UserX,
  Shield,
  RefreshCw,
  Loader2,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react'

const PAGE_SIZE = 10

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [roleFilter, setRoleFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalCount, setTotalCount] = useState(0)

  // Dialog states
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [dialogType, setDialogType] = useState<'role' | 'status' | null>(null)
  const [newRole, setNewRole] = useState<UserRole>('user')
  const [newStatus, setNewStatus] = useState<AccountStatus>('active')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const fetchUsers = useCallback(async () => {
    const supabase = getSupabaseClient()
    if (!supabase) {
      console.error('❌ Users - Supabase client not available')
      setIsLoading(false)
      return
    }

    setIsLoading(true)

    try {
      let query = supabase
        .from('users')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE - 1)

      if (searchQuery) {
        query = query.or(`name.ilike.%${searchQuery}%,email.ilike.%${searchQuery}%`)
      }

      if (statusFilter !== 'all') {
        query = query.eq('account_status', statusFilter)
      }

      if (roleFilter !== 'all') {
        query = query.eq('role', roleFilter)
      }

      const { data: usersData, count, error } = await query

      if (error) {
        console.error('❌ Users - Query error:', error.message)
        toast.error('Failed to fetch users')
        setUsers([])
        setTotalCount(0)
      } else {
        // Fetch penalty balances for these users
        const userIds = usersData?.map(u => u.id) || []

        if (userIds.length > 0) {
          const { data: statsData } = await supabase
            .from('user_statistics')
            .select('user_id, current_penalty_balance')
            .in('user_id', userIds)

          const balanceMap: Record<string, number> = {}
          statsData?.forEach(stat => {
            balanceMap[stat.user_id] = stat.current_penalty_balance || 0
          })

          const usersWithBalance = usersData?.map(user => ({
            ...user,
            user_statistics: { current_penalty_balance: balanceMap[user.id] || 0 }
          })) || []

          console.log('✅ Users - Loaded', usersWithBalance.length, 'users')
          setUsers(usersWithBalance)
        } else {
          setUsers(usersData || [])
        }
        setTotalCount(count || 0)
      }
    } catch (err) {
      console.error('❌ Users - Error:', err)
      toast.error('An unexpected error occurred')
      setUsers([])
      setTotalCount(0)
    } finally {
      setIsLoading(false)
    }
  }, [currentPage, searchQuery, statusFilter, roleFilter])

  useEffect(() => {
    fetchUsers()
  }, [fetchUsers])

  const handleChangeRole = async () => {
    if (!selectedUser) return
    setIsSubmitting(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      toast.error('Database connection not available')
      setIsSubmitting(false)
      return
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error } = await (supabase as any)
      .from('users')
      .update({ role: newRole })
      .eq('id', selectedUser.id)

    if (error) {
      toast.error('Failed to update role')
    } else {
      toast.success(`Role updated to ${newRole}`)
      fetchUsers()
    }

    setIsSubmitting(false)
    setDialogType(null)
    setSelectedUser(null)
  }

  const handleChangeStatus = async () => {
    if (!selectedUser) return
    setIsSubmitting(true)

    const supabase = getSupabaseClient()
    if (!supabase) {
      toast.error('Database connection not available')
      setIsSubmitting(false)
      return
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error } = await (supabase as any)
      .from('users')
      .update({ account_status: newStatus })
      .eq('id', selectedUser.id)

    if (error) {
      toast.error('Failed to update status')
    } else {
      toast.success(`Status updated to ${newStatus}`)
      fetchUsers()
    }

    setIsSubmitting(false)
    setDialogType(null)
    setSelectedUser(null)
  }

  const getStatusBadge = (status: AccountStatus) => {
    const variants: Record<AccountStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      active: 'default',
      pending: 'secondary',
      suspended: 'destructive',
      auto_deactivated: 'destructive',
      deleted: 'outline',
    }

    const labels: Record<AccountStatus, string> = {
      active: 'Active',
      pending: 'Pending',
      suspended: 'Suspended',
      auto_deactivated: 'Auto-Deactivated',
      deleted: 'Deleted',
    }

    return <Badge variant={variants[status]}>{labels[status]}</Badge>
  }

  const getRoleBadge = (role: UserRole) => {
    const variants: Record<UserRole, 'default' | 'secondary' | 'outline'> = {
      admin: 'default',
      supervisor: 'secondary',
      cashier: 'secondary',
      user: 'outline',
    }

    return (
      <Badge variant={variants[role]} className="capitalize">
        {role}
      </Badge>
    )
  }

  const totalPages = Math.ceil(totalCount / PAGE_SIZE)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">User Management</h1>
          <p className="text-muted-foreground">
            Manage users, approve registrations, and control access
          </p>
        </div>
        <Button onClick={fetchUsers} variant="outline" size="sm">
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by name or email..."
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
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="suspended">Suspended</SelectItem>
                <SelectItem value="auto_deactivated">Auto-Deactivated</SelectItem>
              </SelectContent>
            </Select>
            <Select
              value={roleFilter}
              onValueChange={(value) => {
                setRoleFilter(value)
                setCurrentPage(1)
              }}
            >
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="Role" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Roles</SelectItem>
                <SelectItem value="admin">Admin</SelectItem>
                <SelectItem value="supervisor">Supervisor</SelectItem>
                <SelectItem value="cashier">Cashier</SelectItem>
                <SelectItem value="user">User</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Users Table */}
      <Card>
        <CardHeader>
          <CardTitle>Users ({totalCount})</CardTitle>
          <CardDescription>
            A list of all registered users in the system
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Balance</TableHead>
                <TableHead>Joined</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Skeleton className="h-10 w-10 rounded-full" />
                        <div>
                          <Skeleton className="h-4 w-32 mb-1" />
                          <Skeleton className="h-3 w-24" />
                        </div>
                      </div>
                    </TableCell>
                    <TableCell><Skeleton className="h-5 w-16" /></TableCell>
                    <TableCell><Skeleton className="h-5 w-20" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-16" /></TableCell>
                    <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                    <TableCell><Skeleton className="h-8 w-8 ml-auto" /></TableCell>
                  </TableRow>
                ))
              ) : users.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    No users found
                  </TableCell>
                </TableRow>
              ) : (
                users.map((user) => (
                  <TableRow key={user.id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-medium">
                          {user.name?.charAt(0).toUpperCase() || user.email?.charAt(0).toUpperCase() || 'U'}
                        </div>
                        <div>
                          <div className="font-medium">{user.name || user.email}</div>
                          <div className="text-sm text-muted-foreground">{user.email}</div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{getRoleBadge(user.role)}</TableCell>
                    <TableCell>{getStatusBadge(user.account_status)}</TableCell>
                    <TableCell>
                      <span className={(user.user_statistics?.current_penalty_balance || 0) > 0 ? 'text-destructive font-medium' : ''}>
                        {(user.user_statistics?.current_penalty_balance || 0).toLocaleString()} SOS
                      </span>
                    </TableCell>
                    <TableCell>
                      {new Date(user.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Actions</DropdownMenuLabel>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            onClick={() => {
                              setSelectedUser(user)
                              setNewRole(user.role)
                              setDialogType('role')
                            }}
                          >
                            <Shield className="mr-2 h-4 w-4" />
                            Change Role
                          </DropdownMenuItem>
                          {user.account_status === 'pending' && (
                            <DropdownMenuItem
                              onClick={async () => {
                                const supabase = getSupabaseClient()
                                if (!supabase) {
                                  toast.error('Database connection not available')
                                  return
                                }
                                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                                const { error } = await (supabase as any)
                                  .from('users')
                                  .update({ account_status: 'active' })
                                  .eq('id', user.id)
                                if (error) {
                                  toast.error('Failed to approve user')
                                } else {
                                  toast.success('User approved')
                                  fetchUsers()
                                }
                              }}
                            >
                              <UserCheck className="mr-2 h-4 w-4" />
                              Approve
                            </DropdownMenuItem>
                          )}
                          <DropdownMenuItem
                            onClick={() => {
                              setSelectedUser(user)
                              setNewStatus(user.account_status)
                              setDialogType('status')
                            }}
                          >
                            <UserX className="mr-2 h-4 w-4" />
                            Change Status
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
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
                {Math.min(currentPage * PAGE_SIZE, totalCount)} of {totalCount} users
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

      {/* Change Role Dialog */}
      <Dialog open={dialogType === 'role'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Change User Role</DialogTitle>
            <DialogDescription>
              Update the role for {selectedUser?.name}
            </DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <Select value={newRole} onValueChange={(v) => setNewRole(v as UserRole)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="user">User</SelectItem>
                <SelectItem value="supervisor">Supervisor</SelectItem>
                <SelectItem value="cashier">Cashier</SelectItem>
                <SelectItem value="admin">Admin</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogType(null)}>
              Cancel
            </Button>
            <Button onClick={handleChangeRole} disabled={isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Change Status Dialog */}
      <Dialog open={dialogType === 'status'} onOpenChange={() => setDialogType(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Change Account Status</DialogTitle>
            <DialogDescription>
              Update the account status for {selectedUser?.name}
            </DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <Select value={newStatus} onValueChange={(v) => setNewStatus(v as AccountStatus)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="suspended">Suspended</SelectItem>
                <SelectItem value="auto_deactivated">Auto-Deactivated</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogType(null)}>
              Cancel
            </Button>
            <Button onClick={handleChangeStatus} disabled={isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
