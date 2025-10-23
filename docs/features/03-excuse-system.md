# Excuse System

The excuse system allows users to request exemption from penalties when they have valid reasons for not completing their daily deeds. This system ensures fair treatment while maintaining accountability through a supervisor-review process.

## Excuse Types

The system supports three types of excuses:

| Type | Description | Use Case |
|------|-------------|----------|
| **Sickness** | Health-related excuse | When the user is ill and unable to complete deeds |
| **Travel** | Away from home/normal routine | When the user is traveling and deeds are impractical |
| **Raining** | Weather-related difficulty | When weather conditions prevent deed completion |

## Excuse Submission Flow

### Step 1: User Enables Excuse Mode

- Toggle excuse mode **ON** in the app
- Prevents automatic penalty application
- User proceeds to submit excuse request

### Step 2: Excuse Request Form

The user fills out the excuse request form with the following information:

1. **Select date(s) for excuse** - Single or multiple dates can be selected
2. **Select excuse type** - Choose from Sickness, Travel, or Raining
3. **Specify which deed(s) couldn't be completed:**
   - **Option 1:** Select specific deeds from list (multi-select)
   - **Option 2:** Select "All deeds" checkbox
4. **Enter description/explanation** - Optional text field for additional context
5. **Submit for review** - Send the request to supervisor/admin

### Step 3: Review Process

Once submitted:

- Supervisor or Admin reviews the request
- Can **approve** or **reject** the excuse
- If rejected: Must provide a rejection reason
- User receives notification of the decision

### Step 4: Outcome

#### If Approved:

- Penalties waived for specified deeds on specified date(s)
- Excuse mode can remain ON or user can turn it OFF
- User notified: "Excuse approved for [deeds] on [date]"

#### If Rejected:

- Penalties applied retroactively (if excuse mode was ON)
- Excuse mode automatically turned OFF
- User notified with rejection reason

## Retroactive Excuses

Users can submit excuses for past dates:

- **Useful when:** User forgot to enable excuse mode
- **Effect:** If penalties already applied, approval waives them
- **Requirements:** Requires Admin/Supervisor review and approval

**Example Scenario:**
```
User forgot to enable excuse mode on Monday due to sudden illness.
Penalties were applied on Tuesday at noon.
User submits retroactive excuse on Tuesday afternoon.
If approved, Monday's penalties are waived and removed from balance.
```

## Excuse Management (Supervisor/Admin)

Supervisors and Admins have access to comprehensive excuse management tools:

### Features

- **View all pending excuses** - See all requests awaiting review
- **Filter options:**
  - By user
  - By date
  - By excuse type
  - By status (pending/approved/rejected)
- **Approve/Reject with one click** - Quick action buttons
- **Bulk approval option** - For multiple users (e.g., mass rain excuse for entire group)
- **Excuse history and statistics** - Track patterns and trends

### Management Dashboard

```
┌─────────────────────────────────────────────────┐
│ Excuse Management Dashboard                     │
├─────────────────────────────────────────────────┤
│ Filters: [User ▼] [Type ▼] [Date] [Status ▼]  │
├─────────────────────────────────────────────────┤
│ ☑ John Doe - Sickness - Jan 15 - [Approve][Reject] │
│ ☑ Jane Smith - Raining - Jan 15 - [Approve][Reject]│
│ ☑ Bob Wilson - Travel - Jan 14-16 - [Approve][Reject]│
├─────────────────────────────────────────────────┤
│ [Bulk Approve Selected]  [Export]              │
└─────────────────────────────────────────────────┘
```

## Best Practices

### For Users

1. **Enable excuse mode proactively** - Turn it on before the deadline passes
2. **Provide clear descriptions** - Help reviewers understand your situation
3. **Be specific with deeds** - Only select deeds you genuinely couldn't complete
4. **Submit early** - Don't wait until the last minute

### For Supervisors

1. **Review promptly** - Don't leave users waiting unnecessarily
2. **Be fair and consistent** - Apply the same standards to all users
3. **Provide clear rejection reasons** - Help users understand the decision
4. **Use bulk approval wisely** - For legitimate mass events (weather, holidays)

## Integration with Other Systems

The excuse system integrates with:

- **Penalty System** - Automatically waives or applies penalties based on excuse status
- **Notification System** - Sends alerts for excuse approval/rejection
- **User Management** - Tracks excuse patterns per user
- **Audit System** - Logs all excuse submissions and decisions

## Database Schema Reference

```sql
-- Excuse requests table
excuses
  - id
  - user_id (FK → users)
  - start_date
  - end_date
  - excuse_type (enum: sickness, travel, raining)
  - deeds_affected (json array or "all")
  - description (text)
  - status (enum: pending, approved, rejected)
  - reviewed_by (FK → users, nullable)
  - reviewed_at (timestamp, nullable)
  - rejection_reason (text, nullable)
  - created_at
  - updated_at
```

---

[← Back: Penalty System](02-penalty-system.md) | [Next: Payment System →](04-payment-system.md) | [Main README](../../README.md)
