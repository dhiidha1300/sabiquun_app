'use client'

import { useEffect, useState } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Checkbox } from '@/components/ui/checkbox'
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
  Send,
  MessageSquare,
  CheckCircle2,
  XCircle,
  Clock,
  RefreshCw,
  Loader2,
  Users,
  FileText,
  AlertCircle,
  Filter,
  Download,
} from 'lucide-react'
import { Textarea } from '@/components/ui/textarea'
import { ScrollArea } from '@/components/ui/scroll-area'

// Types
interface User {
  id: string
  name: string
  email: string
  phone: string | null
  whatsapp_phone: string | null
  whatsapp_verified: boolean
  role: string
}

interface WhatsAppTemplate {
  id: string
  template_id: string
  template_name: string
  language: string
  status: 'APPROVED' | 'PENDING' | 'REJECTED' | 'DISABLED' | 'PAUSED' | 'IN_APPEAL'
  category: string
  quality_score: string | null
  quality_rating: string | null
  body_text: string
  header_text: string | null
  footer_text: string | null
  variables: string[] | null
  variable_count: number
  components: any
  cached_at: string
}

interface WhatsAppLog {
  id: string
  user_id: string | null
  phone_number: string
  user_name: string | null
  template_name: string
  template_language: string
  template_variables: Record<string, any>
  status: 'pending' | 'sent' | 'delivered' | 'read' | 'failed'
  whatsapp_message_id: string | null
  error_code: string | null
  error_message: string | null
  notification_type: string | null
  sent_at: string
  delivered_at: string | null
  read_at: string | null
}

interface DeliveryStats {
  total_sent: number
  total_delivered: number
  total_read: number
  total_failed: number
  delivery_rate: number
  read_rate: number
  failure_rate: number
}

export default function WhatsAppPage() {
  const [activeTab, setActiveTab] = useState('send')

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">WhatsApp Notifications</h1>
        <p className="text-muted-foreground">
          Send WhatsApp messages and view delivery logs
        </p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList>
          <TabsTrigger value="send" className="flex items-center gap-2">
            <Send className="h-4 w-4" />
            Send Messages
          </TabsTrigger>
          <TabsTrigger value="logs" className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            Delivery Logs
          </TabsTrigger>
        </TabsList>

        <TabsContent value="send" className="space-y-4">
          <SendTab />
        </TabsContent>

        <TabsContent value="logs" className="space-y-4">
          <LogsTab />
        </TabsContent>
      </Tabs>
    </div>
  )
}

// ==================== SEND TAB COMPONENT ====================

function SendTab() {
  const supabase = getSupabaseClient()

  // State
  const [users, setUsers] = useState<User[]>([])
  const [templates, setTemplates] = useState<WhatsAppTemplate[]>([])
  const [selectedUsers, setSelectedUsers] = useState<Set<string>>(new Set())
  const [selectedTemplate, setSelectedTemplate] = useState<string>('')
  const [templateVariables, setTemplateVariables] = useState<Record<string, string>>({})
  const [isLoading, setIsLoading] = useState(true)
  const [isSending, setIsSending] = useState(false)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [filterVerified, setFilterVerified] = useState<boolean | null>(null)
  const [lastSyncTime, setLastSyncTime] = useState<string | null>(null)

  // Load users and templates
  useEffect(() => {
    loadData()
  }, [])

  // Refresh templates from Meta API
  const refreshTemplates = async () => {
    setIsRefreshing(true)
    try {
      toast.loading('Syncing templates from Meta API...')

      const response = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/sync-whatsapp-templates`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(error.error || 'Failed to sync templates')
      }

      const result = await response.json()
      toast.dismiss()
      toast.success(`Synced ${result.total_templates} templates from Meta API`)

      // Reload templates
      await loadData()
    } catch (error: any) {
      toast.dismiss()
      toast.error('Failed to sync templates: ' + error.message)
    } finally {
      setIsRefreshing(false)
    }
  }

  const loadData = async () => {
    setIsLoading(true)
    try {
      // Load users with WhatsApp
      const { data: usersData, error: usersError } = await supabase
        .from('users')
        .select('id, name, email, phone')
        .order('name')

      if (usersError) throw usersError

      // Load user notification preferences to get WhatsApp info
      const { data: prefsData, error: prefsError } = await supabase
        .from('user_notification_preferences')
        .select('user_id, whatsapp_phone, whatsapp_verified')

      if (prefsError) throw prefsError

      // Merge users with preferences
      const prefsMap = new Map(
        (prefsData || []).map(p => [p.user_id, p])
      )

      const mergedUsers = (usersData || []).map(user => ({
        ...user,
        whatsapp_phone: prefsMap.get(user.id)?.whatsapp_phone || null,
        whatsapp_verified: prefsMap.get(user.id)?.whatsapp_verified || false,
      }))

      setUsers(mergedUsers)

      // Load WhatsApp templates from cache (only approved ones)
      const { data: templatesData, error: templatesError } = await supabase
        .from('whatsapp_templates_cache')
        .select('*')
        .eq('status', 'APPROVED')
        .order('template_name')

      if (templatesError) throw templatesError

      setTemplates(templatesData || [])

      // Get last sync time
      if (templatesData && templatesData.length > 0) {
        const latestSync = templatesData[0].cached_at
        setLastSyncTime(latestSync)
      }
    } catch (error: any) {
      console.error('Error loading data:', error)
      toast.error('Failed to load data: ' + error.message)
    } finally {
      setIsLoading(false)
    }
  }

  // Filter users
  const filteredUsers = users.filter(user => {
    const matchesSearch =
      user.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.whatsapp_phone?.includes(searchQuery)

    const matchesFilter =
      filterVerified === null || user.whatsapp_verified === filterVerified

    return matchesSearch && matchesFilter
  })

  // Toggle user selection
  const toggleUser = (userId: string) => {
    const newSelected = new Set(selectedUsers)
    if (newSelected.has(userId)) {
      newSelected.delete(userId)
    } else {
      newSelected.add(userId)
    }
    setSelectedUsers(newSelected)
  }

  // Select all/none
  const toggleSelectAll = () => {
    if (selectedUsers.size === filteredUsers.length) {
      setSelectedUsers(new Set())
    } else {
      setSelectedUsers(new Set(filteredUsers.map(u => u.id)))
    }
  }

  // Get selected template
  const currentTemplate = templates.find(t => t.id === selectedTemplate)

  // Get template variables directly from cache
  const templateVars = currentTemplate?.variables || []

  // Send messages
  const handleSend = async () => {
    if (selectedUsers.size === 0) {
      toast.error('Please select at least one recipient')
      return
    }

    if (!selectedTemplate) {
      toast.error('Please select a template')
      return
    }

    // Validate template variables
    for (const varName of templateVars) {
      if (!templateVariables[varName]?.trim()) {
        toast.error(`Please fill in the ${varName} variable`)
        return
      }
    }

    setIsSending(true)
    try {
      const selectedUsersList = users.filter(u => selectedUsers.has(u.id))
      let successCount = 0
      let failCount = 0

      for (const user of selectedUsersList) {
        if (!user.whatsapp_verified || !user.whatsapp_phone) {
          failCount++
          continue
        }

        // Insert into whatsapp_logs
        const { error } = await supabase
          .from('whatsapp_logs')
          .insert({
            user_id: user.id,
            phone_number: user.whatsapp_phone,
            user_name: user.name,
            template_name: currentTemplate!.template_name,
            template_language: currentTemplate!.language,
            template_variables: templateVariables,
            status: 'pending',
            notification_type: currentTemplate!.category,
          })

        if (error) {
          console.error('Error queuing message:', error)
          failCount++
        } else {
          successCount++
        }
      }

      if (successCount > 0) {
        toast.success(`Queued ${successCount} message(s) for delivery`)

        // Trigger edge function to process the queue immediately
        try {
          const processResponse = await fetch(
            `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/process-whatsapp-logs`,
            {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json',
              },
            }
          )

          const processResult = await processResponse.json()

          if (processResult.success) {
            if (processResult.sent > 0) {
              toast.success(`✅ Successfully sent ${processResult.sent} message(s)`)
            }
            if (processResult.failed > 0) {
              toast.error(`❌ ${processResult.failed} message(s) failed to send`)
            }

            // Reload logs to show updated status
            await loadLogs()
          } else {
            toast.error('Failed to process messages: ' + processResult.error)
          }
        } catch (processError: any) {
          console.error('Error processing queue:', processError)
          toast.error('Messages queued but processing failed. They will be sent by the scheduled job.')
        }
      }
      if (failCount > 0) {
        toast.warning(`${failCount} message(s) could not be queued`)
      }

      // Reset form
      setSelectedUsers(new Set())
      setSelectedTemplate('')
      setTemplateVariables({})
    } catch (error: any) {
      console.error('Error sending messages:', error)
      toast.error('Failed to send messages: ' + error.message)
    } finally {
      setIsSending(false)
    }
  }

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-96 w-full" />
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* Left: Recipients */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Users className="h-5 w-5" />
            Select Recipients
          </CardTitle>
          <CardDescription>
            {selectedUsers.size} of {filteredUsers.filter(u => u.whatsapp_verified).length} verified users selected
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Search and filters */}
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
            <Select
              value={filterVerified === null ? 'all' : filterVerified ? 'verified' : 'unverified'}
              onValueChange={(value) =>
                setFilterVerified(value === 'all' ? null : value === 'verified')
              }
            >
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Filter" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Users</SelectItem>
                <SelectItem value="verified">Verified Only</SelectItem>
                <SelectItem value="unverified">Unverified</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Select all */}
          <div className="flex items-center justify-between border-b pb-2">
            <Label className="flex items-center gap-2 cursor-pointer">
              <Checkbox
                checked={selectedUsers.size === filteredUsers.filter(u => u.whatsapp_verified).length && filteredUsers.length > 0}
                onCheckedChange={toggleSelectAll}
              />
              <span className="text-sm font-medium">Select All Verified</span>
            </Label>
            <Button
              variant="ghost"
              size="sm"
              onClick={loadData}
            >
              <RefreshCw className="h-4 w-4" />
            </Button>
          </div>

          {/* User list */}
          <ScrollArea className="h-[400px]">
            <div className="space-y-2">
              {filteredUsers.map(user => (
                <div
                  key={user.id}
                  className={`flex items-center gap-3 p-3 rounded-lg border ${
                    selectedUsers.has(user.id) ? 'bg-primary/5 border-primary' : ''
                  }`}
                >
                  <Checkbox
                    checked={selectedUsers.has(user.id)}
                    onCheckedChange={() => toggleUser(user.id)}
                    disabled={!user.whatsapp_verified}
                  />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium truncate">{user.name}</p>
                      {user.whatsapp_verified ? (
                        <Badge variant="default" className="text-xs">
                          <CheckCircle2 className="h-3 w-3 mr-1" />
                          Verified
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-xs">
                          <XCircle className="h-3 w-3 mr-1" />
                          Unverified
                        </Badge>
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground truncate">
                      {user.whatsapp_phone || 'No WhatsApp number'}
                    </p>
                  </div>
                </div>
              ))}

              {filteredUsers.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  <Users className="h-12 w-12 mx-auto mb-2 opacity-20" />
                  <p>No users found</p>
                </div>
              )}
            </div>
          </ScrollArea>
        </CardContent>
      </Card>

      {/* Right: Template and Variables */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5" />
            Message Configuration
          </CardTitle>
          <CardDescription>
            Select template and configure variables
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Template sync status */}
          <div className="flex items-center justify-between text-xs text-muted-foreground">
            {lastSyncTime && (
              <span>Last synced: {new Date(lastSyncTime).toLocaleString()}</span>
            )}
            <Button
              variant="ghost"
              size="sm"
              onClick={refreshTemplates}
              disabled={isRefreshing}
            >
              {isRefreshing ? (
                <>
                  <Loader2 className="h-3 w-3 mr-1 animate-spin" />
                  Syncing...
                </>
              ) : (
                <>
                  <RefreshCw className="h-3 w-3 mr-1" />
                  Refresh Templates
                </>
              )}
            </Button>
          </div>

          {/* Template selection */}
          <div className="space-y-2">
            <Label>WhatsApp Template</Label>
            <Select value={selectedTemplate} onValueChange={setSelectedTemplate}>
              <SelectTrigger>
                <SelectValue placeholder="Select a template" />
              </SelectTrigger>
              <SelectContent>
                {templates.length === 0 && (
                  <div className="p-4 text-center text-sm text-muted-foreground">
                    No templates available. Click "Refresh Templates" to sync from Meta API.
                  </div>
                )}
                {templates.map(template => (
                  <SelectItem key={template.id} value={template.id}>
                    <div className="flex items-center gap-2">
                      <span>{template.template_name}</span>
                      <Badge variant="outline" className="text-xs">
                        {template.language}
                      </Badge>
                      {template.quality_score && (
                        <Badge
                          variant={
                            template.quality_score === 'HIGH'
                              ? 'default'
                              : template.quality_score === 'MEDIUM'
                              ? 'secondary'
                              : 'destructive'
                          }
                          className="text-xs"
                        >
                          {template.quality_score}
                        </Badge>
                      )}
                    </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {currentTemplate && (
              <div className="space-y-1">
                <p className="text-xs text-muted-foreground">
                  Template ID: {currentTemplate.template_id}
                </p>
                {currentTemplate.quality_score && (
                  <p className="text-xs text-muted-foreground">
                    Quality: {currentTemplate.quality_score}
                    {currentTemplate.quality_rating && ` (${currentTemplate.quality_rating})`}
                  </p>
                )}
                <div className="mt-2 p-2 bg-muted/50 rounded text-xs">
                  <p className="font-medium mb-1">Template Preview:</p>
                  {currentTemplate.header_text && (
                    <p className="text-muted-foreground mb-1">
                      <strong>Header:</strong> {currentTemplate.header_text}
                    </p>
                  )}
                  <p className="text-muted-foreground mb-1">
                    <strong>Body:</strong> {currentTemplate.body_text}
                  </p>
                  {currentTemplate.footer_text && (
                    <p className="text-muted-foreground">
                      <strong>Footer:</strong> {currentTemplate.footer_text}
                    </p>
                  )}
                </div>
              </div>
            )}
          </div>

          {/* Template variables */}
          {selectedTemplate && templateVars.length > 0 && (
            <div className="space-y-4 pt-4 border-t">
              <Label>Template Variables</Label>
              {templateVars.map(varName => (
                <div key={varName} className="space-y-2">
                  <Label htmlFor={varName} className="text-sm capitalize">
                    {varName.replace(/_/g, ' ')}
                  </Label>
                  <Input
                    id={varName}
                    placeholder={`Enter ${varName}`}
                    value={templateVariables[varName] || ''}
                    onChange={(e) =>
                      setTemplateVariables({
                        ...templateVariables,
                        [varName]: e.target.value
                      })
                    }
                  />
                </div>
              ))}
            </div>
          )}

          {/* Preview */}
          {selectedTemplate && (
            <div className="space-y-2 p-4 bg-muted/50 rounded-lg">
              <Label className="text-xs text-muted-foreground">Preview</Label>
              <div className="text-sm space-y-1">
                <p className="font-medium">{currentTemplate?.title}</p>
                <p className="text-muted-foreground">
                  {selectedUsers.size} recipient(s) selected
                </p>
              </div>
            </div>
          )}

          {/* Send button */}
          <Button
            onClick={handleSend}
            disabled={isSending || selectedUsers.size === 0 || !selectedTemplate}
            className="w-full"
            size="lg"
          >
            {isSending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Sending...
              </>
            ) : (
              <>
                <Send className="mr-2 h-4 w-4" />
                Send to {selectedUsers.size} User(s)
              </>
            )}
          </Button>

          {selectedUsers.size > 0 && (
            <p className="text-xs text-center text-muted-foreground">
              Messages will be queued and sent by the Edge Function
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

// ==================== LOGS TAB COMPONENT ====================

function LogsTab() {
  const supabase = getSupabaseClient()

  // State
  const [logs, setLogs] = useState<WhatsAppLog[]>([])
  const [stats, setStats] = useState<DeliveryStats | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [filterTemplate, setFilterTemplate] = useState<string>('all')
  const [searchPhone, setSearchPhone] = useState('')
  const [selectedLog, setSelectedLog] = useState<WhatsAppLog | null>(null)

  // Load logs
  useEffect(() => {
    loadLogs()
    loadStats()
  }, [filterStatus, filterTemplate, searchPhone])

  const loadLogs = async () => {
    setIsLoading(true)
    try {
      let query = supabase
        .from('whatsapp_logs')
        .select('*')
        .order('sent_at', { ascending: false })
        .limit(100)

      if (filterStatus !== 'all') {
        query = query.eq('status', filterStatus)
      }

      if (filterTemplate !== 'all') {
        query = query.eq('template_name', filterTemplate)
      }

      if (searchPhone) {
        query = query.ilike('phone_number', `%${searchPhone}%`)
      }

      const { data, error } = await query

      if (error) throw error

      setLogs(data || [])
    } catch (error: any) {
      console.error('Error loading logs:', error)
      toast.error('Failed to load logs: ' + error.message)
    } finally {
      setIsLoading(false)
    }
  }

  const loadStats = async () => {
    try {
      const { data, error } = await supabase
        .rpc('get_whatsapp_delivery_stats', { days_back: 7 })

      if (error) throw error

      if (data && data.length > 0) {
        setStats(data[0])
      }
    } catch (error: any) {
      console.error('Error loading stats:', error)
    }
  }

  const getStatusBadge = (status: string) => {
    const variants: Record<string, { variant: any; icon: any; label: string }> = {
      pending: { variant: 'secondary', icon: Clock, label: 'Pending' },
      sent: { variant: 'default', icon: Send, label: 'Sent' },
      delivered: { variant: 'default', icon: CheckCircle2, label: 'Delivered' },
      read: { variant: 'default', icon: CheckCircle2, label: 'Read' },
      failed: { variant: 'destructive', icon: XCircle, label: 'Failed' },
    }

    const config = variants[status] || variants.pending
    const Icon = config.icon

    return (
      <Badge variant={config.variant} className="flex items-center gap-1 w-fit">
        <Icon className="h-3 w-3" />
        {config.label}
      </Badge>
    )
  }

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleString()
  }

  return (
    <div className="space-y-6">
      {/* Statistics Cards */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total Sent
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.total_sent}</div>
              <p className="text-xs text-muted-foreground">Last 7 days</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Delivery Rate
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">
                {stats.delivery_rate}%
              </div>
              <p className="text-xs text-muted-foreground">
                {stats.total_delivered} delivered
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Read Rate
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-blue-600">
                {stats.read_rate}%
              </div>
              <p className="text-xs text-muted-foreground">
                {stats.total_read} read
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Failed
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-red-600">
                {stats.total_failed}
              </div>
              <p className="text-xs text-muted-foreground">
                {stats.failure_rate}% failure rate
              </p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Filters */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Delivery Logs</CardTitle>
              <CardDescription>View WhatsApp message delivery history</CardDescription>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={async () => {
                toast.loading('Processing pending messages...')
                try {
                  const response = await fetch(
                    `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/process-whatsapp-logs`,
                    {
                      method: 'POST',
                      headers: {
                        'Authorization': `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY}`,
                        'Content-Type': 'application/json',
                      },
                    }
                  )
                  const result = await response.json()

                  if (result.success) {
                    toast.success(`Processed: ${result.processed} | Sent: ${result.sent} | Failed: ${result.failed}`)
                    await loadLogs()
                    await loadStats()
                  } else {
                    toast.error('Failed to process queue: ' + result.error)
                  }
                } catch (error: any) {
                  toast.error('Error processing queue: ' + error.message)
                }
              }}
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Process Queue
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by phone number..."
                value={searchPhone}
                onChange={(e) => setSearchPhone(e.target.value)}
                className="pl-9"
              />
            </div>
            <Select value={filterStatus} onValueChange={setFilterStatus}>
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="sent">Sent</SelectItem>
                <SelectItem value="delivered">Delivered</SelectItem>
                <SelectItem value="read">Read</SelectItem>
                <SelectItem value="failed">Failed</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" onClick={loadLogs}>
              <RefreshCw className="h-4 w-4" />
            </Button>
          </div>

          {/* Logs Table */}
          <div className="border rounded-lg">
            {isLoading ? (
              <div className="p-8 space-y-2">
                <Skeleton className="h-12 w-full" />
                <Skeleton className="h-12 w-full" />
                <Skeleton className="h-12 w-full" />
              </div>
            ) : logs.length === 0 ? (
              <div className="p-8 text-center text-muted-foreground">
                <FileText className="h-12 w-12 mx-auto mb-2 opacity-20" />
                <p>No logs found</p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Recipient</TableHead>
                    <TableHead>Template</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Sent At</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {logs.map(log => (
                    <TableRow key={log.id}>
                      <TableCell>
                        <div>
                          <p className="font-medium">{log.user_name || 'Unknown'}</p>
                          <p className="text-xs text-muted-foreground">{log.phone_number}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div>
                          <p className="text-sm">{log.template_name}</p>
                          <Badge variant="outline" className="text-xs mt-1">
                            {log.template_language}
                          </Badge>
                        </div>
                      </TableCell>
                      <TableCell>{getStatusBadge(log.status)}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(log.sent_at)}
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedLog(log)}
                        >
                          View Details
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Log Details Dialog */}
      <Dialog open={!!selectedLog} onOpenChange={(open) => !open && setSelectedLog(null)}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Message Details</DialogTitle>
            <DialogDescription>
              WhatsApp message delivery information
            </DialogDescription>
          </DialogHeader>

          {selectedLog && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-xs text-muted-foreground">Recipient</Label>
                  <p className="text-sm font-medium">{selectedLog.user_name}</p>
                  <p className="text-xs text-muted-foreground">{selectedLog.phone_number}</p>
                </div>
                <div>
                  <Label className="text-xs text-muted-foreground">Status</Label>
                  <div className="mt-1">{getStatusBadge(selectedLog.status)}</div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-xs text-muted-foreground">Template</Label>
                  <p className="text-sm">{selectedLog.template_name}</p>
                  <Badge variant="outline" className="text-xs mt-1">
                    {selectedLog.template_language}
                  </Badge>
                </div>
                <div>
                  <Label className="text-xs text-muted-foreground">Message ID</Label>
                  <p className="text-xs font-mono break-all">
                    {selectedLog.whatsapp_message_id || 'N/A'}
                  </p>
                </div>
              </div>

              <div>
                <Label className="text-xs text-muted-foreground">Template Variables</Label>
                <pre className="mt-1 text-xs bg-muted p-3 rounded-lg overflow-x-auto">
                  {JSON.stringify(selectedLog.template_variables, null, 2)}
                </pre>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <Label className="text-xs text-muted-foreground">Sent At</Label>
                  <p className="text-xs">{formatDate(selectedLog.sent_at)}</p>
                </div>
                <div>
                  <Label className="text-xs text-muted-foreground">Delivered At</Label>
                  <p className="text-xs">{formatDate(selectedLog.delivered_at)}</p>
                </div>
                <div>
                  <Label className="text-xs text-muted-foreground">Read At</Label>
                  <p className="text-xs">{formatDate(selectedLog.read_at)}</p>
                </div>
              </div>

              {selectedLog.status === 'failed' && (
                <div className="space-y-2 p-4 bg-destructive/10 border border-destructive/20 rounded-lg">
                  <Label className="text-xs text-destructive font-medium">Error Details</Label>
                  <p className="text-sm font-medium">
                    Code: {selectedLog.error_code || 'Unknown'}
                  </p>
                  <p className="text-sm text-muted-foreground">
                    {selectedLog.error_message || 'No error message'}
                  </p>
                </div>
              )}
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setSelectedLog(null)}>
              Close
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
