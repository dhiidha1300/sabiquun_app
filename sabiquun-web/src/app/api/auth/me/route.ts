import { NextResponse } from 'next/server'
import { cookies } from 'next/headers'
import { createServerClient } from '@supabase/ssr'

export async function GET() {
  try {
    const cookieStore = await cookies()

    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return cookieStore.getAll()
          },
          setAll(cookiesToSet) {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          },
        },
      }
    )

    // Get user from cookie
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      return NextResponse.json({ user: null, profile: null }, { status: 401 })
    }

    // Fetch profile
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .single()

    if (profileError) {
      console.error('API /auth/me - Profile error:', profileError)
      return NextResponse.json(
        { user, profile: null, error: profileError.message },
        { status: 200 }
      )
    }

    // Fetch user statistics (may not exist for all users)
    const { data: stats } = await supabase
      .from('user_statistics')
      .select('current_penalty_balance')
      .eq('user_id', user.id)
      .maybeSingle()

    const profileWithStats = {
      ...profile,
      user_statistics: stats || { current_penalty_balance: 0 }
    }

    return NextResponse.json({ user, profile: profileWithStats }, { status: 200 })
  } catch (error) {
    console.error('API /auth/me - Error:', error)
    return NextResponse.json(
      { user: null, profile: null, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
