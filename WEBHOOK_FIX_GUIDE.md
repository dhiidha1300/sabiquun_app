# Fix: WhatsApp Webhook 401 "Missing authorization header" Error

## Problem
Supabase Edge Functions are requiring authentication, but webhooks from Facebook don't send auth headers.

---

## Solution 1: Deploy with No JWT Verification (Recommended)

### Step 1: Redeploy the function
```bash
cd d:/sabiquun_app
supabase functions deploy whatsapp-hook --no-verify-jwt
```

If `--no-verify-jwt` flag is not recognized, try:
```bash
supabase functions deploy whatsapp-hook
```

### Step 2: Test with CORRECTED URL

**IMPORTANT**: Your test URL was missing `&` before `hub.challenge`!

**Wrong**:
```
...5RGLthub.challenge=TEST123
```

**Correct**:
```
...5RGLthu&hub.challenge=TEST123
```

**Full correct URL**:
```
https://vrvlqitoyskyzoertfwz.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=e38HbLfbHQEFwAToHiS3qYdALyK21r6CjjzIt5RGLthu&hub.challenge=TEST123
```

Expected response: `TEST123`

---

## Solution 2: Check Supabase Dashboard Settings

### Go to Supabase Dashboard
1. Open https://app.supabase.com
2. Select your project
3. Go to **Settings** → **API**
4. Scroll down to **Edge Functions**
5. Check if there's a setting like "Require authentication for all functions"
6. If yes, **disable it** or add whatsapp-hook to exceptions

---

## Solution 3: Create Supabase Config File

Create `d:/sabiquun_app/supabase/config.toml`:

```toml
[functions.whatsapp-hook]
verify_jwt = false
```

Then redeploy:
```bash
supabase functions deploy whatsapp-hook
```

---

## Solution 4: Test with Anon Key (Diagnostic Only)

This won't fix Facebook webhook, but tests if the function works:

### Using curl:
```bash
curl -X GET \
  'https://vrvlqitoyskyzoertfwz.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=e38HbLfbHQEFwAToHiS3qYdALyK21r6CjjzIt5RGLthu&hub.challenge=TEST123' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

Replace `YOUR_ANON_KEY` with your anon key from Supabase Dashboard → Settings → API.

If this works but the plain URL doesn't, the issue is JWT verification.

---

## Solution 5: Alternative Webhook Endpoint

If Supabase doesn't allow public edge functions, you might need to:

1. Deploy the webhook to a different service (Vercel, Netlify, etc.)
2. Or use Supabase's REST API with RLS policies instead
3. Or use a proxy service

---

## Debugging Steps

### 1. Check Function Deployment

Go to Supabase Dashboard → Edge Functions → whatsapp-hook

Check:
- Status: Should be "Active"
- Last deployment: Should be recent
- Invocations: Check if GET requests appear here when you test

### 2. Check Function Logs

After testing the URL, go to:
Supabase Dashboard → Edge Functions → whatsapp-hook → Logs

Look for:
- Any log entries (means function executed)
- 401 errors (means gateway blocked before function)
- No logs (means request didn't reach function)

### 3. Check Environment Variables

Supabase Dashboard → Edge Functions → Secrets

Ensure `WHATSAPP_VERIFY_TOKEN` is set to:
```
e38HbLfbHQEFwAToHiS3qYdALyK21r6CjjzIt5RGLthu
```

### 4. Re-create Function from Scratch

If nothing works:

1. Delete the function:
   ```bash
   supabase functions delete whatsapp-hook
   ```

2. Redeploy:
   ```bash
   supabase functions deploy whatsapp-hook
   ```

3. Test immediately after deployment

---

## Expected Behavior

### Correct Test URL:
```
https://vrvlqitoyskyzoertfwz.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=e38HbLfbHQEFwAToHiS3qYdALyK21r6CjjzIt5RGLthu&hub.challenge=TEST123
```

### Expected Response:
```
TEST123
```

### Expected HTTP Status:
```
200 OK
```

### Expected Content-Type:
```
text/plain
```

---

## If Still Getting 401

The issue is at the **Supabase API Gateway level**, not your function code.

### Contact Supabase Support:

1. Go to https://supabase.com/dashboard/support
2. Describe the issue:
   ```
   Subject: Edge Function Webhook Requires Authentication

   My edge function "whatsapp-hook" returns 401 "Missing authorization header"
   when accessed via GET request without auth headers. This is needed for
   WhatsApp webhook verification from Meta/Facebook.

   Project: vrvlqitoyskyzoertfwz
   Function: whatsapp-hook
   Error: {"code":401,"message":"Missing authorization header"}

   How can I make this function publicly accessible for webhooks?
   ```

---

## Workaround: Use Deno Deploy Instead

If Supabase doesn't support public functions, deploy to Deno Deploy:

1. Go to https://dash.deno.com
2. Create new project
3. Upload the whatsapp-hook function
4. Get the public URL (no auth required)
5. Use that URL for Facebook webhook

This is a temporary solution until Supabase issue is resolved.

---

## Final Check Before Facebook

Once the manual test works (returns TEST123):

1. Copy the exact URL that worked
2. Go to Facebook Business Manager
3. Paste into Callback URL field
4. Paste token into Verify Token field
5. Click "Verify and save"

Should work immediately if manual test succeeded.

---

*Last updated: February 12, 2026*
