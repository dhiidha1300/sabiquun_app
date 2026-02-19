// Edge Function: sync-whatsapp-templates
// Purpose: Fetch WhatsApp templates from Meta Business API and cache them
// Trigger: On-demand via web admin or scheduled (cron)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MetaTemplate {
  id: string
  name: string
  language: string
  status: 'APPROVED' | 'PENDING' | 'REJECTED' | 'DISABLED' | 'PAUSED' | 'IN_APPEAL'
  category: 'UTILITY' | 'MARKETING' | 'AUTHENTICATION'
  components: any[]
  quality_score?: {
    score: 'HIGH' | 'MEDIUM' | 'LOW' | 'UNKNOWN'
    rating?: 'GREEN' | 'YELLOW' | 'RED'
  }
  rejected_reason?: string
}

interface MetaAPIResponse {
  data: MetaTemplate[]
  paging?: {
    cursors?: {
      after?: string
      before?: string
    }
    next?: string
  }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    console.log('🔄 Starting WhatsApp template sync...')

    // Get WhatsApp credentials from system settings
    const { data: settings, error: settingsError } = await supabase
      .from('settings')
      .select('setting_key, setting_value')
      .in('setting_key', [
        'whatsapp_enabled',
        'whatsapp_business_account_id',
        'whatsapp_access_token',
        'whatsapp_api_version',
      ])

    if (settingsError) {
      throw new Error(`Failed to load settings: ${settingsError.message}`)
    }

    const settingsMap = new Map(
      settings.map(s => [s.setting_key, s.setting_value])
    )

    const whatsappEnabled = settingsMap.get('whatsapp_enabled') === 'true'
    const wabaId = settingsMap.get('whatsapp_business_account_id')
    const accessToken = settingsMap.get('whatsapp_access_token')
    const apiVersion = settingsMap.get('whatsapp_api_version') || 'v18.0'

    if (!whatsappEnabled) {
      return new Response(
        JSON.stringify({ error: 'WhatsApp is not enabled in system settings' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!wabaId || !accessToken) {
      return new Response(
        JSON.stringify({ error: 'WhatsApp credentials not configured' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`📡 Fetching templates from Meta API (WABA: ${wabaId})...`)

    // Fetch templates from Meta API with pagination
    const allTemplates: MetaTemplate[] = []
    let nextUrl = `https://graph.facebook.com/${apiVersion}/${wabaId}/message_templates?limit=100&fields=id,name,language,status,category,components,quality_score,rejected_reason`

    while (nextUrl) {
      const response = await fetch(nextUrl, {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(`Meta API error: ${JSON.stringify(errorData)}`)
      }

      const data: MetaAPIResponse = await response.json()
      allTemplates.push(...data.data)

      console.log(`📥 Fetched ${data.data.length} templates (total: ${allTemplates.length})`)

      // Check for next page
      nextUrl = data.paging?.next || ''
    }

    console.log(`✅ Fetched ${allTemplates.length} templates from Meta API`)

    // Process and cache templates
    const cacheExpiry = new Date()
    cacheExpiry.setHours(cacheExpiry.getHours() + 24) // Cache for 24 hours

    let insertedCount = 0
    let updatedCount = 0
    let errorCount = 0

    for (const template of allTemplates) {
      try {
        // Extract variables from body component
        const bodyComponent = template.components.find((c: any) => c.type === 'BODY')
        const bodyText = bodyComponent?.text || ''
        const variableMatches = bodyText.match(/\{\{(\d+)\}\}/g) || []
        const variableCount = variableMatches.length
        const variables = variableMatches.map((match: string, index: number) => `var${index + 1}`)

        // Extract header info
        const headerComponent = template.components.find((c: any) => c.type === 'HEADER')
        const footerComponent = template.components.find((c: any) => c.type === 'FOOTER')
        const buttonsComponent = template.components.find((c: any) => c.type === 'BUTTONS')

        // Prepare cache entry
        const cacheEntry = {
          template_id: template.id,
          template_name: template.name,
          language: template.language,
          status: template.status,
          category: template.category,
          quality_score: template.quality_score?.score || 'UNKNOWN',
          quality_rating: template.quality_score?.rating || null,
          rejection_reason: template.rejected_reason || null,
          components: template.components,
          header_type: headerComponent?.format || null,
          header_text: headerComponent?.text || null,
          body_text: bodyText,
          footer_text: footerComponent?.text || null,
          buttons: buttonsComponent?.buttons || null,
          variable_count: variableCount,
          variables: variables,
          cached_at: new Date().toISOString(),
          expires_at: cacheExpiry.toISOString(),
          meta_response: template,
        }

        // Upsert to cache
        const { error: upsertError } = await supabase
          .from('whatsapp_templates_cache')
          .upsert(cacheEntry, {
            onConflict: 'template_id',
            ignoreDuplicates: false,
          })

        if (upsertError) {
          console.error(`❌ Error caching template ${template.name}:`, upsertError)
          errorCount++
        } else {
          // Check if it was insert or update
          const { count } = await supabase
            .from('whatsapp_templates_cache')
            .select('*', { count: 'exact', head: true })
            .eq('template_id', template.id)

          if (count === 1) {
            insertedCount++
          } else {
            updatedCount++
          }
        }
      } catch (error) {
        console.error(`❌ Error processing template ${template.name}:`, error)
        errorCount++
      }
    }

    // Delete templates that no longer exist in Meta API
    const currentTemplateIds = allTemplates.map(t => t.id)
    const { error: deleteError, count: deletedCount } = await supabase
      .from('whatsapp_templates_cache')
      .delete({ count: 'exact' })
      .not('template_id', 'in', `(${currentTemplateIds.join(',')})`)

    console.log(`✅ Sync complete:`)
    console.log(`   - Inserted: ${insertedCount}`)
    console.log(`   - Updated: ${updatedCount}`)
    console.log(`   - Deleted: ${deletedCount || 0}`)
    console.log(`   - Errors: ${errorCount}`)

    return new Response(
      JSON.stringify({
        success: true,
        synced_at: new Date().toISOString(),
        total_templates: allTemplates.length,
        inserted: insertedCount,
        updated: updatedCount,
        deleted: deletedCount || 0,
        errors: errorCount,
        cache_expires_at: cacheExpiry.toISOString(),
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    console.error('❌ Sync failed:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
