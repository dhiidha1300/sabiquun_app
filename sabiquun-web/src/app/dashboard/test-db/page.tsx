'use client'

import { useState } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { CheckCircle2, XCircle, AlertCircle } from 'lucide-react'

export default function TestDBPage() {
  const [results, setResults] = useState<any[]>([])
  const [loading, setLoading] = useState(false)

  const runTests = async () => {
    setLoading(true)
    setResults([])
    const supabase = getSupabaseClient()
    const testResults: any[] = []

    if (!supabase) {
      testResults.push({
        name: 'Supabase Client',
        status: 'error',
        message: 'Supabase client is null',
      })
      setResults(testResults)
      setLoading(false)
      return
    }

    // Test 1: Check auth via API
    try {
      const response = await fetch('/api/auth/me', {
        credentials: 'include',
        cache: 'no-store',
      })
      const data = await response.json()
      testResults.push({
        name: 'Authentication Check',
        status: data.user ? 'success' : 'error',
        message: data.user ? `Authenticated as: ${data.user.email} (Role: ${data.profile?.role})` : 'Not authenticated',
        data: data,
      })
    } catch (err) {
      testResults.push({
        name: 'Authentication Check',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 2: Count users
    try {
      console.log('🔍 Test - Querying users table...')
      const { data, error, count } = await supabase
        .from('users')
        .select('*', { count: 'exact' })
        .limit(5)

      console.log('🔍 Test - Users result:', { count, dataLength: data?.length, error })

      testResults.push({
        name: 'Users Table Query',
        status: error ? 'error' : (count === 0 ? 'warning' : 'success'),
        message: error
          ? `ERROR: ${error.message} (Code: ${error.code}, Hint: ${error.hint})`
          : count === 0
            ? 'No users found - database might be empty or RLS blocking'
            : `Found ${count} users, showing first ${data?.length || 0}`,
        data: data,
        count: count,
      })
    } catch (err) {
      console.error('❌ Test - Users query error:', err)
      testResults.push({
        name: 'Users Table Query',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 3: Count deeds_reports
    try {
      console.log('🔍 Test - Querying deeds_reports table...')
      const { data, error, count } = await supabase
        .from('deeds_reports')
        .select('*', { count: 'exact' })
        .limit(5)

      console.log('🔍 Test - Deeds reports result:', { count, dataLength: data?.length, error })

      testResults.push({
        name: 'Deeds Reports Table Query',
        status: error ? 'error' : (count === 0 ? 'warning' : 'success'),
        message: error
          ? `ERROR: ${error.message} (Code: ${error.code})`
          : count === 0
            ? 'No reports found - database might be empty'
            : `Found ${count} reports, showing first ${data?.length || 0}`,
        data: data,
        count: count,
      })
    } catch (err) {
      console.error('❌ Test - Deeds reports query error:', err)
      testResults.push({
        name: 'Deeds Reports Table Query',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 4: Count payments
    try {
      const { data, error, count } = await supabase
        .from('payments')
        .select('*', { count: 'exact' })
        .limit(5)

      testResults.push({
        name: 'Payments Table Query',
        status: error ? 'error' : 'success',
        message: error ? error.message : `Found ${count} payments, showing first ${data?.length || 0}`,
        data: data,
        count: count,
      })
    } catch (err) {
      testResults.push({
        name: 'Payments Table Query',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 5: Count excuses
    try {
      const { data, error, count } = await supabase
        .from('excuses')
        .select('*', { count: 'exact' })
        .limit(5)

      testResults.push({
        name: 'Excuses Table Query',
        status: error ? 'error' : 'success',
        message: error ? error.message : `Found ${count} excuses, showing first ${data?.length || 0}`,
        data: data,
        count: count,
      })
    } catch (err) {
      testResults.push({
        name: 'Excuses Table Query',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 6: RLS Policy Check
    try {
      console.log('🔍 Test - Checking RLS policies...')
      // Try to query with explicit error checking
      const { data: testUser, error: rlsError } = await supabase
        .from('users')
        .select('id, email, name, role')
        .limit(1)
        .maybeSingle()

      testResults.push({
        name: 'RLS Policy Check',
        status: rlsError ? 'error' : (testUser ? 'success' : 'warning'),
        message: rlsError
          ? `RLS might be blocking: ${rlsError.message}`
          : testUser
            ? `RLS policies allow access - Found user: ${testUser.email}`
            : 'No users in database',
        data: testUser,
      })
    } catch (err) {
      console.error('❌ Test - RLS check error:', err)
      testResults.push({
        name: 'RLS Policy Check',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    // Test 7: Check current user session
    try {
      const response = await fetch('/api/auth/me', {
        credentials: 'include',
        cache: 'no-store',
      })
      const sessionData = await response.json()

      testResults.push({
        name: 'Current Session Info',
        status: sessionData.user ? 'success' : 'warning',
        message: sessionData.user
          ? `Logged in as: ${sessionData.profile?.name || sessionData.user.email} (${sessionData.profile?.role})`
          : 'Not authenticated',
        data: sessionData,
      })
    } catch (err) {
      testResults.push({
        name: 'Current Session Info',
        status: 'error',
        message: err instanceof Error ? err.message : 'Unknown error',
      })
    }

    console.log('✅ All tests complete')
    setResults(testResults)
    setLoading(false)
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Database Connection Test</h1>
        <p className="text-muted-foreground mt-1">
          Test database connectivity and RLS policies
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Run Database Tests</CardTitle>
          <CardDescription>
            This will test your connection to Supabase and check if Row Level Security (RLS) policies are blocking queries
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Button onClick={runTests} disabled={loading}>
            {loading ? 'Running Tests...' : 'Run Tests'}
          </Button>
        </CardContent>
      </Card>

      {results.length > 0 && (
        <div className="space-y-4">
          {results.map((result, index) => (
            <Card key={index} className={result.status === 'error' ? 'border-destructive' : ''}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  {result.status === 'success' && <CheckCircle2 className="h-5 w-5 text-green-500" />}
                  {result.status === 'error' && <XCircle className="h-5 w-5 text-destructive" />}
                  {result.status === 'warning' && <AlertCircle className="h-5 w-5 text-yellow-500" />}
                  {result.name}
                </CardTitle>
                <CardDescription>{result.message}</CardDescription>
              </CardHeader>
              {result.data && (
                <CardContent>
                  <details>
                    <summary className="cursor-pointer text-sm font-medium mb-2">
                      Show raw data ({result.count !== undefined ? `${result.count} total` : 'click to expand'})
                    </summary>
                    <pre className="bg-muted p-4 rounded-md overflow-auto text-xs">
                      {JSON.stringify(result.data, null, 2)}
                    </pre>
                  </details>
                </CardContent>
              )}
            </Card>
          ))}
        </div>
      )}

      {results.length > 0 && (
        <Alert>
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            <strong>Common Issues:</strong>
            <ul className="list-disc list-inside mt-2 space-y-1">
              <li>If counts are 0 but no errors: Database is empty OR RLS policies are blocking access</li>
              <li>If you see "JWT expired" or "Invalid JWT": Authentication token issue</li>
              <li>If you see "permission denied": RLS policies are blocking your role</li>
              <li>If all tests pass with data: Database is working correctly!</li>
            </ul>
          </AlertDescription>
        </Alert>
      )}
    </div>
  )
}
