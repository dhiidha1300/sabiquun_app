# WhatsApp Webhook Verification Troubleshooting

**Issue**: "The callback URL or verify token couldn't be validated" error in Facebook

---

## Quick Fix (Most Common)

**Edge functions must be redeployed after setting environment variables!**

### Step 1: Redeploy the Function

```bash
supabase functions deploy whatsapp-hook
```

This is the **#1 cause** of verification failures. Environment variables set in the Supabase Dashboard are only loaded when the function is deployed.

### Step 2: Test the Endpoint

Open this URL in your browser (replace with your values):

```
https://YOUR_PROJECT.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=YOUR_TOKEN&hub.challenge=TEST123
```

**Expected response**: `TEST123` (just the plain text)

If you get:
- `Forbidden` → Token mismatch
- `500 Internal Server Error` → Function error
- Other error → Check function logs

### Step 3: Check Function Logs

In Supabase Dashboard:
1. Go to Edge Functions → whatsapp-hook
2. Click "Logs" tab
3. Try the verification again
4. Look for the detailed debug output:

```
=== Webhook Verification Request ===
Mode: subscribe
Received Token Length: 64
Expected Token Length: 64
Received Token (first 20 chars): 6OPkySATwbV52KlmEfwT
Expected Token (first 20 chars): 6OPkySATwbV52KlmEfwT
Tokens Match: true
Challenge: TEST123
Mode Check: true
✅ Webhook verified successfully
```

---

## Common Issues and Fixes

### Issue 1: Token Mismatch

**Symptom**: Logs show `Tokens Match: false`

**Causes**:
1. **Extra spaces** in the token (copy-paste issue)
2. **Different token** in Supabase vs Facebook
3. **Environment variable not loaded** (forgot to redeploy)

**Fix**:
1. Go to Supabase Dashboard → Edge Functions → Secrets
2. Copy the `WHATSAPP_VERIFY_TOKEN` value
3. Paste it in Facebook webhook configuration
4. **Important**: No extra spaces, quotes, or line breaks!
5. Redeploy the function: `supabase functions deploy whatsapp-hook`

### Issue 2: Environment Variable Not Loaded

**Symptom**: Logs show `Expected Token (first 20 chars): sabiquun_whatsapp_we`

This means the `WHATSAPP_VERIFY_TOKEN` env variable is not set, so it's using the default fallback.

**Fix**:
1. Go to Supabase Dashboard → Edge Functions → Secrets
2. Add secret:
   - Name: `WHATSAPP_VERIFY_TOKEN`
   - Value: Your secure token (e.g., generate a random 64-char string)
3. Click "Save"
4. **CRITICAL**: Redeploy the function
   ```bash
   supabase functions deploy whatsapp-hook
   ```
5. Use the **same token** in Facebook webhook configuration

### Issue 3: Wrong Callback URL

**Symptom**: 404 Not Found or connection timeout

**Fix**:
Check that your callback URL is exactly:
```
https://YOUR_PROJECT_ID.supabase.co/functions/v1/whatsapp-hook
```

Common mistakes:
- ❌ `https://supabase.com/...`
- ❌ `...functions/whatsapp-hook` (missing `/v1/`)
- ❌ `...functions/v1/whatsapp-webhook` (wrong function name)
- ✅ `...functions/v1/whatsapp-hook`

### Issue 4: Function Deployed Before Setting Env Variable

**Symptom**: Token verification fails even though everything looks correct

**Root cause**: You deployed the function before setting the `WHATSAPP_VERIFY_TOKEN` environment variable.

**Fix**:
1. Ensure the secret is set in Supabase Dashboard
2. **Redeploy** the function:
   ```bash
   supabase functions deploy whatsapp-hook
   ```

---

## Step-by-Step Verification Process

### 1. Generate a Secure Token

Use a password generator or run:
```bash
openssl rand -hex 32
```

Example output: `6OPkySATwbV52KlmEfwTGqKvYiLw85xV31c4wOV1mqoU6sYTH6QwYPpy7Rg9SlWh`

### 2. Set Environment Variable

In Supabase Dashboard → Edge Functions → Secrets:
- Name: `WHATSAPP_VERIFY_TOKEN`
- Value: (paste your generated token)
- Click "Save"

### 3. Deploy the Function

```bash
cd d:/sabiquun_app
supabase functions deploy whatsapp-hook
```

**Wait for deployment to complete!**

### 4. Test Manually

Open in browser (replace `YOUR_PROJECT` and `YOUR_TOKEN`):
```
https://YOUR_PROJECT.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=YOUR_TOKEN&hub.challenge=HELLO_WORLD
```

Should display: `HELLO_WORLD`

### 5. Configure Facebook Webhook

In Meta Business Manager → WhatsApp → Configuration → Webhook:

1. **Callback URL**: `https://YOUR_PROJECT.supabase.co/functions/v1/whatsapp-hook`
2. **Verify Token**: (paste the exact same token from step 1)
3. Click "Verify and save"

### 6. Subscribe to Webhook Fields

After verification succeeds, subscribe to:
- ✅ `messages`
- ✅ `message_status`

---

## Debug Checklist

Run through this checklist if verification fails:

- [ ] Environment variable `WHATSAPP_VERIFY_TOKEN` is set in Supabase
- [ ] Function has been deployed **after** setting the env variable
- [ ] Token in Facebook **exactly matches** token in Supabase (no spaces, quotes, etc.)
- [ ] Callback URL is correct: `https://YOUR_PROJECT.supabase.co/functions/v1/whatsapp-hook`
- [ ] Manual test URL returns the challenge text
- [ ] Function logs show the verification request
- [ ] Function logs show "Tokens Match: true"

---

## Still Not Working?

### Check Edge Function Logs

1. Go to Supabase Dashboard → Edge Functions → whatsapp-hook → Logs
2. Trigger verification in Facebook
3. Look for errors in real-time

Common log errors:

**Error: "Expected Token (first 20 chars): sabiquun_whatsapp_we"**
→ Env variable not set or function not redeployed

**Error: "Tokens Match: false"**
→ Token mismatch between Facebook and Supabase

**No logs appearing at all**
→ Wrong callback URL or function not deployed

### Generate New Token

If all else fails, start fresh:

1. Generate a new token:
   ```bash
   openssl rand -hex 32
   ```

2. Update in Supabase Dashboard → Edge Functions → Secrets:
   - Delete old `WHATSAPP_VERIFY_TOKEN`
   - Add new `WHATSAPP_VERIFY_TOKEN` with new token

3. Redeploy:
   ```bash
   supabase functions deploy whatsapp-hook
   ```

4. Update in Facebook with the new token

5. Try verification again

---

## Testing After Successful Verification

Once verified, test the full flow:

1. Send a WhatsApp message from your app
2. Check message status in web admin (should show "sent")
3. Open the message on your phone
4. Refresh web admin (should show "delivered" → "read")

If webhooks still don't update status:
- Check that webhook is **subscribed** to `messages` and `message_status` fields
- Check whatsapp-hook logs for incoming POST requests
- Verify `whatsapp_logs` table has `whatsapp_message_id` saved

---

## Reference: Function Code

The webhook function checks:

```typescript
// Line 14: Load env variable with fallback
const VERIFY_TOKEN = Deno.env.get('WHATSAPP_VERIFY_TOKEN') || 'sabiquun_whatsapp_webhook_token'

// Line 26-28: Extract query parameters
const mode = url.searchParams.get('hub.mode')
const token = url.searchParams.get('hub.verify_token')
const challenge = url.searchParams.get('hub.challenge')

// Line 33: Verify mode and token
if (mode === 'subscribe' && token === VERIFY_TOKEN) {
  // Return challenge to verify webhook
  return new Response(challenge, {
    status: 200,
    headers: { 'Content-Type': 'text/plain' }
  })
}
```

If `mode === 'subscribe'` AND `token === VERIFY_TOKEN`, it returns the challenge.

Otherwise, it returns 403 Forbidden.

---

*Last updated: February 12, 2026*
