# Flutter WhatsApp Verification UI Implementation

**Date**: February 4, 2026
**Phase**: 70 - WhatsApp Integration Enhancement (Flutter UI)

---

## Overview

This document describes the implementation of WhatsApp verification UI in the Flutter app's user management system, allowing admins to manage users' WhatsApp phone numbers and verification status.

---

## Changes Made

### File Modified

**File**: [sabiquun_app/lib/features/admin/presentation/pages/user_edit_page.dart](d:/sabiquun_app/sabiquun_app/lib/features/admin/presentation/pages/user_edit_page.dart)

### 1. Added State Variables

```dart
final _whatsappPhoneController = TextEditingController();
bool _whatsappVerified = false;
String? _originalWhatsappPhone;
bool _originalWhatsappVerified = false;
```

**Purpose**: Track WhatsApp phone number and verification status, along with original values for change detection.

---

### 2. Added WhatsApp Preferences Loading

**Function**: `_loadWhatsAppPreferences()`

```dart
Future<void> _loadWhatsAppPreferences() async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('user_notification_preferences')
        .select('whatsapp_phone, whatsapp_verified')
        .eq('user_id', widget.userId)
        .maybeSingle();

    if (response != null && mounted) {
      setState(() {
        _whatsappPhoneController.text = response['whatsapp_phone'] ?? '';
        _whatsappVerified = response['whatsapp_verified'] ?? false;
        _originalWhatsappPhone = response['whatsapp_phone'];
        _originalWhatsappVerified = response['whatsapp_verified'] ?? false;
      });
    }
  } catch (e) {
    debugPrint('Error loading WhatsApp preferences: $e');
  }
}
```

**Purpose**: Load existing WhatsApp preferences from `user_notification_preferences` table when user edit page opens.

**Called**: In `_loadUserData()` method

---

### 3. Added WhatsApp Preferences Saving

**Function**: `_saveWhatsAppPreferences()`

```dart
Future<void> _saveWhatsAppPreferences() async {
  try {
    final supabase = Supabase.instance.client;
    final whatsappPhone = _whatsappPhoneController.text.trim().isEmpty
        ? null
        : _whatsappPhoneController.text.trim();

    // Check if preferences exist
    final existing = await supabase
        .from('user_notification_preferences')
        .select('user_id')
        .eq('user_id', widget.userId)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await supabase
          .from('user_notification_preferences')
          .update({
            'whatsapp_phone': whatsappPhone,
            'whatsapp_verified': _whatsappVerified,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', widget.userId);
    } else {
      // Insert new
      await supabase
          .from('user_notification_preferences')
          .insert({
            'user_id': widget.userId,
            'whatsapp_phone': whatsappPhone,
            'whatsapp_verified': _whatsappVerified,
          });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save WhatsApp preferences: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Purpose**: Save WhatsApp preferences to database. Performs upsert (update if exists, insert if not).

**Called**: In `_saveChanges()` method when WhatsApp fields have changed.

---

### 4. Updated Change Detection

**Function**: `_hasChanges()`

```dart
bool _hasChanges() {
  if (_originalUser == null) return false;

  final hasUserChanges = _nameController.text != _originalUser!.name ||
      _emailController.text != _originalUser!.email ||
      _phoneController.text != (_originalUser!.phone ?? '') ||
      _selectedRole != _originalUser!.role ||
      _selectedMembershipStatus != _originalUser!.membershipStatus ||
      _selectedAccountStatus != _originalUser!.accountStatus;

  final hasWhatsAppChanges = _whatsappPhoneController.text != (_originalWhatsappPhone ?? '') ||
      _whatsappVerified != _originalWhatsappVerified;

  return hasUserChanges || hasWhatsAppChanges;
}
```

**Purpose**: Detect if WhatsApp preferences have changed to enable the save button.

---

### 5. Updated Save Logic

**Function**: `_saveChanges()`

**Changes**:
- Made function `async` to await WhatsApp preferences save
- Added WhatsApp change detection
- Calls `_saveWhatsAppPreferences()` if WhatsApp fields changed
- Shows success message for WhatsApp-only changes
- Handles case where only WhatsApp changed (no user data changes)

```dart
// Save WhatsApp preferences if changed
final hasWhatsAppChanges = _whatsappPhoneController.text != (_originalWhatsappPhone ?? '') ||
    _whatsappVerified != _originalWhatsappVerified;

if (hasWhatsAppChanges) {
  await _saveWhatsAppPreferences();
}

// Only send UpdateUserRequested if there are user data changes
if (name != null || email != null || phone != null || role != null ||
    membershipStatus != null || accountStatus != null) {
  context.read<AdminBloc>().add(UpdateUserRequested(...));
} else {
  // Only WhatsApp changes, show success
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('WhatsApp preferences updated successfully'),
      backgroundColor: Colors.green,
    ),
  );
}
```

---

### 6. Added WhatsApp UI Section

**Location**: Between phone field and role dropdown in the form

**Components**:

#### A. Section Header
```dart
Row(
  children: [
    const Icon(Icons.chat, color: Color(0xFF25D366)),
    const SizedBox(width: 8),
    Text(
      'WhatsApp Settings',
      style: Theme.of(context).textTheme.titleLarge,
    ),
  ],
)
```

#### B. WhatsApp Phone Number Input
```dart
TextFormField(
  controller: _whatsappPhoneController,
  decoration: InputDecoration(
    labelText: 'WhatsApp Phone Number',
    hintText: '+254712345678',
    helperText: 'International format with country code',
    border: const OutlineInputBorder(),
    prefixIcon: const Icon(Icons.phone, color: Color(0xFF25D366)),
    suffixIcon: _whatsappVerified
        ? const Icon(Icons.verified, color: Colors.green)
        : const Icon(Icons.pending, color: Colors.orange),
  ),
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!value.startsWith('+')) {
        return 'Phone number must start with + and country code';
      }
      if (value.length < 10) {
        return 'Phone number is too short';
      }
    }
    return null;
  },
)
```

**Features**:
- International format hint (+254712345678)
- Validation for + prefix and minimum length
- Visual indicator showing verified (✓) or pending (⏰) status
- WhatsApp green color for icon

#### C. Verification Toggle Switch
```dart
Card(
  child: SwitchListTile(
    title: const Text('WhatsApp Verified'),
    subtitle: Text(
      _whatsappVerified
          ? 'User can receive WhatsApp notifications'
          : 'User cannot receive WhatsApp notifications',
    ),
    value: _whatsappVerified,
    onChanged: _whatsappPhoneController.text.trim().isEmpty
        ? null
        : (value) {
            setState(() {
              _whatsappVerified = value;
            });
          },
    secondary: Icon(
      _whatsappVerified ? Icons.check_circle : Icons.cancel,
      color: _whatsappVerified ? Colors.green : Colors.grey,
    ),
  ),
)
```

**Features**:
- Disabled if no phone number entered
- Dynamic subtitle explaining the effect
- Visual icon showing verification state
- Green check for verified, grey cancel for unverified

#### D. Helper Text
```dart
if (_whatsappPhoneController.text.trim().isEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      'Enter a WhatsApp phone number to enable verification',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.orange,
          ),
    ),
  )
```

**Purpose**: Inform admin they need to enter a phone number before enabling verification.

---

## How to Use

### 1. Access User Edit Page

1. Open Flutter app as admin
2. Navigate to **Users** management page
3. Tap on any user to edit
4. User edit page opens

### 2. Set WhatsApp Phone Number

**Step 1**: Scroll to **WhatsApp Settings** section

**Step 2**: Enter phone number in international format:
- Format: `+[country code][number]`
- Example: `+254712345678`
- Must start with `+`
- Must be at least 10 characters

**Step 3**: Validation occurs on save:
- Red error if missing `+` prefix
- Red error if too short

### 3. Enable WhatsApp Verification

**Step 1**: After entering valid phone number, toggle **WhatsApp Verified** switch

**Step 2**: Status changes:
- **ON**: User can receive WhatsApp notifications
- **OFF**: User cannot receive WhatsApp notifications

**Visual Indicators**:
- ✓ Green icon = Verified
- ⏰ Orange icon = Pending/Not verified

### 4. Save Changes

**Step 1**: Scroll down to **Reason for Changes** section (appears automatically)

**Step 2**: Enter reason for WhatsApp changes

**Step 3**: Tap **Save Changes** button

**Result**:
- Green success message appears
- WhatsApp preferences saved to `user_notification_preferences` table
- User can now receive WhatsApp notifications from web admin

---

## Database Integration

### Table Used

**Table**: `user_notification_preferences`

**Columns Modified**:
- `whatsapp_phone` (VARCHAR 20) - Phone in international format
- `whatsapp_verified` (BOOLEAN) - Admin verification status
- `updated_at` (TIMESTAMP) - Last update time

### Upsert Logic

```sql
-- If preferences exist
UPDATE user_notification_preferences
SET whatsapp_phone = ?,
    whatsapp_verified = ?,
    updated_at = NOW()
WHERE user_id = ?;

-- If preferences don't exist
INSERT INTO user_notification_preferences (user_id, whatsapp_phone, whatsapp_verified)
VALUES (?, ?, ?);
```

---

## Validation Rules

### Phone Number Validation

1. **Optional Field**: Phone number can be empty
2. **Format Check**: If provided, must start with `+`
3. **Length Check**: If provided, must be at least 10 characters
4. **Example Valid Numbers**:
   - `+254712345678` (Kenya)
   - `+966551234567` (Saudi Arabia)
   - `+252612345678` (Somalia)

### Verification Toggle Rules

1. **Disabled State**: If phone number is empty
2. **Enabled State**: If phone number has value
3. **Purpose**: Admin explicitly approves user for WhatsApp notifications

---

## User Flow Example

### Scenario: Admin Enables WhatsApp for User

1. Admin opens user "Ahmed Hassan" for editing
2. Admin scrolls to WhatsApp Settings section
3. Admin enters phone: `+254712345678`
4. Phone input shows orange pending icon
5. Admin toggles "WhatsApp Verified" to ON
6. Phone input changes to green verified icon
7. Admin enters reason: "User requested WhatsApp notifications"
8. Admin taps Save Changes
9. Success message: "WhatsApp preferences updated successfully"
10. User can now receive WhatsApp messages from web admin

---

## Integration with Web Admin

### How It Works Together

1. **Flutter App** (Admin):
   - Admin enters `whatsapp_phone` and enables `whatsapp_verified`
   - Data saved to `user_notification_preferences` table

2. **Web Admin** (WhatsApp Page):
   - Loads users with `whatsapp_verified = true`
   - Shows verified users in recipient list
   - Sends WhatsApp messages to verified phone numbers

3. **Edge Function** (send-whatsapp-notification):
   - Processes pending messages from `whatsapp_logs`
   - Calls WhatsApp Cloud API
   - Updates delivery status

### Data Flow

```
Flutter App (Admin enters phone + verification)
    ↓
user_notification_preferences table
    ↓
Web Admin (loads verified users)
    ↓
whatsapp_logs table (queues messages)
    ↓
Edge Function (sends to WhatsApp API)
    ↓
WhatsApp Cloud API
    ↓
User receives WhatsApp message
```

---

## Error Handling

### Common Errors

#### 1. "Phone number must start with + and country code"
**Cause**: User entered phone without `+` prefix

**Fix**: Add `+` at the beginning (e.g., `+254712345678`)

#### 2. "Phone number is too short"
**Cause**: Phone number less than 10 characters

**Fix**: Enter complete phone number with country code

#### 3. "Failed to save WhatsApp preferences: ..."
**Cause**: Database error or permission issue

**Fix**: Check:
- Internet connection
- Database permissions
- Supabase configuration

---

## Testing Checklist

- [x] WhatsApp section appears in user edit page
- [x] Phone number input accepts international format
- [x] Validation shows error for invalid format
- [x] Verification toggle disabled without phone number
- [x] Verification toggle enabled with phone number
- [x] Visual indicators (✓/⏰) show correct status
- [x] Save button appears when changes made
- [x] WhatsApp preferences save to database
- [x] Success message shows after save
- [x] Data persists after page reload
- [x] Helper text appears when phone empty
- [x] Web admin can see verified users

---

## Security Notes

1. **Admin-Only Access**: Only admins can modify WhatsApp verification
2. **Manual Verification**: Admin must explicitly verify each phone number
3. **Audit Trail**: Reason required for all changes
4. **Phone Privacy**: Phone numbers stored securely in database
5. **RLS Policies**: Row-level security enforces access control

---

## Dependencies

- `package:supabase_flutter` - Database client
- `user_notification_preferences` table - Must exist in database
- WhatsApp Business Account - For actual message sending

---

## Files Modified

| File | Changes |
|------|---------|
| [user_edit_page.dart](d:/sabiquun_app/sabiquun_app/lib/features/admin/presentation/pages/user_edit_page.dart:1) | Added WhatsApp phone input, verification toggle, save logic |

---

## Related Documentation

- [WhatsApp Web Admin Implementation](./whatsapp-web-admin-implementation.md)
- [WhatsApp Integration Migration](d:/sabiquun_app/supabase/migrations/20250122_whatsapp_integration.sql)
- [WhatsApp Logs Migration](d:/sabiquun_app/supabase/migrations/20250203_whatsapp_logs.sql)

---

*Implementation Complete: February 4, 2026*
*Phase 70 - WhatsApp Flutter UI Enhancement*
