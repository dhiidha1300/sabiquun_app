// Process WhatsApp Logs - Supabase Edge Function
// Purpose: Process pending WhatsApp messages from whatsapp_logs table
// This handles manual messages sent from web admin
// Different from send-whatsapp-notification which handles automated notifications

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WhatsAppConfig {
  whatsapp_enabled: boolean
  whatsapp_phone_number_id: string
  whatsapp_access_token: string
  whatsapp_api_version: string
}

interface PendingMessage {
  id: string
  user_id: string | null
  phone_number: string
  user_name: string | null
  template_name: string
  template_language: string
  template_variables: Record<string, string>
  status: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase environment variables')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    })

    console.log('=== Processing WhatsApp Logs Queue ===')
    console.log('Timestamp:', new Date().toISOString())

    // Get WhatsApp config
    const config = await getWhatsAppConfig(supabase)

    if (!config.whatsapp_enabled) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'WhatsApp is disabled',
          processed: 0,
          sent: 0,
          failed: 0,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get pending messages from whatsapp_logs
    const { data: pendingMessages, error: fetchError } = await supabase
      .from('whatsapp_logs')
      .select('*')
      .eq('status', 'pending')
      .order('sent_at', { ascending: true })
      .limit(50)

    if (fetchError) {
      console.error('Error fetching pending messages:', fetchError)
      throw fetchError
    }

    if (!pendingMessages || pendingMessages.length === 0) {
      console.log('No pending messages to process')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No pending messages',
          processed: 0,
          sent: 0,
          failed: 0,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Found ${pendingMessages.length} pending messages`)

    let sent = 0
    let failed = 0
    const errors: string[] = []

    // Process each message
    for (const message of pendingMessages as PendingMessage[]) {
      try {
        const result = await sendWhatsAppMessage(config, message)

        if (result.success) {
          // Update as sent
          await supabase
            .from('whatsapp_logs')
            .update({
              status: 'sent',
              whatsapp_message_id: result.message_id,
              sent_at: new Date().toISOString(),
            })
            .eq('id', message.id)

          sent++
          console.log(`✅ Sent to ${message.phone_number}`)
        } else {
          // Update as failed
          await supabase
            .from('whatsapp_logs')
            .update({
              status: 'failed',
              error_code: 'SEND_FAILED',
              error_message: result.error || 'Unknown error',
            })
            .eq('id', message.id)

          failed++
          errors.push(`${message.id}: ${result.error}`)
          console.error(`❌ Failed for ${message.phone_number}: ${result.error}`)
        }
      } catch (err) {
        failed++
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        errors.push(`${message.id}: ${errorMsg}`)
        console.error(`❌ Exception for message ${message.id}:`, err)

        // Update as failed
        await supabase
          .from('whatsapp_logs')
          .update({
            status: 'failed',
            error_code: 'EXCEPTION',
            error_message: errorMsg,
          })
          .eq('id', message.id)
      }
    }

    console.log('=== Processing Complete ===')
    console.log(`Processed: ${pendingMessages.length}, Sent: ${sent}, Failed: ${failed}`)

    return new Response(
      JSON.stringify({
        success: true,
        processed: pendingMessages.length,
        sent,
        failed,
        errors,
        timestamp: new Date().toISOString(),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Fatal error processing WhatsApp logs:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

async function getWhatsAppConfig(supabase: any): Promise<WhatsAppConfig> {
  const { data: settings, error } = await supabase
    .from('settings')
    .select('setting_key, setting_value')
    .in('setting_key', [
      'whatsapp_enabled',
      'whatsapp_phone_number_id',
      'whatsapp_access_token',
      'whatsapp_api_version'
    ])

  if (error) {
    throw new Error('Failed to fetch WhatsApp configuration')
  }

  const configMap: Record<string, string> = {}
  for (const setting of settings || []) {
    configMap[setting.setting_key] = setting.setting_value
  }

  return {
    whatsapp_enabled: configMap['whatsapp_enabled'] === 'true',
    whatsapp_phone_number_id: configMap['whatsapp_phone_number_id'] || '',
    whatsapp_access_token: configMap['whatsapp_access_token'] || '',
    whatsapp_api_version: configMap['whatsapp_api_version'] || 'v18.0'
  }
}

async function sendWhatsAppMessage(
  config: WhatsAppConfig,
  message: PendingMessage
): Promise<{ success: boolean; message_id?: string; error?: string }> {
  if (!config.whatsapp_phone_number_id || !config.whatsapp_access_token) {
    return {
      success: false,
      error: 'WhatsApp API credentials not configured'
    }
  }

  if (!message.phone_number) {
    return {
      success: false,
      error: 'No phone number provided'
    }
  }

  const apiUrl = `https://graph.facebook.com/${config.whatsapp_api_version}/${config.whatsapp_phone_number_id}/messages`
  const formattedPhone = message.phone_number.replace(/[^\d]/g, '')

  // Build template components from variables
  const components: any[] = []

  if (message.template_variables && Object.keys(message.template_variables).length > 0) {
    const paramValues = Object.values(message.template_variables)

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

  const requestBody: any = {
    messaging_product: 'whatsapp',
    recipient_type: 'individual',
    to: formattedPhone,
    type: 'template',
    template: {
      name: message.template_name,
      language: {
        code: message.template_language || 'en'
      }
    }
  }

  if (components.length > 0) {
    requestBody.template.components = components
  }

  console.log(`Sending WhatsApp to ${formattedPhone} using template: ${message.template_name}`)

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
      const errorMessage = responseData.error?.message ||
                          responseData.error?.error_data?.details ||
                          `HTTP ${response.status}`

      console.error('WhatsApp API error:', responseData)

      return {
        success: false,
        error: `WhatsApp API error: ${errorMessage}`
      }
    }

    // Success - extract message ID
    const messageId = responseData.messages?.[0]?.id || 'unknown'

    return {
      success: true,
      message_id: messageId
    }

  } catch (err) {
    console.error('Network error sending WhatsApp:', err)
    return {
      success: false,
      error: `Network error: ${err instanceof Error ? err.message : 'Unknown error'}`
    }
  }
}
