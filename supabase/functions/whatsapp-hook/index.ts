// WhatsApp Webhook - Supabase Edge Function
// Purpose: Receive status updates from WhatsApp Cloud API
// Updates: delivered, read, and failed statuses in whatsapp_logs

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// WhatsApp webhook verification token (set this in Meta Business Manager)
const VERIFY_TOKEN = Deno.env.get('WHATSAPP_VERIFY_TOKEN') || 'sabiquun_whatsapp_webhook_token'

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)

  // GET request - webhook verification
  if (req.method === 'GET') {
    const mode = url.searchParams.get('hub.mode')
    const token = url.searchParams.get('hub.verify_token')
    const challenge = url.searchParams.get('hub.challenge')

    console.log('=== Webhook Verification Request ===')
    console.log('Mode:', mode)
    console.log('Received Token Length:', token?.length)
    console.log('Expected Token Length:', VERIFY_TOKEN?.length)
    console.log('Received Token (first 20 chars):', token?.substring(0, 20))
    console.log('Expected Token (first 20 chars):', VERIFY_TOKEN?.substring(0, 20))
    console.log('Tokens Match:', token === VERIFY_TOKEN)
    console.log('Challenge:', challenge)
    console.log('Mode Check:', mode === 'subscribe')

    if (mode === 'subscribe' && token === VERIFY_TOKEN) {
      console.log('✅ Webhook verified successfully')
      return new Response(challenge, {
        status: 200,
        headers: { 'Content-Type': 'text/plain' }
      })
    } else {
      console.error('❌ Webhook verification failed')
      console.error('Failure reason:')
      console.error('  - Mode is "subscribe"?', mode === 'subscribe')
      console.error('  - Token matches?', token === VERIFY_TOKEN)
      return new Response('Forbidden', { status: 403 })
    }
  }

  // POST request - webhook notification
  if (req.method === 'POST') {
    try {
      const supabaseUrl = Deno.env.get('SUPABASE_URL')
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

      if (!supabaseUrl || !supabaseServiceKey) {
        throw new Error('Missing Supabase environment variables')
      }

      const supabase = createClient(supabaseUrl, supabaseServiceKey, {
        auth: { autoRefreshToken: false, persistSession: false }
      })

      const body = await req.json()

      console.log('Received webhook notification:', JSON.stringify(body, null, 2))

      // Process webhook entries
      for (const entry of body.entry || []) {
        for (const change of entry.changes || []) {
          if (change.field === 'messages') {
            const value = change.value

            // Process status updates
            if (value.statuses && value.statuses.length > 0) {
              for (const status of value.statuses) {
                await processStatusUpdate(supabase, status)
              }
            }

            // Process message errors
            if (value.errors && value.errors.length > 0) {
              for (const error of value.errors) {
                console.error('WhatsApp error:', error)
              }
            }
          }
        }
      }

      return new Response(
        JSON.stringify({ success: true }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )

    } catch (error) {
      console.error('❌ Error processing webhook:', error)
      return new Response(
        JSON.stringify({
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error'
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }
  }

  return new Response('Method not allowed', { status: 405 })
})

async function processStatusUpdate(supabase: any, status: any) {
  const messageId = status.id
  const recipientId = status.recipient_id
  const statusType = status.status // sent, delivered, read, failed
  const timestamp = status.timestamp

  console.log(`Processing status update: ${messageId} - ${statusType}`)

  // Find the message in whatsapp_logs
  const { data: existingMessage, error: findError } = await supabase
    .from('whatsapp_logs')
    .select('*')
    .eq('whatsapp_message_id', messageId)
    .single()

  if (findError || !existingMessage) {
    console.log(`Message ${messageId} not found in whatsapp_logs, skipping...`)
    return
  }

  // Prepare update based on status type
  const updates: any = {
    status: statusType,
  }

  switch (statusType) {
    case 'delivered':
      updates.delivered_at = new Date(parseInt(timestamp) * 1000).toISOString()
      break

    case 'read':
      updates.status = 'read'
      updates.read_at = new Date(parseInt(timestamp) * 1000).toISOString()
      // If no delivered_at, set it to the read timestamp
      if (!existingMessage.delivered_at) {
        updates.delivered_at = new Date(parseInt(timestamp) * 1000).toISOString()
      }
      break

    case 'failed':
      updates.status = 'failed'
      if (status.errors && status.errors.length > 0) {
        updates.error_code = status.errors[0].code
        updates.error_message = status.errors[0].title || status.errors[0].message
      }
      break

    case 'sent':
      // Already handled when message is sent, but update if needed
      updates.status = 'sent'
      break
  }

  // Update the message
  const { error: updateError } = await supabase
    .from('whatsapp_logs')
    .update(updates)
    .eq('whatsapp_message_id', messageId)

  if (updateError) {
    console.error(`Error updating message ${messageId}:`, updateError)
  } else {
    console.log(`✅ Updated message ${messageId} to ${statusType}`)
  }

  // Also update notification_queue if it exists
  const { error: queueUpdateError } = await supabase
    .from('notification_queue')
    .update({
      whatsapp_status: statusType,
      updated_at: new Date().toISOString(),
    })
    .eq('whatsapp_message_id', messageId)

  if (queueUpdateError) {
    // Not critical if this fails, just log it
    console.log('Note: notification_queue update skipped or failed')
  }
}
