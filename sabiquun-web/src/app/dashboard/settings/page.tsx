'use client'

import { useEffect, useState } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Skeleton } from '@/components/ui/skeleton'
import { Separator } from '@/components/ui/separator'
import { toast } from 'sonner'
import { Loader2, Save, Settings, Bell, CreditCard, AlertTriangle } from 'lucide-react'

interface SystemSettings {
  penalty_rate: number
  grace_period_hours: number
  auto_deactivation_threshold: number
  warning_threshold_1: number
  warning_threshold_2: number
  new_member_grace_days: number
  deadline_reminder_enabled: boolean
  deadline_reminder_hour: number
  payment_reminder_enabled: boolean
  payment_reminder_day: string
}

export default function SettingsPage() {
  const [settings, setSettings] = useState<SystemSettings>({
    penalty_rate: 5000,
    grace_period_hours: 12,
    auto_deactivation_threshold: 500000,
    warning_threshold_1: 400000,
    warning_threshold_2: 450000,
    new_member_grace_days: 30,
    deadline_reminder_enabled: true,
    deadline_reminder_hour: 21,
    payment_reminder_enabled: true,
    payment_reminder_day: 'sunday',
  })
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  const supabase = getSupabaseClient()

  useEffect(() => {
    const fetchSettings = async () => {
      setIsLoading(true)

      const { data, error } = await supabase.from('settings').select('*')

      if (error) {
        console.error('Error fetching settings:', error)
        toast.error('Failed to load settings')
      } else if (data) {
        const settingsMap: Record<string, any> = {}
        const settingsData = data as { key: string; value: any }[]
        settingsData.forEach((s) => {
          settingsMap[s.key] = s.value
        })

        setSettings((prev) => ({
          ...prev,
          penalty_rate: settingsMap.penalty_rate ?? prev.penalty_rate,
          grace_period_hours: settingsMap.grace_period_hours ?? prev.grace_period_hours,
          auto_deactivation_threshold: settingsMap.auto_deactivation_threshold ?? prev.auto_deactivation_threshold,
          warning_threshold_1: settingsMap.warning_threshold_1 ?? prev.warning_threshold_1,
          warning_threshold_2: settingsMap.warning_threshold_2 ?? prev.warning_threshold_2,
          new_member_grace_days: settingsMap.new_member_grace_days ?? prev.new_member_grace_days,
          deadline_reminder_enabled: settingsMap.deadline_reminder_enabled ?? prev.deadline_reminder_enabled,
          deadline_reminder_hour: settingsMap.deadline_reminder_hour ?? prev.deadline_reminder_hour,
          payment_reminder_enabled: settingsMap.payment_reminder_enabled ?? prev.payment_reminder_enabled,
          payment_reminder_day: settingsMap.payment_reminder_day ?? prev.payment_reminder_day,
        }))
      }

      setIsLoading(false)
    }

    fetchSettings()
  }, [supabase])

  const handleSave = async () => {
    setIsSaving(true)

    try {
      // Upsert each setting
      const settingsToSave = Object.entries(settings).map(([key, value]) => ({
        key,
        value,
        updated_at: new Date().toISOString(),
      }))

      for (const setting of settingsToSave) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error } = await (supabase as any)
          .from('settings')
          .upsert(setting, { onConflict: 'key' })

        if (error) throw error
      }

      toast.success('Settings saved successfully')
    } catch (error) {
      console.error('Error saving settings:', error)
      toast.error('Failed to save settings')
    } finally {
      setIsSaving(false)
    }
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">System Settings</h1>
          <p className="text-muted-foreground">
            Configure system parameters and behavior
          </p>
        </div>
        <Card>
          <CardHeader>
            <Skeleton className="h-6 w-32" />
            <Skeleton className="h-4 w-64" />
          </CardHeader>
          <CardContent className="space-y-6">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="space-y-2">
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-10 w-full" />
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">System Settings</h1>
          <p className="text-muted-foreground">
            Configure system parameters and behavior
          </p>
        </div>
        <Button onClick={handleSave} disabled={isSaving}>
          {isSaving ? (
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          ) : (
            <Save className="mr-2 h-4 w-4" />
          )}
          Save Changes
        </Button>
      </div>

      <Tabs defaultValue="general" className="space-y-4">
        <TabsList>
          <TabsTrigger value="general" className="gap-2">
            <Settings className="h-4 w-4" />
            General
          </TabsTrigger>
          <TabsTrigger value="penalties" className="gap-2">
            <AlertTriangle className="h-4 w-4" />
            Penalties
          </TabsTrigger>
          <TabsTrigger value="notifications" className="gap-2">
            <Bell className="h-4 w-4" />
            Notifications
          </TabsTrigger>
        </TabsList>

        {/* General Settings */}
        <TabsContent value="general" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>General Settings</CardTitle>
              <CardDescription>
                Basic system configuration
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="penalty_rate">Penalty Rate per Missed Deed (SOS)</Label>
                  <Input
                    id="penalty_rate"
                    type="number"
                    value={settings.penalty_rate}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        penalty_rate: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Amount charged for each missed deed
                  </p>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="grace_period">Grace Period (Hours)</Label>
                  <Input
                    id="grace_period"
                    type="number"
                    value={settings.grace_period_hours}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        grace_period_hours: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Hours after midnight to submit reports
                  </p>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="new_member_grace">New Member Grace Period (Days)</Label>
                  <Input
                    id="new_member_grace"
                    type="number"
                    value={settings.new_member_grace_days}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        new_member_grace_days: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Days without penalties for new members
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Penalty Settings */}
        <TabsContent value="penalties" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Penalty Thresholds</CardTitle>
              <CardDescription>
                Configure auto-deactivation and warning levels
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="auto_deactivation">Auto-Deactivation Threshold (SOS)</Label>
                  <Input
                    id="auto_deactivation"
                    type="number"
                    value={settings.auto_deactivation_threshold}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        auto_deactivation_threshold: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Balance at which accounts are automatically deactivated
                  </p>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="warning_1">First Warning Threshold (SOS)</Label>
                  <Input
                    id="warning_1"
                    type="number"
                    value={settings.warning_threshold_1}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        warning_threshold_1: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Balance at which first warning is sent
                  </p>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="warning_2">Second Warning Threshold (SOS)</Label>
                  <Input
                    id="warning_2"
                    type="number"
                    value={settings.warning_threshold_2}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        warning_threshold_2: parseInt(e.target.value) || 0,
                      }))
                    }
                  />
                  <p className="text-xs text-muted-foreground">
                    Balance at which final warning is sent
                  </p>
                </div>
              </div>

              <Separator />

              <div className="p-4 bg-muted rounded-lg">
                <h4 className="font-medium mb-2">Current Thresholds</h4>
                <div className="grid grid-cols-3 gap-4 text-sm">
                  <div>
                    <span className="text-muted-foreground">Warning 1:</span>
                    <p className="font-medium text-yellow-600">
                      {settings.warning_threshold_1.toLocaleString()} SOS
                    </p>
                  </div>
                  <div>
                    <span className="text-muted-foreground">Warning 2:</span>
                    <p className="font-medium text-orange-600">
                      {settings.warning_threshold_2.toLocaleString()} SOS
                    </p>
                  </div>
                  <div>
                    <span className="text-muted-foreground">Deactivation:</span>
                    <p className="font-medium text-destructive">
                      {settings.auto_deactivation_threshold.toLocaleString()} SOS
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Notification Settings */}
        <TabsContent value="notifications" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Notification Settings</CardTitle>
              <CardDescription>
                Configure automated notifications
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Deadline Reminders</Label>
                  <p className="text-sm text-muted-foreground">
                    Send reminders before report deadline
                  </p>
                </div>
                <Switch
                  checked={settings.deadline_reminder_enabled}
                  onCheckedChange={(checked) =>
                    setSettings((prev) => ({
                      ...prev,
                      deadline_reminder_enabled: checked,
                    }))
                  }
                />
              </div>

              {settings.deadline_reminder_enabled && (
                <div className="space-y-2 pl-4 border-l-2 border-muted">
                  <Label htmlFor="reminder_hour">Reminder Time (Hour)</Label>
                  <Input
                    id="reminder_hour"
                    type="number"
                    min={0}
                    max={23}
                    value={settings.deadline_reminder_hour}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        deadline_reminder_hour: parseInt(e.target.value) || 21,
                      }))
                    }
                    className="w-24"
                  />
                  <p className="text-xs text-muted-foreground">
                    24-hour format (e.g., 21 for 9 PM)
                  </p>
                </div>
              )}

              <Separator />

              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Payment Reminders</Label>
                  <p className="text-sm text-muted-foreground">
                    Weekly reminders for users with high balance
                  </p>
                </div>
                <Switch
                  checked={settings.payment_reminder_enabled}
                  onCheckedChange={(checked) =>
                    setSettings((prev) => ({
                      ...prev,
                      payment_reminder_enabled: checked,
                    }))
                  }
                />
              </div>

              {settings.payment_reminder_enabled && (
                <div className="space-y-2 pl-4 border-l-2 border-muted">
                  <Label htmlFor="reminder_day">Reminder Day</Label>
                  <select
                    id="reminder_day"
                    value={settings.payment_reminder_day}
                    onChange={(e) =>
                      setSettings((prev) => ({
                        ...prev,
                        payment_reminder_day: e.target.value,
                      }))
                    }
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  >
                    <option value="sunday">Sunday</option>
                    <option value="monday">Monday</option>
                    <option value="tuesday">Tuesday</option>
                    <option value="wednesday">Wednesday</option>
                    <option value="thursday">Thursday</option>
                    <option value="friday">Friday</option>
                    <option value="saturday">Saturday</option>
                  </select>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
