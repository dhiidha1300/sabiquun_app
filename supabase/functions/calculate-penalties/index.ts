// Calculate Daily Penalties - Supabase Edge Function
// This function runs automatically at 12:00 PM EAT (9:00 AM UTC) daily
// to calculate and apply penalties for users who missed deed submissions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for development/testing
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PenaltyCalculationResult {
  success: boolean
  date_processed?: string
  users_processed?: number
  penalties_created?: number
  target_deeds?: number
  penalty_per_deed?: number
  errors?: string[]
  timestamp?: string
  error?: string
}

interface Penalty {
  id: string
  user_id: string
  amount: number
  date_incurred: string
  users: {
    id: string
    name: string
    fcm_token: string | null
    email: string
  }
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

    console.log('=== Starting Automatic Penalty Calculation ===')
    console.log('Timestamp:', new Date().toISOString())
    console.log('Timezone: EAT (UTC+3)')

    // Call the penalty calculation function with logging
    const { data: calculationResult, error: calculationError } = await supabase
      .rpc('calculate_daily_penalties_with_logging') as {
        data: PenaltyCalculationResult | null,
        error: any
      }

    if (calculationError) {
      console.error('❌ Penalty calculation error:', calculationError)
      throw calculationError
    }

    if (!calculationResult) {
      throw new Error('No result returned from penalty calculation')
    }

    console.log('✅ Penalty calculation completed:', calculationResult)

    // If penalties were created, send notifications
    if (calculationResult.success && calculationResult.penalties_created && calculationResult.penalties_created > 0) {
      console.log(`📧 Processing notifications for ${calculationResult.penalties_created} new penalties...`)

      try {
        await sendPenaltyNotifications(supabase, calculationResult.date_processed!)
      } catch (notificationError) {
        console.error('⚠️  Notification sending failed (non-critical):', notificationError)
        // Don't fail the entire function if notifications fail
      }
    } else {
      console.log('ℹ️  No penalties created - no notifications to send')
    }

    // Check for users approaching deactivation threshold
    if (calculationResult.success) {
      console.log('🔍 Checking for users approaching deactivation threshold...')

      try {
        await checkDeactivationWarnings(supabase)
      } catch (warningError) {
        console.error('⚠️  Deactivation warning check failed (non-critical):', warningError)
      }
    }

    console.log('=== Penalty Calculation Function Complete ===')

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        result: calculationResult,
        timestamp: new Date().toISOString(),
        timezone: 'EAT (UTC+3)'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('❌ Fatal error in penalty calculation function:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
        timezone: 'EAT (UTC+3)'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

/**
 * Send notifications to users who received penalties today
 */
async function sendPenaltyNotifications(supabase: any, dateProcessed: string): Promise<void> {
  console.log(`Fetching penalties for date: ${dateProcessed}`)

  // Get all penalties created for this date with user information
  const { data: penalties, error } = await supabase
    .from('penalties')
    .select(`
      id,
      user_id,
      amount,
      date_incurred,
      users!inner (
        id,
        name,
        fcm_token,
        email
      )
    `)
    .eq('date_incurred', dateProcessed) as { data: Penalty[] | null, error: any }

  if (error) {
    console.error('Error fetching penalties:', error)
    throw error
  }

  if (!penalties || penalties.length === 0) {
    console.log('No penalties found for notifications')
    return
  }

  console.log(`Found ${penalties.length} penalties to notify`)

  // For each penalty, queue a notification
  for (const penalty of penalties) {
    try {
      // Calculate user's current balance
      const { data: balanceData } = await supabase
        .rpc('get_user_penalty_balance', { p_user_id: penalty.user_id })

      const currentBalance = balanceData?.total_balance || penalty.amount

      // Insert into notification queue
      const notificationData = {
        user_id: penalty.user_id,
        type: 'penalty_incurred',
        title: 'Penalty Applied',
        body: `Penalty of ${penalty.amount.toLocaleString()} shillings applied for missed deeds. Current balance: ${currentBalance.toLocaleString()} shillings.`,
        data: {
          penalty_id: penalty.id,
          amount: penalty.amount,
          balance: currentBalance,
          date_incurred: penalty.date_incurred,
          action: 'open_payment_screen'
        },
        status: 'pending',
        created_at: new Date().toISOString()
      }

      const { error: queueError } = await supabase
        .from('notification_queue')
        .insert(notificationData)

      if (queueError) {
        console.error(`Failed to queue notification for user ${penalty.users.name}:`, queueError)
      } else {
        console.log(`✅ Notification queued for user: ${penalty.users.name} (${penalty.amount} shillings)`)
      }

    } catch (err) {
      console.error(`Error processing notification for penalty ${penalty.id}:`, err)
      // Continue with next penalty
    }
  }

  console.log(`📬 Notification queuing complete`)
}

/**
 * Check for users approaching deactivation threshold and send warnings
 */
async function checkDeactivationWarnings(supabase: any): Promise<void> {
  const WARNING_THRESHOLD_1 = 400000 // First warning at 400K
  const WARNING_THRESHOLD_2 = 450000 // Final warning at 450K
  const DEACTIVATION_THRESHOLD = 500000 // Deactivation at 500K

  // Get users with high balances
  const { data: highBalanceUsers, error } = await supabase
    .from('users')
    .select('id, name, email, fcm_token')
    .eq('account_status', 'active')
    .in('membership_status', ['exclusive', 'legacy'])

  if (error) {
    console.error('Error fetching users for warning check:', error)
    return
  }

  if (!highBalanceUsers || highBalanceUsers.length === 0) {
    return
  }

  let warningsIssued = 0

  for (const user of highBalanceUsers) {
    try {
      // Get user's current balance
      const { data: balanceData } = await supabase
        .rpc('get_user_penalty_balance', { p_user_id: user.id })

      if (!balanceData) continue

      const balance = balanceData.total_balance

      // Determine if warning is needed
      let warningType: string | null = null
      let warningMessage: string | null = null

      if (balance >= DEACTIVATION_THRESHOLD) {
        // Auto-deactivate user
        console.log(`🚨 User ${user.name} reached deactivation threshold: ${balance}`)

        const { error: updateError } = await supabase
          .from('users')
          .update({
            account_status: 'auto_deactivated',
            updated_at: new Date().toISOString()
          })
          .eq('id', user.id)

        if (!updateError) {
          warningType = 'account_deactivated'
          warningMessage = `Your account has been deactivated due to penalty balance of ${balance.toLocaleString()} shillings. Please contact admin.`
        }

      } else if (balance >= WARNING_THRESHOLD_2) {
        // Final warning
        warningType = 'deactivation_warning_final'
        warningMessage = `⚠️ FINAL WARNING: Your penalty balance is ${balance.toLocaleString()} shillings. Account will be deactivated at 500,000. Please pay immediately!`

      } else if (balance >= WARNING_THRESHOLD_1) {
        // First warning
        warningType = 'deactivation_warning'
        warningMessage = `⚠️ Warning: Your penalty balance is ${balance.toLocaleString()} shillings. Account will be deactivated at 500,000. Please clear your dues.`
      }

      // Send warning if needed
      if (warningType && warningMessage) {
        const { error: queueError } = await supabase
          .from('notification_queue')
          .insert({
            user_id: user.id,
            type: warningType,
            title: warningType === 'account_deactivated' ? 'Account Deactivated' : 'Payment Warning',
            body: warningMessage,
            data: {
              balance: balance,
              threshold: DEACTIVATION_THRESHOLD,
              action: 'open_payment_screen'
            },
            status: 'pending',
            created_at: new Date().toISOString()
          })

        if (!queueError) {
          console.log(`⚠️  Warning sent to ${user.name}: ${warningType} (${balance} shillings)`)
          warningsIssued++
        }
      }

    } catch (err) {
      console.error(`Error checking balance for user ${user.id}:`, err)
    }
  }

  if (warningsIssued > 0) {
    console.log(`📢 Issued ${warningsIssued} deactivation warnings`)
  } else {
    console.log('✅ No users approaching deactivation threshold')
  }
}
