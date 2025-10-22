# User Status & Membership

Users in the system have two key status dimensions: **Membership Status** and **Account Status**.

## Membership Status

Membership status determines penalty application rules and is primarily based on account age.

### New Member (0-30 days)

**Duration:** First 30 days from account creation

**Characteristics:**
- 🎓 Training period for learning the system
- 🚫 **No penalties applied** for missed deeds
- ✅ Full app access after admin approval
- 📚 Focus on building daily habit and understanding the app
- 📊 Statistics tracked but no financial consequences

**Purpose:**
- Give new users time to adjust to daily tracking
- Allow habit formation without financial pressure
- Reduce churn from early penalties

**Visual Indicator:**
- Badge: "New Member" or "Training Period"
- Color: Blue/Green
- Tooltip: "No penalties during first 30 days"

---

### Exclusive Member (1 month - 3 years)

**Duration:** Day 31 through 1,095 days (3 years)

**Characteristics:**
- 💪 Standard member with full accountability
- 💰 **Penalties applied** for missed deeds
- ✅ All features available
- 🏆 Eligible for leaderboard and achievements
- 📈 Full statistics and analytics tracking

**Purpose:**
- Core membership tier for active accountability
- Ensures consistent engagement through financial commitment

**Visual Indicator:**
- Badge: "Exclusive Member"
- Color: Gold/Yellow
- No special tooltip (standard membership)

---

### Legacy Member (3+ years)

**Duration:** 1,096 days (3 years) and beyond

**Characteristics:**
- 🌟 Long-term member status with special recognition
- 💎 Same rules as Exclusive members (penalties still apply)
- 🏅 Special badge and profile decoration
- 📊 Extended historical statistics
- 🎖️ Priority recognition in leaderboard

**Purpose:**
- Recognize and honor long-term commitment
- Encourage continued engagement
- Build community prestige

**Visual Indicator:**
- Badge: "Legacy Member" or "Veteran"
- Color: Purple/Platinum
- Tooltip: "Member for 3+ years"
- Special profile frame or icon

---

### Membership Status Calculation

#### Automatic Calculation
```javascript
// Runs daily via cron job
const accountAge = currentDate - user.created_at
const daysSinceJoining = Math.floor(accountAge / 86400000) // milliseconds to days

if (daysSinceJoining <= 30) {
  user.membership_status = 'new'
} else if (daysSinceJoining <= 1095) { // 3 years = 1095 days
  user.membership_status = 'exclusive'
} else {
  user.membership_status = 'legacy'
}
```

#### Manual Override (Admin Only)
Admins can manually upgrade membership status for special cases:
- Early graduation from training period (if user demonstrates readiness)
- Honorary legacy status for special contributors
- Reset to training period for returning inactive users

**Note:** Manual upgrades are logged in audit trail with reason.

---

## Account Status

Account status determines app access level and functionality.

### Pending

**Initial state for all new registrations.**

**Characteristics:**
- ⏳ Awaiting admin approval
- 🚫 Blocked from main app features
- ✅ **Can only view Rules & Policies page**
- 📧 Cannot submit reports, payments, or excuses

**Workflow:**
1. User completes registration form
2. Account created with status: `pending`
3. Admin receives notification: "New user registration"
4. Admin reviews user details
5. Admin approves or rejects

**User Experience:**
- Welcome screen: "Thank you for registering!"
- Message: "Your account is pending admin approval"
- Button: "View Rules & Policies" (accessible)
- Button: "Logout"
- Notification when approved/rejected

**Admin Notification:**
```
Title: New User Registration
Body: {user_name} ({email}) registered. Pending approval.
Action: Opens user management screen
```

---

### Active

**Normal operating status after approval.**

**Characteristics:**
- ✅ Normal app access
- ✅ All features available based on role
- ✅ Can submit reports, payments, excuses
- 📊 Full statistics tracking
- 🔔 Receives all notifications

**Activation:**
- Admin clicks "Approve" on pending user
- User receives "Welcome! Account Approved" notification
- User can immediately login and use app

**User Experience:**
- Full access to home screen
- All navigation menu items available
- Can interact with all features per role

---

### Suspended

**Manually suspended by admin for violations or other reasons.**

**Characteristics:**
- ⛔ Cannot submit reports or payments
- 👁️ Can view past data (read-only)
- 🚫 Cannot login until reactivated
- 📧 Receives suspension notification with reason

**Reasons for Suspension:**
- Policy violations
- Suspected fraudulent activity
- Requested break from system
- Dispute resolution in progress

**Workflow:**
1. Admin navigates to user profile
2. Admin clicks "Suspend User"
3. Admin provides suspension reason (required)
4. User account status → `suspended`
5. User logged out from all devices
6. User receives notification

**Reactivation:**
- Admin clicks "Reactivate" on user profile
- User receives "Account Reactivated" notification
- User can login again

**User Experience:**
- Login attempt shows: "Your account has been suspended. Contact admin for reactivation."
- In-app (if already logged in): "Your account has been suspended. You can view past data but cannot submit new reports."

---

### Auto-deactivated

**Automatically triggered when penalty balance reaches threshold.**

**Characteristics:**
- ⚠️ Penalty balance ≥ 500,000 shillings (configurable)
- 🚫 Cannot submit reports or payments
- 👁️ Can view past data (read-only)
- 📊 Can see penalty balance and payment history
- 🔑 **Requires admin manual reactivation** (even after paying)

**Trigger Logic:**
```javascript
// After penalty calculation or payment rejection
const balance = await getUserPenaltyBalance(userId)
const threshold = await getSetting('auto_deactivation_threshold') // 500,000

if (balance >= threshold) {
  user.account_status = 'auto_deactivated'
  await sendNotification(userId, 'account_deactivated')
}
```

**Warning System:**
Users receive warnings **before** auto-deactivation:
```javascript
const warningThresholds = await getSetting('warning_thresholds') // [400000, 450000]

if (warningThresholds.includes(balance)) {
  await sendNotification(userId, 'auto_deactivation_warning', {
    balance: balance,
    remaining: threshold - balance
  })
}
```

**Warning Notifications:**
- At 400,000: "⚠️ Account Deactivation Warning: Your balance is 400,000. Account will be deactivated at 500,000. Please pay immediately."
- At 450,000: "⚠️ URGENT: Account Deactivation Warning: Your balance is 450,000. Only 50,000 away from deactivation!"

**Reactivation Process:**
1. User pays enough to bring balance below threshold (optional)
2. User contacts admin
3. Admin reviews account and payment status
4. Admin manually reactivates account
5. User receives "Account Reactivated" notification
6. User can resume normal activity

**Rationale for Manual Reactivation:**
- Ensures admin oversight for high-penalty users
- Prevents system gaming
- Allows admin to verify payment or circumstances
- Provides opportunity for one-on-one support

---

## Excuse Mode Status

A special toggle that affects penalty application, separate from account status.

### Excuse Mode: OFF (Default)

**Behavior:**
- ✅ Automatic penalties applied at grace period end
- ✅ Normal accountability system active
- 📊 Standard workflow

### Excuse Mode: ON

**Behavior:**
- ⏸️ **No automatic penalties applied**
- ⚠️ Requires excuse submission with specific deed(s) mentioned
- 🔍 Supervisor/Admin approval required

**Workflow:**

1. **User Enables Excuse Mode**
   ```
   User toggles "Excuse Mode" to ON
   System stops automatic penalty calculation
   User proceeds to submit excuse request
   ```

2. **User Submits Excuse**
   ```
   Selects date(s) for excuse
   Selects excuse type (Sickness/Travel/Raining)
   Specifies affected deed(s) or "All deeds"
   Enters description (optional)
   Submits for review
   ```

3. **Supervisor/Admin Reviews**
   ```
   Receives notification of pending excuse
   Reviews user excuse request
   Approves or rejects with reason
   ```

4. **Outcome: Approved**
   ```
   Penalties waived for specified deeds on specified date(s)
   User notified: "Excuse approved for [deeds] on [date]"
   Excuse mode can remain ON or user turns OFF
   ```

5. **Outcome: Rejected**
   ```
   Penalties applied retroactively for all missed deeds
   Excuse mode automatically turned OFF
   User notified with rejection reason
   User balance updated with retroactive penalties
   ```

**Important Rules:**
- Excuse mode does NOT automatically waive penalties
- Excuse request MUST be submitted and approved
- Rejected excuses result in full retroactive penalties
- Users can submit retroactive excuses for past dates

**Use Cases:**
- User traveling for extended period (enable excuse mode, submit excuse)
- User sick for several days (enable excuse mode, submit excuse)
- User in region with heavy rain affecting prayers (enable excuse mode, submit excuse)

---

## Status Transition Diagram

```
NEW USER
    ↓ (registers)
PENDING
    ↓ (admin approves)
ACTIVE + NEW MEMBER (0-30 days, no penalties)
    ↓ (30 days pass)
ACTIVE + EXCLUSIVE MEMBER (penalties active)
    ↓ (3 years pass)
ACTIVE + LEGACY MEMBER
    ↓ (balance ≥ 500K)
AUTO-DEACTIVATED
    ↓ (admin reactivates)
ACTIVE
```

**Alternative paths:**
- ACTIVE → SUSPENDED (admin action) → ACTIVE (admin reactivates)
- Any status → REJECTED (admin rejects registration)

---

## Status Indicators in UI

### Home Screen Display
```
┌─────────────────────────────────────┐
│  👤 User Name                       │
│  🎓 New Member (12 days remaining)  │  ← Membership badge
│  ✅ Active                          │  ← Account status
│  🔕 Excuse Mode: OFF                │  ← Excuse mode status
└─────────────────────────────────────┘
```

### Profile Screen Display
```
┌─────────────────────────────────────┐
│  Membership Status                   │
│  🎓 New Member                       │
│  Training period - No penalties      │
│  Exclusive membership in 18 days     │
│                                      │
│  Account Status                      │
│  ✅ Active                           │
│                                      │
│  Member Since                        │
│  October 10, 2025 (12 days ago)     │
└─────────────────────────────────────┘
```

### Auto-Deactivation Warning Banner
```
┌─────────────────────────────────────┐
│  ⚠️ WARNING: High Penalty Balance   │
│  Your balance is 450,000 shillings  │
│  Account will be deactivated at     │
│  500,000. Please pay now!           │
│  [Pay Now]                          │
└─────────────────────────────────────┘
```

---

## Database Fields

### In `users` table:
```sql
membership_status VARCHAR(50) NOT NULL DEFAULT 'new'
  -- Values: 'new', 'exclusive', 'legacy'

account_status VARCHAR(50) NOT NULL DEFAULT 'pending'
  -- Values: 'pending', 'active', 'suspended', 'auto_deactivated'

excuse_mode BOOLEAN DEFAULT FALSE

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  -- Used for membership status calculation

approved_by UUID REFERENCES users(id)
  -- Admin who approved the user

approved_at TIMESTAMP
  -- When user was approved
```

---

[← Back: User Roles](02-user-roles.md) | [Next: Future Enhancements →](04-future-enhancements.md) | [Database Schema →](../database/01-schema.md)
