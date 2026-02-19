// Send WhatsApp Notification - Supabase Edge Function
// This function processes pending WhatsApp notifications from the queue
// and sends them via WhatsApp Business Cloud API

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for development/testing
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WhatsAppConfig {
  whatsapp_enabled: boolean
  whatsapp_phone_number_id: string
  whatsapp_business_account_id: string
  whatsapp_access_token: string
  whatsapp_api_version: string
}

interface PendingNotification {
  id: string
  user_id: string
  type: string
  title: string
  body: string
  whatsapp_phone: string
  whatsapp_template_name: string
  whatsapp_template_language: string
  template_params: Record<string, string>
  created_at: string
}

interface WhatsAppSendResult {
  success: boolean
  notification_id: string
  message_id?: string
  error?: string
}

interface ProcessingResult {
  success: boolean
  processed: number
  sent: number
  failed: number
  errors: string[]
  timestamp: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase environment variables')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    console.log('=== Starting WhatsApp Notification Processing ===')
    console.log('Timestamp:', new Date().toISOString())

    // Get request body for optional parameters
    let limit = 50
    try {
      const body = await req.json()
      if (body.limit && typeof body.limit === 'number') {
        limit = Math.min(body.limit, 100) // Max 100 per batch
      }
    } catch {
      // No body or invalid JSON, use defaults
    }

    // Check if WhatsApp is enabled
    const config = await getWhatsAppConfig(supabase)

    if (!config.whatsapp_enabled) {
      console.log('WhatsApp notifications are disabled')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'WhatsApp notifications are disabled',
          processed: 0,
          sent: 0,
          failed: 0,
          timestamp: new Date().toISOString()
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // Get pending WhatsApp notifications
    const { data: pendingNotifications, error: fetchError } = await supabase
      .rpc('get_pending_whatsapp_notifications', { p_limit: limit })

    if (fetchError) {
      console.error('Error fetching pending notifications:', fetchError)
      throw fetchError
    }

    if (!pendingNotifications || pendingNotifications.length === 0) {
      console.log('No pending WhatsApp notifications to process')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No pending notifications',
          processed: 0,
          sent: 0,
          failed: 0,
          timestamp: new Date().toISOString()
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    console.log(`Found ${pendingNotifications.length} pending WhatsApp notifications`)

    // Process each notification
    const results: WhatsAppSendResult[] = []
    let sent = 0
    let failed = 0
    const errors: string[] = []

    for (const notification of pendingNotifications as PendingNotification[]) {
      try {
        const result = await sendWhatsAppMessage(config, notification)
        results.push(result)

        if (result.success) {
          // Mark as sent
          await supabase.rpc('mark_whatsapp_notification_sent', {
            p_notification_id: notification.id,
            p_whatsapp_message_id: result.message_id
          })
          sent++
          console.log(`✅ Sent to ${notification.whatsapp_phone}: ${notification.type}`)
        } else {
          // Mark as failed
          await supabase.rpc('mark_whatsapp_notification_failed', {
            p_notification_id: notification.id,
            p_error_code: 'SEND_FAILED',
            p_error_message: result.error || 'Unknown error'
          })
          failed++
          errors.push(`${notification.id}: ${result.error}`)
          console.error(`❌ Failed for ${notification.whatsapp_phone}: ${result.error}`)
        }
      } catch (err) {
        failed++
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        errors.push(`${notification.id}: ${errorMsg}`)
        console.error(`❌ Exception for notification ${notification.id}:`, err)

        // Mark as failed
        await supabase.rpc('mark_whatsapp_notification_failed', {
          p_notification_id: notification.id,
          p_error_code: 'EXCEPTION',
          p_error_message: errorMsg
        })
      }
    }

    console.log('=== WhatsApp Notification Processing Complete ===')
    console.log(`Processed: ${pendingNotifications.length}, Sent: ${sent}, Failed: ${failed}`)

    const response: ProcessingResult = {
      success: true,
      processed: pendingNotifications.length,
      sent,
      failed,
      errors,
      timestamp: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('❌ Fatal error in WhatsApp notification function:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

/**
 * Get WhatsApp configuration from settings
 */
async function getWhatsAppConfig(supabase: any): Promise<WhatsAppConfig> {
  const { data: settings, error } = await supabase
    .from('settings')
    .select('setting_key, setting_value')
    .in('setting_key', [
      'whatsapp_enabled',
      'whatsapp_phone_number_id',
      'whatsapp_business_account_id',
      'whatsapp_access_token',
      'whatsapp_api_version'
    ])

  if (error) {
    console.error('Error fetching WhatsApp config:', error)
    throw new Error('Failed to fetch WhatsApp configuration')
  }

  const configMap: Record<string, string> = {}
  for (const setting of settings || []) {
    configMap[setting.setting_key] = setting.setting_value
  }

  return {
    whatsapp_enabled: configMap['whatsapp_enabled'] === 'true',
    whatsapp_phone_number_id: configMap['whatsapp_phone_number_id'] || '',
    whatsapp_business_account_id: configMap['whatsapp_business_account_id'] || '',
    whatsapp_access_token: configMap['whatsapp_access_token'] || '',
    whatsapp_api_version: configMap['whatsapp_api_version'] || 'v18.0'
  }
}

/**
 * Send a WhatsApp message using the Cloud API
 */
async function sendWhatsAppMessage(
  config: WhatsAppConfig,
  notification: PendingNotification
): Promise<WhatsAppSendResult> {
  // Validate config
  if (!config.whatsapp_phone_number_id || !config.whatsapp_access_token) {
    return {
      success: false,
      notification_id: notification.id,
      error: 'WhatsApp API credentials not configured'
    }
  }

  // Validate phone number
  if (!notification.whatsapp_phone) {
    return {
      success: false,
      notification_id: notification.id,
      error: 'No WhatsApp phone number for user'
    }
  }

  // Build the WhatsApp API URL
  const apiUrl = `https://graph.facebook.com/${config.whatsapp_api_version}/${config.whatsapp_phone_number_id}/messages`

  // Format phone number (remove + if present, ensure it's just digits)
  const formattedPhone = notification.whatsapp_phone.replace(/[^\d]/g, '')

  // Build template components from params
  const components: any[] = []

  if (notification.template_params && Object.keys(notification.template_params).length > 0) {
    // Convert template_params object to array of parameter values
    // The mapping should be defined in whatsapp_template_mapping table
    const paramValues = Object.values(notification.template_params)

    if (paramValues.length > 0) {
      components.push({
        type: 'body',
        parameters: paramValues.map(value => ({
          type: 'text',
          text: String(value)
        }))
      })
    }
  }

  // Build request body
  const requestBody: any = {
    messaging_product: 'whatsapp',
    recipient_type: 'individual',
    to: formattedPhone,
    type: 'template',
    template: {
      name: notification.whatsapp_template_name,
      language: {
        code: notification.whatsapp_template_language || 'en'
      }
    }
  }

  // Add components if we have parameters
  if (components.length > 0) {
    requestBody.template.components = components
  }

  console.log(`Sending WhatsApp message to ${formattedPhone} using template: ${notification.whatsapp_template_name}`)

  try {
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.whatsapp_access_token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    })

    const responseData = await response.json()

    if (!response.ok) {
      // WhatsApp API error
      const errorMessage = responseData.error?.message ||
                          responseData.error?.error_data?.details ||
                          `HTTP ${response.status}`

      console.error('WhatsApp API error:', responseData)

      return {
        success: false,
        notification_id: notification.id,
        error: `WhatsApp API error: ${errorMessage}`
      }
    }

    // Success - extract message ID
    const messageId = responseData.messages?.[0]?.id || 'unknown'

    return {
      success: true,
      notification_id: notification.id,
      message_id: messageId
    }

  } catch (err) {
    console.error('Network error sending WhatsApp message:', err)
    return {
      success: false,
      notification_id: notification.id,
      error: `Network error: ${err instanceof Error ? err.message : 'Unknown error'}`
    }
  }
}
