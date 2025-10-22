# Authentication Screens

This document outlines all authentication-related screens and user flows for the Sabiquun application.

---

## Login Screen

### UI Layout

```
┌─────────────────────────────────────┐
│                                     │
│         [App Logo/Icon]             │
│                                     │
│            Sabiquun                 │
│      Track Your Daily Deeds         │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Email                         │  │
│  │ [email input field]           │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Password                      │  │
│  │ [password input]       [👁]   │  │
│  └───────────────────────────────┘  │
│                                     │
│  ☐ Remember me                      │
│                                     │
│  [Forgot password?] →               │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        LOGIN                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Don't have an account? [Sign up]  │
│                                     │
│  ────────── Or ──────────          │
│                                     │
│  [🔵 Continue with Google]         │
│  [📱 Continue with Apple]          │
│  (Future Enhancement)              │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Email Input Field**: Text input for user email address
- **Password Input Field**: Secure text input with show/hide toggle icon
- **Show/Hide Toggle**: Eye icon button to reveal/mask password
- **Remember Me Checkbox**: Option to persist login session
- **Forgot Password Link**: Navigation to password recovery flow
- **Login Button**: Primary action button (disabled until fields validated)
- **Sign Up Link**: Navigation to registration screen
- **Social Auth Options**: Google/Apple OAuth buttons (optional future enhancement)

### Validation Rules

- Email: Valid email format required
- Password: Minimum 8 characters
- Show error messages inline below respective fields
- Disable login button until validation passes

### User Flow

1. User enters email and password
2. Optional: Check "Remember me"
3. Click "Login" button
4. System validates credentials
5. On success: Navigate to appropriate role dashboard
6. On failure: Show error message

---

## Sign Up Screen

### UI Layout

```
┌─────────────────────────────────────┐
│  [← Back]        Sign Up            │
│                                     │
│         [Profile Photo]             │
│      [Tap to upload photo]          │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Full Name                     │  │
│  │ [text input]                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌────────┬──────────────────────┐  │
│  │ +252 ▼ │ Phone Number         │  │
│  │        │ [number input]       │  │
│  └────────┴──────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Email Address                 │  │
│  │ [email input]                 │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Password                      │  │
│  │ [password input]       [👁]   │  │
│  └───────────────────────────────┘  │
│  [████████░░] Strong               │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Confirm Password              │  │
│  │ [password input]       [👁]   │  │
│  └───────────────────────────────┘  │
│                                     │
│  ☑ I agree to Terms & Conditions   │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        SIGN UP                │  │
│  └───────────────────────────────┘  │
│                                     │
│  Already have account? [Login]     │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Profile Photo Upload**: Optional circular image picker with camera/gallery options
- **Name Input Field**: Text input for full name
- **Phone Number Input**: Country code selector + number input field
  - Default country code: +252 (Somalia)
  - Dropdown to select other codes
- **Email Input Field**: Email format validation
- **Password Input Field**: Secure input with show/hide toggle
- **Password Strength Indicator**: Visual bar showing password strength
  - Weak (Red): < 8 characters
  - Medium (Yellow): 8-11 characters
  - Strong (Green): 12+ characters with mixed case/numbers
- **Confirm Password Field**: Must match password field
- **Terms Checkbox**: Required acceptance before signup
- **Sign Up Button**: Primary action (disabled until all validations pass)
- **Login Link**: Return to login screen

### Validation Rules

- Name: Minimum 2 characters, letters only
- Phone: Valid phone number format
- Email: Valid email format, unique in system
- Password: Minimum 8 characters, at least one uppercase, one lowercase, one number
- Confirm Password: Must exactly match password field
- Terms: Must be checked

### User Flow

1. User optionally uploads profile photo
2. User fills in all required fields
3. System validates each field on blur
4. User checks Terms & Conditions
5. Click "Sign Up" button
6. System creates account with "pending" status
7. Navigate to Pending Approval screen

---

## Pending Approval Screen

### UI Layout

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          [✓ Success Icon]           │
│                                     │
│      Thank You for Registering!     │
│                                     │
│    Your account is pending admin    │
│           approval review           │
│                                     │
│  You will receive a notification    │
│      once your account has been     │
│        approved by an admin         │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   View Rules & Policies       │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │         Logout                │  │
│  └───────────────────────────────┘  │
│                                     │
│                                     │
│   Need help? Contact support at     │
│       support@sabiquun.app          │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Success Icon**: Large checkmark or pending icon
- **Thank You Message**: Confirmation header text
- **Pending Status Message**: Explanation of approval process
- **Notification Promise**: Information about approval notification
- **View Rules & Policies Button**: Secondary action to review app guidelines
- **Logout Button**: Return to login screen
- **Support Contact**: Help text with contact information

### User Flow

1. Automatically shown after successful signup
2. User can view Rules & Policies while waiting
3. User can logout and return later
4. Admin approves account (separate admin flow)
5. User receives approval notification via email/push
6. User can login with credentials

---

## Forgot Password Screen

### UI Layout

```
┌─────────────────────────────────────┐
│  [← Back]    Forgot Password        │
│                                     │
│                                     │
│         [🔑 Lock Icon]              │
│                                     │
│       Reset Your Password           │
│                                     │
│  Enter your email address and we    │
│  will send you a link to reset      │
│          your password              │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Email Address                 │  │
│  │ [email input]                 │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │    Send Reset Link            │  │
│  └───────────────────────────────┘  │
│                                     │
│                                     │
│  [← Back to Login]                  │
│                                     │
└─────────────────────────────────────┘
```

### Success State

```
┌─────────────────────────────────────┐
│  [← Back]    Forgot Password        │
│                                     │
│                                     │
│         [✓ Success Icon]            │
│                                     │
│       Email Sent Successfully!      │
│                                     │
│  We've sent a password reset link   │
│  to your email address:             │
│                                     │
│       user@example.com              │
│                                     │
│  Please check your inbox and follow │
│  the instructions to reset your     │
│  password. The link expires in 1hr  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │      Back to Login            │  │
│  └───────────────────────────────┘  │
│                                     │
│  Didn't receive email?              │
│  [Resend Link]                      │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Back Button**: Return to login screen
- **Lock Icon**: Visual indicator for password reset
- **Instructions Text**: Clear explanation of process
- **Email Input Field**: Email address validation
- **Send Reset Link Button**: Primary action
- **Success Message**: Confirmation after email sent
- **Resend Link**: Option to request another email
- **Back to Login Link**: Return to main login

### Validation Rules

- Email: Valid format required
- Email: Must exist in system (show generic success either way for security)

### User Flow

1. User clicks "Forgot password?" on login screen
2. User enters email address
3. Click "Send Reset Link"
4. System sends email with reset token
5. Show success message
6. User checks email and clicks link
7. Opens Reset Password screen

---

## Reset Password Screen

### UI Layout

```
┌─────────────────────────────────────┐
│           Reset Password            │
│                                     │
│                                     │
│         [🔑 Lock Icon]              │
│                                     │
│      Create New Password            │
│                                     │
│  Enter a strong password for        │
│          your account               │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ New Password                  │  │
│  │ [password input]       [👁]   │  │
│  └───────────────────────────────┘  │
│  [████████░░] Strong               │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Confirm New Password          │  │
│  │ [password input]       [👁]   │  │
│  └───────────────────────────────┘  │
│                                     │
│  Password Requirements:             │
│  ✓ At least 8 characters           │
│  ✓ One uppercase letter            │
│  ✓ One lowercase letter            │
│  ✓ One number                      │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Reset Password            │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Lock Icon**: Security visual indicator
- **New Password Field**: Secure input with show/hide toggle
- **Password Strength Indicator**: Real-time strength visualization
  - Updates as user types
  - Color-coded: Red (Weak), Yellow (Medium), Green (Strong)
- **Confirm Password Field**: Matching validation
- **Requirements Checklist**: Dynamic checkmarks showing met requirements
- **Reset Password Button**: Primary action (enabled when valid)

### Validation Rules

- New Password Requirements:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - Optional: Special character
- Confirm Password: Must match new password exactly
- Token: Must be valid and not expired

### User Flow

1. User clicks reset link from email
2. System validates token (show error if expired/invalid)
3. User enters new password
4. System shows real-time strength feedback
5. User confirms password
6. Click "Reset Password"
7. System updates password
8. Show success message
9. Redirect to login screen

### Error Handling

- **Expired Token**: "This reset link has expired. Please request a new one."
- **Invalid Token**: "This reset link is invalid. Please request a new one."
- **Weak Password**: Disable button, highlight requirements
- **Mismatch**: "Passwords do not match"

---

## Navigation Map

```
Login Screen
  ├─→ Forgot Password Screen
  │     └─→ Reset Password Screen
  │           └─→ Login Screen (success)
  │
  ├─→ Sign Up Screen
  │     └─→ Pending Approval Screen
  │           └─→ Rules & Policies
  │
  └─→ Home Screen (based on role)
        ├─→ Normal User Dashboard
        ├─→ Supervisor Dashboard
        ├─→ Cashier Dashboard
        └─→ Admin Dashboard
```

---

## Related Documentation

- [Normal User Screens](./02-user-screens.md)
- [Supervisor Screens](./03-supervisor-screens.md)
- [Cashier Screens](./04-cashier-screens.md)
- [Admin Screens](./05-admin-screens.md)
- [Database Schema](../database/)
- [API Endpoints](../technical/)

---

*Last Updated: 2025-10-22*
