import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/lib/types/database'

function isValidUrl(url: string | undefined): boolean {
  if (!url) return false
  try {
    const parsed = new URL(url)
    return parsed.protocol === 'http:' || parsed.protocol === 'https:'
  } catch {
    return false
  }
}

export function createClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  console.log('Creating Supabase client with:', {
    hasUrl: !!supabaseUrl,
    hasKey: !!supabaseKey,
    urlValid: isValidUrl(supabaseUrl),
    url: supabaseUrl?.substring(0, 30) + '...' // Show partial URL for debugging
  })

  // During build time or if env vars are not set properly, return null
  if (!isValidUrl(supabaseUrl) || !supabaseKey) {
    console.error('Supabase client not initialized: Invalid or missing environment variables', {
      supabaseUrl,
      hasKey: !!supabaseKey
    })
    // Return a mock client that won't crash but won't work either
    // This allows the build to complete
    return null as unknown as ReturnType<typeof createBrowserClient<Database>>
  }

  console.log('Supabase client created successfully')
  return createBrowserClient<Database>(supabaseUrl!, supabaseKey!)
}

// Singleton instance for client-side use
let client: ReturnType<typeof createClient> | null = null

export function getSupabaseClient() {
  if (!client) {
    client = createClient()
  }
  return client
}
