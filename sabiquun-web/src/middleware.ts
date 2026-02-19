import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

function isValidUrl(url: string | undefined): boolean {
  if (!url) return false
  try {
    const parsed = new URL(url)
    return parsed.protocol === 'http:' || parsed.protocol === 'https:'
  } catch {
    return false
  }
}

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname

  // Validate environment variables
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!isValidUrl(supabaseUrl) || !supabaseKey) {
    // If Supabase is not configured, allow public routes and redirect dashboard to login
    const publicRoutes = ['/', '/login', '/forgot-password', '/unauthorized', '/account-inactive', '/features', '/contact', '/privacy', '/terms']
    const isPublicRoute = publicRoutes.some(route => pathname === route || pathname.startsWith('/api/'))

    if (!isPublicRoute) {
      const url = request.nextUrl.clone()
      url.pathname = '/login'
      return NextResponse.redirect(url)
    }

    return NextResponse.next()
  }

  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    supabaseUrl!,
    supabaseKey!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Get user session
  let user = null
  try {
    const {
      data: { user: userData },
    } = await supabase.auth.getUser()
    user = userData
  } catch (error) {
    console.error('Error getting user in middleware:', error)
    // If there's an error getting the user, treat as unauthenticated
  }

  // Public routes that don't require authentication
  const publicRoutes = ['/', '/login', '/forgot-password', '/unauthorized', '/account-inactive', '/features', '/contact', '/privacy', '/terms']
  const isPublicRoute = publicRoutes.some(route => pathname === route || pathname.startsWith('/api/'))

  // If user is not logged in and trying to access protected routes
  if (!user && !isPublicRoute) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    url.searchParams.set('redirectTo', pathname)
    return NextResponse.redirect(url)
  }

  // If user is logged in, check their role for dashboard access
  if (user && pathname.startsWith('/dashboard')) {
    console.log('Middleware - Checking dashboard access for user:', user.id)

    // Fetch user profile to get role
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('role, account_status')
      .eq('id', user.id)
      .single()

    console.log('Middleware - Profile fetch result:', { profile, error: profileError })

    if (!profile) {
      // If profile doesn't exist, redirect to unauthorized
      console.log('Middleware - No profile found, redirecting to unauthorized')
      const url = request.nextUrl.clone()
      url.pathname = '/unauthorized'
      return NextResponse.redirect(url)
    }

    // Check if user is allowed to access the admin panel
    const allowedRoles = ['admin', 'supervisor', 'cashier']
    if (!allowedRoles.includes(profile.role)) {
      // Regular users can't access the admin panel
      console.log('Middleware - User role not allowed:', profile.role)
      const url = request.nextUrl.clone()
      url.pathname = '/unauthorized'
      return NextResponse.redirect(url)
    }

    // Check if account is active
    if (profile.account_status !== 'active') {
      console.log('Middleware - Account not active:', profile.account_status)
      const url = request.nextUrl.clone()
      url.pathname = '/account-inactive'
      return NextResponse.redirect(url)
    }

    console.log('Middleware - Access granted for role:', profile.role)

    // Role-based route protection
    const adminOnlyRoutes = [
      '/dashboard/users',
      '/dashboard/deeds',
      '/dashboard/settings',
      '/dashboard/notifications',
      '/dashboard/content',
      '/dashboard/audit-logs',
    ]

    const cashierRoutes = ['/dashboard/payments', '/dashboard/penalties']
    const supervisorRoutes = ['/dashboard/reports', '/dashboard/excuses', '/dashboard/leaderboard']

    // Check admin-only routes
    if (adminOnlyRoutes.some(route => pathname.startsWith(route)) && profile.role !== 'admin') {
      const url = request.nextUrl.clone()
      url.pathname = '/dashboard'
      return NextResponse.redirect(url)
    }

    // Cashier can access payment and penalty routes
    if (cashierRoutes.some(route => pathname.startsWith(route))) {
      if (!['admin', 'cashier'].includes(profile.role)) {
        const url = request.nextUrl.clone()
        url.pathname = '/dashboard'
        return NextResponse.redirect(url)
      }
    }

    // Supervisor can access report and excuse routes
    if (supervisorRoutes.some(route => pathname.startsWith(route))) {
      if (!['admin', 'supervisor'].includes(profile.role)) {
        const url = request.nextUrl.clone()
        url.pathname = '/dashboard'
        return NextResponse.redirect(url)
      }
    }
  }

  // Redirect logged-in users away from login page
  if (user && pathname === '/login') {
    console.log('Middleware - Redirecting logged-in user from login to dashboard')
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  console.log('Middleware - Allowing access to:', pathname)
  return supabaseResponse
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
