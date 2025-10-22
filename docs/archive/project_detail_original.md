Complete Application Specification
Good Deeds Tracking App with Flutter & Supabase

1. APPLICATION OVERVIEW
Purpose: Track daily Islamic good deeds with financial accountability system
Tech Stack:

Frontend: Flutter
Backend: Supabase (PostgreSQL, Auth, Storage)
Push Notifications: Firebase Cloud Messaging (FCM)
Email Service: Mailgun (configurable by admin)
File Storage: Supabase Storage
Export Formats: PDF & Excel

Core Concept:

Users track 10 daily deeds with customizable targets
Missing deeds incur financial penalties (5,000 shillings per deed)
Penalty per 0.1 deed = 500 shillings
Grace period until 12 PM next day
Admin approval system for new users
Multiple user roles with distinct permissions


2. USER ROLES & PERMISSIONS
Normal User

Submit daily deed reports (draft/submit)
View own statistics and detailed deed breakdown
Submit excuse requests (specify which deeds)
Submit payment claims (full/partial)
Toggle excuse mode status
View rules and policies (accessible even when pending approval)
Receive notifications (deadlines, penalties, payments)

Supervisor

View all users' reports and statistics
Manage leaderboard and special tags
View/export reports (PDF/Excel)
Send daily report reminder notifications (manual)
Approve/reject excuse requests
View deed compliance analytics by category
Cannot view payments or financial data

Cashier

All Normal User permissions
View payment history (all users)
Approve/reject payment claims
Manually adjust user penalty balances
View user penalty balances and payment status
Clear penalties (partial/full)

Admin

Full system access
User management (approve, suspend, deactivate, upgrade membership)
Deed template management (add/edit/remove deeds, change targets)
Configure system settings (penalty amounts, grace period, rest days)
Configure notification templates and schedules
Configure payment methods
Adjust penalties manually
Edit individual deed values in submitted reports
View complete analytics dashboard
Manage rest days calendar
Export reports (PDF/Excel)
View audit logs
Force app update configuration
Email service configuration


3. USER STATUS & MEMBERSHIP
Membership Status (Auto-calculated based on created_at or manually upgraded by Admin)
New Member (0-30 days):

Training period
No penalties applied
Full app access after approval
Learning system and building habit

Exclusive Member (1 month - 3 years):

Standard member with full accountability
Penalties applied for missed deeds
All features available

Legacy Member (3+ years):

Long-term member status
Special recognition in app
Same rules as Exclusive members

Account Status
Pending:

New registration awaiting admin approval
Blocked from main app
Can only view Rules & Policies page
Admin receives notification of new registration

Active:

Normal app access
All features available based on role
Reports, payments, and deeds trackable

Suspended:

Manually suspended by Admin
Cannot submit reports or payments
Can view past data (read-only)
Cannot login until reactivated

Auto-deactivated:

Penalty balance ≥ 500,000 shillings (configurable)
Cannot submit reports or payments
Requires Admin manual reactivation
User receives warning at configurable thresholds (e.g., 400K, 450K)

Excuse Mode Status
Excuse Mode Toggle:

User can enable/disable excuse mode
When enabled: No automatic penalties applied
Requires excuse submission with specific deed(s) mentioned
Supervisor/Admin approves or rejects excuse
If approved: Penalties waived for specified deeds
If rejected: Penalties applied retroactively


4. DEED SYSTEM (CORE FEATURE)
Default 10 Daily Deeds
#Deed NameCategoryValue TypePossible Values1Fajr PrayerFara'idBinary0 or 12Duha PrayerSunnahBinary0 or 13Dhuhr PrayerFara'idBinary0 or 14Juz of QuranSunnahBinary0 or 15Asr PrayerFara'idBinary0 or 16Sunnah PrayersSunnahFractional0, 0.1, 0.2, ..., 1.07Maghrib PrayerFara'idBinary0 or 18Isha PrayerFara'idBinary0 or 19AthkarSunnahBinary0 or 110WitrSunnahBinary0 or 1
Category Breakdown:

Fara'id (Obligatory): 5 deeds (5 daily prayers)
Sunnah (Recommended): 5 deeds (Duha, Juz, Sunnah Prayers, Athkar, Witr)

Note on Sunnah Prayers:

10 different Sunnah prayers combined as one deed
0.1 = 1 Sunnah prayer completed
1.0 = All 10 Sunnah prayers completed
Users familiar with this system (no helper text needed)

Deed Management (Admin)
Admin Capabilities:

Add new deeds beyond default 10
Edit existing deed properties (name, category, value type)
Change deed sort order
Deactivate deeds (not delete - preserve historical data)
When new deed added: Daily target automatically increases
System default deeds can be modified but flagged as system deeds

Deed Template Properties:

Deed name (e.g., "Fajr Prayer")
Deed key (unique identifier, e.g., "fajr_prayer")
Category (Fara'id/Sunnah)
Value type (Binary/Fractional)
Sort order (display order in report form)
Is active (can be deactivated)
Is system default (flag for original 10 deeds)

Daily Reporting Rules
Report Period:

Day starts: Midnight (00:00)
Day ends: 11:59 PM (23:59)
Grace period: Until 12 PM (noon) next day (configurable by admin)
Single timezone for entire system

Reporting Constraints:

One report per day
Can save as draft (including offline drafts)
Draft auto-saves when offline, syncs when online
Draft expires/deleted automatically after grace period ends
Once submitted: Report locked (no user edits)
Admin can edit submitted reports (logged in audit trail)
Past dates disabled after grace period ends (unless admin enables)

Rest Days:

Admin configures rest days via calendar
No deed submissions allowed on rest days
No penalties applied on rest days
All deeds disabled in report form
Users can view rest day schedule in advance

Report Form UI:

Display all active deeds in sort order
Binary deeds: Toggle/Checkbox UI
Fractional deeds: Slider with 0.1 increments (0.0 - 1.0)
Real-time total calculation as user fills form
Visual indicator for Fara'id vs Sunnah (different colors/icons)
Penalty preview if total < target (e.g., "2 deeds missed = 10,000 penalty")
Category breakdown: "5/5 Fara'id, 3.5/5 Sunnah"
Save as draft button
Submit button (with confirmation dialog)

Deed Calculation Examples
Example 1: Full Compliance

All 5 Fara'id prayers: 5.0
Duha, Juz, Athkar, Witr: 4.0
Sunnah Prayers: 1.0
Total: 10.0 deeds ✅ No penalty

Example 2: Partial Completion

Fajr, Dhuhr, Asr, Maghrib, Isha: 5.0
Duha, Athkar: 2.0
Sunnah Prayers: 0.5
Juz, Witr: 0.0
Total: 7.5 deeds ❌ Penalty: 2.5 × 5,000 = 12,500 shillings

Example 3: Near Perfect

All deeds except Sunnah Prayers (0.8 instead of 1.0): 9.8
Total: 9.8 deeds ❌ Penalty: 0.2 × 5,000 = 1,000 shillings


5. PENALTY SYSTEM
Penalty Calculation
Base Rate:

5,000 shillings per full deed missed (configurable by admin)
500 shillings per 0.1 deed missed
Calculated as: (Target - Actual) × 5,000

Examples:

0.1 missing = 500 shillings
0.5 missing = 2,500 shillings
1.0 missing = 5,000 shillings
2.0 missing = 10,000 shillings
10.0 missing (no report) = 50,000 shillings

Penalty Trigger Time:

Calculated once at 12 PM (after grace period ends)
Applied automatically by system
Not applied if:

User is New member (first 30 days)
Day is designated rest day
User has approved excuse for that day
User submitted report meeting/exceeding target



Penalty Accumulation
Cumulative Balance:

All unpaid penalties accumulate
User sees current total balance
Balance displayed on home screen
Warning notifications at configurable thresholds

Auto-deactivation:

Triggered when balance ≥ 500,000 shillings (configurable)
Account status changes to "Auto-deactivated"
User cannot submit reports or payments
User receives notification
Admin must manually reactivate account
Warning notifications before threshold (e.g., at 400K, 450K)

Penalty Management (Admin/Cashier)
Manual Adjustments:

Admin can add penalties manually (with reason)
Admin can remove penalties (with reason)
Admin can waive penalties (with reason)
Admin can edit penalty amounts
All changes logged in audit trail

Penalty Details Stored:

User ID
Related report ID (if applicable)
Amount
Date incurred
Status (Paid/Unpaid/Waived)
Paid amount (for tracking partial payments)
Waived by (Admin/Cashier ID)
Waived reason
Timestamps


6. EXCUSE SYSTEM
Excuse Types

Sickness - Health-related excuse
Travel - Away from home/normal routine
Raining - Weather-related difficulty

Excuse Submission Flow
Step 1: User Enables Excuse Mode

Toggle excuse mode ON in app
Prevents automatic penalty application
User proceeds to submit excuse request

Step 2: Excuse Request Form

Select date(s) for excuse
Select excuse type (Sickness/Travel/Raining)
Specify which deed(s) couldn't be completed:

Option 1: Select specific deeds from list (multi-select)
Option 2: Select "All deeds" checkbox


Enter description/explanation (optional text field)
Submit for review

Step 3: Review Process

Supervisor or Admin reviews request
Can approve or reject
If rejected: Must provide rejection reason
User receives notification of decision

Step 4: Outcome

If Approved:

Penalties waived for specified deeds on specified date(s)
Excuse mode can remain ON or user can turn OFF
User notified: "Excuse approved for [deeds] on [date]"


If Rejected:

Penalties applied retroactively (if excuse mode was ON)
Excuse mode automatically turned OFF
User notified with rejection reason



Retroactive Excuses

Users can submit excuses for past dates
Useful if user forgot to enable excuse mode
If penalties already applied, approval waives them
Requires Admin/Supervisor review and approval

Excuse Management (Supervisor/Admin)

View all pending excuses
Filter by user, date, type, status
Approve/Reject with one click
Bulk approval option (for multiple users, e.g., mass rain excuse)
Excuse history and statistics


7. PAYMENT SYSTEM
Payment Methods
Default Methods:

ZAAD (Mobile Money)
eDahab (Mobile Money)

Admin Configuration:

Add new payment methods
Edit method names and display names
Activate/deactivate methods
Set sort order for dropdown display
System stores methods in database for future API integration

Payment Submission Flow (User)
Step 1: Navigate to Payment Screen

User views current penalty balance
Sees breakdown of penalties (by date/amount)
Oldest penalties highlighted (FIFO payment application)

Step 2: Payment Form

Select payment method from dropdown
Choose payment type:

Full Payment: Pays entire balance (amount pre-filled)
Partial Payment: User enters custom amount


Enter reference number (optional, e.g., transaction ID)
Review payment summary

Step 3: Submit Payment

User clicks "Pay" button
Confirmation dialog: "Are you sure you want to submit payment of [amount]?"
On confirmation, payment status: Pending

Step 4: Thank You Screen

"Payment is being processed"
"Proof of payment might be needed"
"You will be notified once payment is reviewed"
Return to home button

Step 5: Notification

Admin/Cashier receives notification: "New payment submitted by [User]"
User waits for approval

Payment Review Flow (Admin/Cashier)
Payment Dashboard:

View all pending payments
Filter by user, date, amount, status
Search by reference number
Sort by submission date

Review Actions:

Approve Payment:

Verify payment externally (check mobile money account)
Click "Approve" in app
Amount deducted from user's penalty balance (FIFO)
User receives notification: "Payment of [amount] approved"
Payment status: Approved


Reject Payment:

Enter rejection reason
Click "Reject"
User receives notification with reason
Payment status: Rejected
Amount remains in user's penalty balance



Manual Balance Clearing:

Admin/Cashier can manually reduce user balance
Useful for:

Cash payments received in person
Adjustments/corrections
Forgiveness/grace


Enter amount to clear
Enter reason/notes
Confirm action
Logged in audit trail
User receives notification

Payment Application (FIFO)
Oldest Penalties First:
When user pays 30,000 and has these penalties:

Jan 5: 10,000 (unpaid)
Jan 8: 15,000 (unpaid)
Jan 12: 20,000 (unpaid)

Payment Distribution:

Jan 5 penalty: Fully paid (10,000) → Status: Paid
Jan 8 penalty: Fully paid (15,000) → Status: Paid
Jan 12 penalty: Partially paid (5,000) → Remaining: 15,000
Total balance after payment: 15,000

Database Records:

Create penalty_payments entries linking payment to penalties
Track amount applied to each penalty
Update penalty status and paid_amount fields

Payment History
User View:

List of all payments submitted
Status badges (Pending/Approved/Rejected)
Amount, date, payment method
Reference number
Reviewer name (if reviewed)
Download receipt option (PDF)

Admin/Cashier View:

All users' payment history
Advanced filters and search
Export to Excel/PDF
Analytics: Total received, pending amount, approval rate


8. NOTIFICATION SYSTEM
Notification Infrastructure
Push Notifications: Firebase Cloud Messaging (FCM)
Email Notifications: Mailgun (configurable by admin in settings)
In-App Notifications: Notification bell icon with badge count
Notification Types
1. Deadline Reminder

Trigger: Scheduled by admin (e.g., 9 PM daily)
Recipient: All active users who haven't submitted today's report
Title: "Reminder: Submit Today's Deeds"
Body: "You have until 12 PM tomorrow to submit today's report. Current progress: {progress}"
Action: Opens report submission screen

2. Penalty Incurred

Trigger: Automatic at 12 PM when penalty calculated
Recipient: User who incurred penalty
Title: "Penalty Applied"
Body: "Penalty of {amount} shillings applied for {missed_deeds} missed deeds on {date}. Current balance: {balance}"
Action: Opens payment screen

3. Payment Submitted (to Admin/Cashier)

Trigger: User submits payment
Recipient: All Admins and Cashiers
Title: "New Payment Submission"
Body: "{user_name} submitted payment of {amount} shillings. Pending review."
Action: Opens payment review screen

4. Payment Approved (to User)

Trigger: Admin/Cashier approves payment
Recipient: User who submitted payment
Title: "Payment Approved ✅"
Body: "Your payment of {amount} shillings has been approved. New balance: {balance}"
Action: Opens payment history

5. Payment Rejected (to User)

Trigger: Admin/Cashier rejects payment
Recipient: User who submitted payment
Title: "Payment Rejected"
Body: "Your payment of {amount} was rejected. Reason: {reason}. Please resubmit."
Action: Opens payment screen

6. Payment Reminder

Trigger: Scheduled by admin (e.g., weekly) if balance > threshold
Recipient: Users with high penalty balance
Title: "Payment Reminder"
Body: "Your penalty balance is {balance} shillings. Please clear your dues to avoid account deactivation."
Action: Opens payment screen

7. Auto-Deactivation Warning

Trigger: Balance reaches configurable threshold (e.g., 400K, 450K)
Recipient: User approaching deactivation
Title: "⚠️ Account Deactivation Warning"
Body: "Your balance is {balance}. Account will be deactivated at 500,000. Please pay immediately."
Action: Opens payment screen

8. Account Deactivated

Trigger: Balance reaches 500K threshold
Recipient: Deactivated user
Title: "Account Deactivated"
Body: "Your account has been deactivated due to penalty balance of {balance}. Contact admin for reactivation."
Action: Opens contact/support screen

9. Account Reactivated

Trigger: Admin reactivates account
Recipient: Reactivated user
Title: "Account Reactivated ✅"
Body: "Your account has been reactivated by admin. You can now submit reports."
Action: Opens home screen

10. New User Registration (to Admin)

Trigger: New user signs up
Recipient: All Admins
Title: "New User Registration"
Body: "{user_name} ({email}) registered. Pending approval."
Action: Opens user management screen

11. User Approved (to User)

Trigger: Admin approves new user
Recipient: Approved user
Title: "Welcome! Account Approved ✅"
Body: "Your account has been approved. You can now start tracking your daily deeds!"
Action: Opens home screen

12. User Rejected (to User)

Trigger: Admin rejects registration
Recipient: Rejected user (email only)
Title: "Registration Rejected"
Body: "Your registration was not approved. Reason: {reason}. Contact admin for more info."
Action: None (email only)

13. Rest Day Announcement

Trigger: Scheduled by admin (e.g., day before rest day)
Recipient: All active users
Title: "Rest Day Tomorrow"
Body: "Tomorrow ({date}) is a rest day. No reports needed, no penalties."
Action: None

14. Excuse Approved

Trigger: Supervisor/Admin approves excuse
Recipient: User who submitted excuse
Title: "Excuse Approved ✅"
Body: "Your excuse for {deeds} on {date} has been approved. Penalties waived."
Action: Opens excuse history

15. Excuse Rejected

Trigger: Supervisor/Admin rejects excuse
Recipient: User who submitted excuse
Title: "Excuse Rejected"
Body: "Your excuse for {date} was rejected. Reason: {reason}. Penalties applied."
Action: Opens excuse history

16. Manual Report Reminder (Supervisor)

Trigger: Supervisor sends manually
Recipient: Selected users or all users
Title: Custom (set by Supervisor)
Body: Custom (set by Supervisor)
Action: Opens report submission screen

17. Grace Period Ending Soon

Trigger: Scheduled (e.g., 11 AM - 1 hour before grace period ends)
Recipient: Users with pending drafts or no submission for yesterday
Title: "⏰ Grace Period Ending Soon"
Body: "You have 1 hour left to submit yesterday's report. Submit now to avoid penalty."
Action: Opens report submission screen

Notification Configuration (Admin)
Template Management:

View all notification templates
Edit title and body text
Use placeholders: {user_name}, {amount}, {date}, {balance}, etc.
Enable/disable specific notifications
Cannot delete system default templates

Schedule Management:

Set time for scheduled notifications (deadline reminders, payment reminders)
Set frequency (daily, weekly, monthly)
Set conditions (e.g., payment reminder only if balance > X)
Enable/disable schedules
Create custom manual notification templates

Email Configuration:

Configure Mailgun API credentials
Set sender email and name
Test email sending
Enable/disable email notifications per type
Email template customization (HTML templates)

Notification UI (User)
Notification Center:

Bell icon with unread count badge
List of all notifications (newest first)
Mark as read/unread
Delete notification
Filter by type
Clear all read notifications

Notification Preferences:

Enable/disable push notifications
Enable/disable email notifications
Choose notification sound
Quiet hours (mute notifications during specific times)


9. USER INTERFACE SCREENS
Authentication Screens
Login Screen

Email input field
Password input field (with show/hide toggle)
"Remember me" checkbox
"Forgot password?" link
"Login" button
"Don't have an account? Sign up" link
Social auth options (optional future enhancement)

Sign Up Screen

Profile photo upload (optional)
Name input field
Phone number input field (with country code selector)
Email input field
Password input field (with strength indicator)
Confirm password field
"I agree to Terms & Conditions" checkbox
"Sign Up" button
"Already have account? Login" link

Pending Approval Screen

Shows after successful sign-up
"Thank you for registering!" message
"Your account is pending admin approval"
"You will receive notification once approved"
"View Rules & Policies" button
Logout button

Forgot Password Screen

Email input field
"Send Reset Link" button
Success message: "Reset link sent to your email"
"Back to Login" link

Reset Password Screen (opened from email link)

New password field
Confirm password field
"Reset Password" button
Password strength indicator

Normal User Screens
Home Screen

Header:

Profile photo (circular)
User name and membership status badge
Notification bell icon with badge count


Penalty Balance Card:

Large display of current balance
Color-coded (green if low, yellow if medium, red if high)
"Pay Now" button


Today's Progress Card:

Circular progress indicator: "7.5/10 deeds"
Category breakdown: "5/5 Fara'id | 2.5/5 Sunnah"
Status: "Grace period ends in 3 hours" (if applicable)
"Submit Report" button (if not submitted)
"View Report" button (if submitted)


Recent Reports Section:

Title: "Last 5 Reports"
List of 5 most recent reports:

Date
Total deeds (e.g., "8.5/10")
Status badge (Submitted/Draft)
Penalty amount (if any)


"View All Reports" button


Special Tags Section (if applicable):

"🏆 Fajr Champion" badge (if eligible)
Other achievement badges


Floating Action Button (FAB):

Large "+" button
Action: Opens report submission screen



Report Submission Screen

Header:

Date selector (default: today, but can select past dates if enabled)
"Save Draft" button (top right)
Close button


Deed List:

Display all active deeds in sort order
Each deed shows:

Deed name
Category icon/badge (Fara'id/Sunnah)
Binary: Checkbox/Toggle
Fractional: Slider (0.0 - 1.0 with 0.1 steps) + numeric display




Real-Time Summary Card (bottom sheet):

Total deeds: "7.5/10"
Fara'id: "5/5" ✅
Sunnah: "2.5/5" ❌
Missing: "2.5 deeds"
Penalty preview: "12,500 shillings" (if applicable)
Color-coded progress bar


Action Buttons:

"Save as Draft" (secondary button)
"Submit Report" (primary button)
Confirmation dialog on submit: "Submit report for {date}? You cannot edit after submission."



Reports Screen

Header:

Title: "My Reports"
Filter icon (opens filter drawer)
Export icon (download as PDF/Excel)


Filter Options:

Date range selector
Status filter (All/Submitted/Draft)
Penalty filter (All/With Penalty/No Penalty)


Reports List:

Grouped by month
Each report card shows:

Date
Total deeds with progress bar
Fara'id and Sunnah breakdown
Penalty amount (if any)
Status badge
Tap to view details




Report Details (bottom sheet or new screen):

Date and submission time
Individual deed values (list)
Category totals
Penalty calculation breakdown
Edit button (admin only, visible if admin viewing)



Deed Breakdown Screen

Header:

Title: "Deed Analytics"
Date range selector (This Week/This Month/All Time)


Individual Deed Stats:

Each deed shows:

Deed name
Completion rate (e.g., "Fajr: 28/30 days - 93%")
Progress bar
Trend indicator (improving/declining)
Heatmap calendar view (optional)




Category Summary:

Fara'id compliance: "92% (138/150 deeds)"
Sunnah compliance: "78% (117/150 deeds)"
Charts/graphs



Payment Screen

Current Balance Card:

Large display of total penalty balance
"Last updated: {timestamp}"


Penalty Breakdown:

List of unpaid penalties:

Date incurred
Amount
Related report link


Oldest penalties highlighted (FIFO)


Payment Form:

Payment method dropdown (ZAAD/eDahab/etc.)
Payment type selector:

Radio button: Full Payment ({full_amount})
Radio button: Partial Payment


Amount input field (if partial)
Reference number field (optional)
"Submit Payment" button


Payment History Tab:

List of all submitted payments:

Date
Amount
Status badge (Pending/Approved/Rejected)
Payment method
Reference number
Download receipt button





Excuse Screen

Excuse Mode Toggle:

Large toggle switch
Explanation text: "Enable to prevent automatic penalties"


Submit Excuse Form:

Date selector (can select past dates)
Excuse type dropdown (Sickness/Travel/Raining)
Deed selector:

Multi-select checkboxes for specific deeds
"All deeds" checkbox


Description text area (optional)
"Submit Excuse" button


Excuse History:

List of all excuses:

Date
Type
Deeds affected
Status badge (Pending/Approved/Rejected)
Reviewer name
Tap for details





Settings Screen

Profile Section:

Profile photo (tap to change)
Name (tap to edit)
Email (non-editable, shows verified badge)
Phone (tap to edit)
Membership status badge (display only)


Security:

Change Password button
Active Sessions (list of devices)
Logout from all devices button


Notifications:

Push notifications toggle
Email notifications toggle
Notification sound selector
Quiet hours configuration


Display:

Language selector (future enhancement)
Theme (Light/Dark/System)


Support:

Rules & Policies
Contact Admin
About App
App Version (shows update available if needed)


Account:

Delete Account button (requires confirmation)



Rules & Policies Screen

Accessible to all users (including pending)
Rich text/HTML content
Sections:

About the App
Deed Guidelines
Penalty System Explained
Excuse Policy
Payment Instructions
Terms & Conditions
Privacy Policy


Admin can edit content

Supervisor Screens
All Normal User screens plus:
User Reports Dashboard

Header:

Title: "All User Reports"
Search bar (by user name/email)
Filter icon


User List:

Each user card shows:

Profile photo
Name
Membership status
Today's progress: "8/10"
Last report date
Compliance rate: "85%"
Tap to view user's full reports




Export Options:

Export all reports (date range)
Export specific user reports
Format: PDF or Excel



Leaderboard Management

Leaderboard View:

Tab selector: Daily/Weekly/Monthly/All-Time
Rank list:

Rank number
Profile photo
User name
Total




RetryAAContinuedeeds or average
- Special tags (Fajr Champion, etc.)
- Membership status badge

Special Tags Management:

"Fajr Champion" criteria configuration
Auto-assign based on rules (e.g., 90% Fajr completion for 30 days)
Manual assign/remove tags
Create custom achievement tags


Leaderboard Settings:

Filter by membership status
Exclude New members option
Reset period configuration



Manual Notification Screen

Compose Notification:

Title input field
Body text area (supports placeholders)
Recipient selector:

All users
Specific membership status
Specific users (multi-select)
Users with no submission today


"Send Now" or "Schedule" options
Preview button


Sent Notifications History:

List of manually sent notifications
Date, time, recipients count
View delivery status



Excuse Management Screen

Pending Excuses Tab:

List of all pending excuse requests
Each card shows:

User name and photo
Date(s) of excuse
Excuse type
Deeds affected (or "All deeds")
Description
Submitted date/time


Actions: Approve or Reject buttons
Bulk actions (select multiple, approve/reject all)


Excuse History Tab:

Filter by status (Approved/Rejected)
Filter by user
Filter by date range
Search functionality
Export to Excel



Analytics Dashboard

Overview Cards:

Total active users
Average deeds today
Compliance rate today
Top performer of the day


Deed Compliance Charts:

Line chart: Daily compliance rate over time
Bar chart: Compliance by deed type
Pie chart: Fara'id vs Sunnah distribution


User Engagement:

Active users trend
Report submission rate
Most missed deed
Best performing deed


Category Analytics:

Fara'id compliance: "88% average"
Sunnah compliance: "76% average"
Individual deed heatmap



Cashier Screens
All Normal User screens plus:
Payment Review Dashboard

Pending Payments Tab:

List of all pending payment submissions
Each card shows:

User name and photo
Amount submitted
Payment method
Reference number
Submission date/time
Current user balance


Actions:

View Details button
Approve button (green)
Reject button (red)




Payment Details Modal:

Full payment information
User's penalty breakdown
Payment distribution preview (FIFO)
Approve/Reject actions with confirmation
Reject requires reason input


Payment History Tab:

All approved/rejected payments
Filter by user, date, status
Search by reference number
Export to Excel/PDF



User Balance Management

User Search:

Search bar (by name/email/phone)
User list with current balances


User Balance Screen:

Selected user info
Current total balance (large display)
List of unpaid penalties with dates and amounts
Manual Balance Adjustment:

"Clear Penalty" button
Amount input (partial or full)
Reason/notes field (required)
Payment method dropdown (how they paid)
Confirm button


Action logged in audit trail
User receives notification



Payment Analytics

Overview Cards:

Total payments received (this month)
Pending payments count
Average payment amount
Total outstanding balance (all users)


Charts:

Payment trends over time
Payment method distribution
Top paying users



Admin Screens
All Normal User, Supervisor, and Cashier screens plus:
User Management Dashboard

Tabs:

Pending Approval
Active Users
Suspended Users
Auto-Deactivated Users


Pending Approval Tab:

List of users awaiting approval
Each card shows:

Profile photo
Name, email, phone
Registration date
"View Details" button
"Approve" button (green)
"Reject" button (red)


Bulk approve option


User Details Modal:

All user information
Approve/Reject actions
Rejection requires reason


Active Users Tab:

List of all active users
Search and filter options
Each user card shows:

Profile info
Membership status (with upgrade option)
Current balance
Last report date
Compliance rate


Actions dropdown:

View Full Profile
View Reports
View Payment History
Edit User
Suspend User
Manually Upgrade Membership
Delete User




User Profile Screen:

Complete user information
Edit all fields
Change role (User/Supervisor/Cashier/Admin)
Change membership status manually
View statistics
View audit log for this user



Deed Template Management

Deed List:

Display all deeds (active and inactive)
Drag to reorder (changes sort_order)
Each deed shows:

Deed name
Category badge
Value type badge
Active/Inactive toggle
System default flag
Edit button
Delete button (disabled for system deeds)




Add/Edit Deed Form:

Deed name input
Deed key input (auto-generated from name, editable)
Category dropdown (Fara'id/Sunnah)
Value type dropdown (Binary/Fractional)
Sort order number
Active toggle
Save button


Impact Warning:

When adding deed: "This will increase daily target to 11 deeds for all users"
When deactivating deed: "This will decrease daily target. Existing reports will not be affected."
Confirmation dialog



System Settings

General Settings:

Daily deed target (display only, calculated from active deeds)
Penalty per deed (5000 shillings) - editable
Grace period hours (12) - editable
Training period days (30) - editable
Auto-deactivation threshold (500000) - editable
Warning thresholds (JSON: [400000, 450000]) - editable


Payment Settings:

Payment methods management:

Add new method button
List of methods with edit/delete/reorder


Payment receipt template configuration


Notification Settings:

Email service configuration:

Mailgun API key
Mailgun domain
Sender email
Sender name
Test email button


FCM configuration:

Server key
Test notification button




Bulk Operations:

Enable/disable bulk report submission
Enable/disable offline draft saving


App Version Control:

Current app version
Minimum required version
Force update toggle
Update message customization
Platform-specific settings (iOS/Android)



Notification Template Management

Template List:

All notification templates grouped by type
Each template shows:

Template name
Type badge
Active/Inactive toggle
System default flag
Edit button
Cannot delete system templates




Edit Template Form:

Template title (supports placeholders)
Template body (supports placeholders)
Available placeholders list:

{user_name}
{amount}
{balance}
{date}
{deeds}
{penalty}
etc.


Preview section (with sample data)
Active toggle
Save button


Notification Schedules:

List of scheduled notifications
Each schedule shows:

Notification type
Scheduled time
Frequency
Conditions
Active/Inactive toggle


Edit schedule:

Time picker
Frequency selector (Daily/Weekly/Monthly)
Condition builder (e.g., "Only if balance > 100000")
Days of week selector (for weekly)
Active toggle





Rest Days Management

Calendar View:

Monthly calendar showing all rest days highlighted
Add rest day by clicking date
View upcoming rest days list


Add Rest Day Form:

Date picker (single or range)
Description field (e.g., "Eid al-Fitr")
Recurring option (annually)
Save button


Rest Days List:

All configured rest days
Edit/Delete options
Bulk import option (Excel/CSV)



Penalty Management

User Penalty Overview:

Search for user
User's penalty history
All penalties (paid/unpaid/waived)


Manual Penalty Actions:

Add penalty manually:

User selector
Amount input
Date
Reason field (required)
Confirm button


Remove penalty:

Select penalty from list
Reason field (required)
Confirm button


Waive penalty:

Select penalty from list
Reason field (required)
Confirm button


Edit penalty amount:

New amount input
Reason field (required)
Confirm button




All actions logged in audit trail

Report Management

Search Reports:

Search by user
Filter by date range
Filter by status


Edit Report:

View report details
Edit individual deed values:

Change any deed value
Reason field (required)
Recalculates total and penalties
Confirm button


Action logged in audit trail
User receives notification of changes



Analytics Dashboard (Enhanced)

User Metrics:

Total users by status:

Pending: 5
Active: 150
Suspended: 3
Auto-deactivated: 2


Users by membership:

New: 12
Exclusive: 120
Legacy: 18


Users at risk (approaching deactivation)
New registrations trend


Deed Metrics:

Total deeds submitted:

Today: 1,245
This week: 8,960
This month: 35,420
All time: 450,000


Average deeds per user:

Today: 8.3
This week: 8.5
This month: 8.7


Compliance rate:

Today: 65% (97/150 users met target)
This week: 72%
This month: 68%


Top performers list (highest average)
Lowest performers list (need attention)
Deed type distribution:

Fara'id: 88% compliance
Sunnah: 76% compliance


Individual deed analytics:

Most completed: Maghrib (95%)
Least completed: Duha (62%)
Heatmap by deed type




Financial Metrics:

Total penalties incurred:

This month: 2,500,000 shillings
All time: 35,000,000 shillings


Total payments received:

This month: 1,800,000 shillings
All time: 28,000,000 shillings


Outstanding balance (all users): 7,000,000 shillings
Pending payments:

Count: 15
Amount: 450,000 shillings


Payment method distribution (pie chart)
Payment trends (line chart)


Engagement Metrics:

Daily active users (DAU): 142/150 (95%)
Report submission rate: 89%
Average report submission time: 9:30 PM
Notification open rate: 78%
Average response time to notifications: 45 minutes


Excuse Metrics:

Pending excuses: 8
Approved vs rejected ratio: 85% approved
Most common excuse type: Sickness (45%)
Excuses by month (trend)


Export Options:

Export any metric to Excel/PDF
Date range selector
Custom report builder



Audit Log Viewer

Filter Options:

Date range
Action type (Penalty Adjusted/Deed Edited/User Suspended/etc.)
Performed by (admin/cashier selector)
Entity type (Penalty/Report/User/etc.)
User affected


Audit Log List:

Each entry shows:

Timestamp
Action description (e.g., "Penalty waived")
Performed by (admin name)
User affected
Entity type and ID
Old value → New value
Reason/notes


Expandable details
Export to Excel



Content Management

Rules & Policies Editor:

Rich text editor
Sections management (add/edit/delete/reorder)
Preview mode
Publish button
Version history


App Announcements:

Create announcement banner
Display on home screen for all users
Schedule start and end dates
Priority level
Dismissible or persistent




10. DATABASE SCHEMA (COMPLETE)
1. users
sqlCREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  photo_url TEXT,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
    -- Values: 'user', 'supervisor', 'cashier', 'admin'
  membership_status VARCHAR(50) NOT NULL DEFAULT 'new',
    -- Values: 'new', 'exclusive', 'legacy'
  account_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    -- Values: 'pending', 'active', 'suspended', 'auto_deactivated'
  excuse_mode BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_account_status ON users(account_status);
2. deed_templates
sqlCREATE TABLE deed_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deed_name VARCHAR(255) NOT NULL,
  deed_key VARCHAR(100) UNIQUE NOT NULL,
    -- e.g., 'fajr_prayer', 'duha_prayer'
  category VARCHAR(50) NOT NULL,
    -- Values: 'sunnah', 'faraid'
  value_type VARCHAR(50) NOT NULL,
    -- Values: 'binary', 'fractional'
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  is_system_default BOOLEAN DEFAULT FALSE,
    -- True for original 10 deeds, cannot be deleted
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deed_templates_active ON deed_templates(is_active);
CREATE INDEX idx_deed_templates_sort_order ON deed_templates(sort_order);
Default Records (inserted on system setup):
sqlINSERT INTO deed_templates (deed_name, deed_key, category, value_type, sort_order, is_system_default) VALUES
('Fajr Prayer', 'fajr_prayer', 'faraid', 'binary', 1, TRUE),
('Duha Prayer', 'duha_prayer', 'sunnah', 'binary', 2, TRUE),
('Dhuhr Prayer', 'dhuhr_prayer', 'faraid', 'binary', 3, TRUE),
('Juz of Quran', 'juz_quran', 'sunnah', 'binary', 4, TRUE),
('Asr Prayer', 'asr_prayer', 'faraid', 'binary', 5, TRUE),
('Sunnah Prayers', 'sunnah_prayers', 'sunnah', 'fractional', 6, TRUE),
('Maghrib Prayer', 'maghrib_prayer', 'faraid', 'binary', 7, TRUE),
('Isha Prayer', 'isha_prayer', 'faraid', 'binary', 8, TRUE),
('Athkar', 'athkar', 'sunnah', 'binary', 9, TRUE),
('Witr', 'witr', 'sunnah', 'binary', 10, TRUE);
3. deeds_reports
sqlCREATE TABLE deeds_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  report_date DATE NOT NULL,
  total_deeds DECIMAL(4,1) NOT NULL DEFAULT 0,
    -- Calculated sum, e.g., 9.5
  sunnah_count DECIMAL(4,1) NOT NULL DEFAULT 0,
    -- Calculated from deed entries
  faraid_count DECIMAL(4,1) NOT NULL DEFAULT 0,
    -- Calculated from deed entries
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
    -- Values: 'draft', 'submitted'
  submitted_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, report_date)
);

CREATE INDEX idx_deeds_reports_user_date ON deeds_reports(user_id, report_date);
CREATE INDEX idx_deeds_reports_date ON deeds_reports(report_date);
CREATE INDEX idx_deeds_reports_status ON deeds_reports(status);
4. deed_entries
sqlCREATE TABLE deed_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  report_id UUID NOT NULL REFERENCES deeds_reports(id) ON DELETE CASCADE,
  deed_template_id UUID NOT NULL REFERENCES deed_templates(id),
  deed_value DECIMAL(3,1) NOT NULL DEFAULT 0,
    -- 0, 1, or 0.1-1.0 for fractional
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(report_id, deed_template_id)
);

CREATE INDEX idx_deed_entries_report ON deed_entries(report_id);
CREATE INDEX idx_deed_entries_template ON deed_entries(deed_template_id);
5. penalties
sqlCREATE TABLE penalties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  report_id UUID REFERENCES deeds_reports(id),
    -- Nullable for manual penalties
  amount DECIMAL(10,2) NOT NULL,
  date_incurred DATE NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'unpaid',
    -- Values: 'unpaid', 'paid', 'waived'
  paid_amount DECIMAL(10,2) DEFAULT 0,
    -- Tracks partial payments
  waived_by UUID REFERENCES users(id),
    -- Admin/Cashier who waived
  waived_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_penalties_user ON penalties(user_id);
CREATE INDEX idx_penalties_status ON penalties(status);
CREATE INDEX idx_penalties_date ON penalties(date_incurred);
6. payments
sqlCREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(100) NOT NULL,
    -- e.g., 'ZAAD', 'eDahab'
  reference_number VARCHAR(255),
    -- Optional user-provided reference
  payment_type VARCHAR(50) NOT NULL,
    -- Values: 'full', 'partial'
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
    -- Values: 'pending', 'approved', 'rejected'
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_by UUID REFERENCES users(id),
    -- Admin/Cashier who reviewed
  reviewed_at TIMESTAMP,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_submitted_at ON payments(submitted_at);
7. penalty_payments
sqlCREATE TABLE penalty_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  penalty_id UUID NOT NULL REFERENCES penalties(id) ON DELETE CASCADE,
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  amount_applied DECIMAL(10,2) NOT NULL,
    -- Amount from this payment applied to this penalty
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_penalty_payments_penalty ON penalty_payments(penalty_id);
CREATE INDEX idx_penalty_payments_payment ON penalty_payments(payment_id);
8. excuses
sqlCREATE TABLE excuses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  report_date DATE NOT NULL,
  excuse_type VARCHAR(50) NOT NULL,
    -- Values: 'sickness', 'travel', 'raining'
  description TEXT,
  affected_deeds JSONB NOT NULL,
    -- Array of deed_template_ids or {"all": true}
    -- e.g., ["uuid1", "uuid2"] or {"all": true}
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
    -- Values: 'pending', 'approved', 'rejected'
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_by UUID REFERENCES users(id),
    -- Supervisor/Admin who reviewed
  reviewed_at TIMESTAMP,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_excuses_user ON excuses(user_id);
CREATE INDEX idx_excuses_status ON excuses(status);
CREATE INDEX idx_excuses_date ON excuses(report_date);
9. rest_days
sqlCREATE TABLE rest_days (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rest_date DATE NOT NULL UNIQUE,
  description VARCHAR(255),
    -- e.g., "Eid al-Fitr"
  is_recurring BOOLEAN DEFAULT FALSE,
    -- Repeats annually if true
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rest_days_date ON rest_days(rest_date);
10. settings
sqlCREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
    -- Stored as string, parsed based on data_type
  description TEXT,
  data_type VARCHAR(50) NOT NULL,
    -- Values: 'string', 'number', 'boolean', 'json'
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_settings_key ON settings(setting_key);
Default Settings:
sqlINSERT INTO settings (setting_key, setting_value, description, data_type) VALUES
('penalty_per_deed', '5000', 'Penalty amount per full deed missed (in shillings)', 'number'),
('grace_period_hours', '12', 'Hours after midnight for grace period', 'number'),
('training_period_days', '30', 'Days of training period for new members (no penalties)', 'number'),
('auto_deactivation_threshold', '500000', 'Penalty balance threshold for auto-deactivation', 'number'),
('warning_thresholds', '[400000, 450000]', 'Balance thresholds for warning notifications', 'json'),
('payment_methods', '["ZAAD", "eDahab"]', 'Available payment methods', 'json'),
('bulk_report_enabled', 'true', 'Enable bulk report submission feature', 'boolean'),
('force_update_enabled', 'false', 'Force app update for users', 'boolean'),
('minimum_app_version', '1.0.0', 'Minimum required app version', 'string'),
('mailgun_api_key', '', 'Mailgun API key for email service', 'string'),
('mailgun_domain', '', 'Mailgun domain', 'string'),
('sender_email', 'noreply@gooddeeds.app', 'Email sender address', 'string'),
('sender_name', 'Good Deeds App', 'Email sender name', 'string'),
('fcm_server_key', '', 'Firebase Cloud Messaging server key', 'string');
11. notification_templates
sqlCREATE TABLE notification_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  template_key VARCHAR(100) UNIQUE NOT NULL,
    -- e.g., 'deadline_reminder', 'penalty_incurred'
  title VARCHAR(255) NOT NULL,
    -- Supports placeholders: {user_name}, {amount}, etc.
  body TEXT NOT NULL,
    -- Supports placeholders
  notification_type VARCHAR(50) NOT NULL,
    -- e.g., 'deadline', 'payment', 'penalty', 'excuse'
  is_active BOOLEAN DEFAULT TRUE,
  is_system_default BOOLEAN DEFAULT TRUE,
    -- System templates cannot be deleted
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_templates_key ON notification_templates(template_key);
CREATE INDEX idx_notification_templates_type ON notification_templates(notification_type);
Default Templates (examples):
sqlINSERT INTO notification_templates (template_key, title, body, notification_type, is_system_default) VALUES
('deadline_reminder', 'Reminder: Submit Today''s Deeds', 'You have until 12 PM tomorrow to submit today''s report. Current progress: {progress}', 'deadline', TRUE),
('penalty_incurred', 'Penalty Applied', 'Penalty of {amount} shillings applied for {missed_deeds} missed deeds on {date}. Current balance: {balance}', 'penalty', TRUE),
('payment_approved', 'Payment Approved ✅', 'Your payment of {amount} shillings has been approved. New balance: {balance}', 'payment', TRUE),
('grace_period_ending', '⏰ Grace Period Ending Soon', 'You have 1 hour left to submit yesterday''s report. Submit now to avoid penalty.', 'deadline', TRUE),
('account_deactivated', 'Account Deactivated', 'Your account has been deactivated due to penalty balance of {balance}. Contact admin for reactivation.', 'account', TRUE);
12. notification_schedules
sqlCREATE TABLE notification_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  notification_template_id UUID NOT NULL REFERENCES notification_templates(id) ON DELETE CASCADE,
  scheduled_time TIME NOT NULL,
    -- Time of day to send (e.g., '21:00:00' for 9 PM)
  frequency VARCHAR(50) NOT NULL,
    -- Values: 'daily', 'weekly', 'monthly', 'once'
  days_of_week JSONB,
    -- For weekly: [0,1,2,3,4,5,6] where 0=Sunday
  conditions JSONB,
    -- e.g., {"balance_greater_than": 100000}
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_schedules_active ON notification_schedules(is_active);
CREATE INDEX idx_notification_schedules_time ON notification_schedules(scheduled_time);
13. notifications_log
sqlCREATE TABLE notifications_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_template_id UUID REFERENCES notification_templates(id),
    -- Null for manual notifications
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
    -- Rendered with actual values (no placeholders)
  notification_type VARCHAR(50) NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP
);

CREATE INDEX idx_notifications_log_user ON notifications_log(user_id);
CREATE INDEX idx_notifications_log_read ON notifications_log(is_read);
CREATE INDEX idx_notifications_log_sent_at ON notifications_log(sent_at);
14. audit_logs
sqlCREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    -- User affected by the action
  performed_by UUID NOT NULL REFERENCES users(id),
    -- Admin/Cashier who performed action
  action_type VARCHAR(100) NOT NULL,
    -- e.g., 'penalty_adjusted', 'deed_edited', 'user_suspended'
  entity_type VARCHAR(50) NOT NULL,
    -- e.g., 'penalty', 'report', 'user', 'deed_entry'
  entity_id UUID,
    -- ID of the affected entity
  old_value JSONB,
    -- Previous state
  new_value JSONB,
    -- New state
  description TEXT,
    -- Human-readable description
  reason TEXT,
    -- Reason provided by admin
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_performed_by ON audit_logs(performed_by);
CREATE INDEX idx_audit_logs_action_type ON audit_logs(action_type);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

```sql
15. password_reset_tokens
sqlCREATE TABLE password_reset_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_user ON password_reset_tokens(user_id);
```

### **16. user_sessions**
```sql
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(500) UNIQUE NOT NULL,
    -- JWT or session token
  device_info JSONB,
    -- {device_type, os, app_version, fcm_token}
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_sessions_user ON user_sessionsRetryAAContinue(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
```
### **17. user_statistics**
```sql
CREATE TABLE user_statistics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total_deeds DECIMAL(10,1) DEFAULT 0,
    -- Lifetime total deeds
  total_reports_submitted INTEGER DEFAULT 0,
  total_penalties_incurred DECIMAL(12,2) DEFAULT 0,
  total_penalties_paid DECIMAL(12,2) DEFAULT 0,
  current_penalty_balance DECIMAL(12,2) DEFAULT 0,
  average_daily_deeds DECIMAL(4,2) DEFAULT 0,
  best_streak_days INTEGER DEFAULT 0,
    -- Longest streak of meeting daily target
  current_streak_days INTEGER DEFAULT 0,
  fajr_completion_rate DECIMAL(5,2) DEFAULT 0,
    -- Percentage, e.g., 85.50
  faraid_completion_rate DECIMAL(5,2) DEFAULT 0,
  sunnah_completion_rate DECIMAL(5,2) DEFAULT 0,
  last_report_date DATE,
  last_calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_statistics_user ON user_statistics(user_id);
CREATE INDEX idx_user_statistics_balance ON user_statistics(current_penalty_balance);
CREATE INDEX idx_user_statistics_avg_deeds ON user_statistics(average_daily_deeds);
```

### **18. leaderboard**
```sql
CREATE TABLE leaderboard (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rank INTEGER NOT NULL,
  total_deeds DECIMAL(10,1) NOT NULL,
  average_deeds DECIMAL(4,2) NOT NULL,
  period_type VARCHAR(50) NOT NULL,
    -- Values: 'daily', 'weekly', 'monthly', 'all_time'
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  special_tags JSONB DEFAULT '[]',
    -- e.g., ["fajr_champion", "perfect_week"]
  calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, period_type, period_start, period_end)
);

CREATE INDEX idx_leaderboard_period ON leaderboard(period_type, period_start, period_end);
CREATE INDEX idx_leaderboard_rank ON leaderboard(rank);
CREATE INDEX idx_leaderboard_user ON leaderboard(user_id);
```

### **19. payment_methods**
```sql
CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  method_name VARCHAR(100) UNIQUE NOT NULL,
    -- e.g., 'zaad', 'edahab'
  display_name VARCHAR(100) NOT NULL,
    -- e.g., 'ZAAD', 'eDahab'
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER NOT NULL,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_methods_active ON payment_methods(is_active);
CREATE INDEX idx_payment_methods_sort ON payment_methods(sort_order);
```

**Default Records:**
```sql
INSERT INTO payment_methods (method_name, display_name, sort_order) VALUES
('zaad', 'ZAAD', 1),
('edahab', 'eDahab', 2);
```

### **20. special_tags**
```sql
CREATE TABLE special_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tag_key VARCHAR(100) UNIQUE NOT NULL,
    -- e.g., 'fajr_champion', 'perfect_month'
  display_name VARCHAR(100) NOT NULL,
    -- e.g., '🏆 Fajr Champion'
  description TEXT,
  criteria JSONB NOT NULL,
    -- e.g., {"deed_key": "fajr_prayer", "completion_rate": 90, "days": 30}
  auto_assign BOOLEAN DEFAULT TRUE,
    -- Automatically assign based on criteria
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_special_tags_active ON special_tags(is_active);
```

**Default Record:**
```sql
INSERT INTO special_tags (tag_key, display_name, description, criteria, auto_assign) VALUES
('fajr_champion', '🏆 Fajr Champion', 'Awarded for 90%+ Fajr prayer completion over 30 days', 
'{"deed_key": "fajr_prayer", "completion_rate": 90, "days": 30}', TRUE);
```

### **21. user_tags**
```sql
CREATE TABLE user_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES special_tags(id) ON DELETE CASCADE,
  awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  awarded_by UUID REFERENCES users(id),
    -- Null if auto-assigned
  expires_at TIMESTAMP,
    -- Null if permanent
  UNIQUE(user_id, tag_id)
);

CREATE INDEX idx_user_tags_user ON user_tags(user_id);
CREATE INDEX idx_user_tags_tag ON user_tags(tag_id);
```

### **22. app_content**
```sql
CREATE TABLE app_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_key VARCHAR(100) UNIQUE NOT NULL,
    -- e.g., 'rules_and_policies', 'about_app', 'terms_conditions'
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
    -- HTML or Markdown
  content_type VARCHAR(50) DEFAULT 'html',
    -- Values: 'html', 'markdown'
  is_published BOOLEAN DEFAULT TRUE,
  version INTEGER DEFAULT 1,
  updated_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_app_content_key ON app_content(content_key);
```

**Default Records:**
```sql
INSERT INTO app_content (content_key, title, content) VALUES
('rules_and_policies', 'Rules & Policies', '<h1>Welcome to Good Deeds App</h1><p>Track your daily Islamic good deeds...</p>'),
('about_app', 'About the App', '<p>This app helps Muslims track their daily good deeds...</p>'),
('terms_conditions', 'Terms & Conditions', '<p>By using this app, you agree to...</p>'),
('privacy_policy', 'Privacy Policy', '<p>We respect your privacy...</p>');
```

### **23. announcements**
```sql
CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  announcement_type VARCHAR(50) DEFAULT 'info',
    -- Values: 'info', 'warning', 'success', 'error'
  priority INTEGER DEFAULT 0,
    -- Higher number = higher priority
  is_dismissible BOOLEAN DEFAULT TRUE,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP,
    -- Null for permanent
  target_roles JSONB DEFAULT '["user", "supervisor", "cashier", "admin"]',
    -- Which roles should see this
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_announcements_active ON announcements(is_active);
CREATE INDEX idx_announcements_dates ON announcements(start_date, end_date);
```

### **24. user_announcement_dismissals**
```sql
CREATE TABLE user_announcement_dismissals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  dismissed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, announcement_id)
);

CREATE INDEX idx_user_announcement_dismissals_user ON user_announcement_dismissals(user_id);
```

---

## 11. KEY BUSINESS LOGIC & CALCULATIONS

### **Membership Status Auto-Calculation**

**Trigger:** Daily cron job or on-demand calculation

**Logic:**
```sql
-- Calculate membership status based on account age
UPDATE users 
SET membership_status = CASE
  WHEN CURRENT_DATE - created_at::date <= 30 THEN 'new'
  WHEN CURRENT_DATE - created_at::date <= 1095 THEN 'exclusive' -- 3 years
  ELSE 'legacy'
END
WHERE account_status = 'active';
```

### **Penalty Calculation**

**Trigger:** Daily at 12 PM (after grace period)

**Logic:**
```javascript
// For each user with no submitted report for yesterday
const yesterday = new Date();
yesterday.setDate(yesterday.getDate() - 1);

// Check if user should be penalized
const shouldPenalize = (
  user.membership_status !== 'new' && // Not in training period
  !isRestDay(yesterday) && // Not a rest day
  !hasApprovedExcuse(user.id, yesterday) && // No approved excuse
  !hasSubmittedReport(user.id, yesterday) // No report submitted
);

if (shouldPenalize) {
  // Calculate target (sum of active deeds)
  const target = await getActiveDeedsCount();
  
  // Get actual deeds submitted (or 0 if no report)
  const actual = await getUserDeedsForDate(user.id, yesterday) || 0;
  
  // Calculate missed deeds
  const missed = target - actual;
  
  if (missed > 0) {
    // Calculate penalty (5000 per deed, 500 per 0.1)
    const penaltyAmount = missed * 5000;
    
    // Create penalty record
    await createPenalty({
      user_id: user.id,
      amount: penaltyAmount,
      date_incurred: yesterday,
      status: 'unpaid'
    });
    
    // Update user statistics
    await updateUserBalance(user.id, penaltyAmount);
    
    // Check auto-deactivation threshold
    const balance = await getUserPenaltyBalance(user.id);
    const threshold = await getSetting('auto_deactivation_threshold');
    
    if (balance >= threshold) {
      await deactivateUser(user.id);
      await sendNotification(user.id, 'account_deactivated');
    } else {
      // Check warning thresholds
      const warnings = await getSetting('warning_thresholds');
      if (warnings.includes(balance)) {
        await sendNotification(user.id, 'auto_deactivation_warning');
      }
    }
    
    // Send penalty notification
    await sendNotification(user.id, 'penalty_incurred', {
      amount: penaltyAmount,
      missed_deeds: missed,
      date: yesterday,
      balance: balance
    });
  }
}
```

### **Payment Application (FIFO)**

**Trigger:** When admin/cashier approves payment

**Logic:**
```javascript
async function applyPayment(paymentId) {
  const payment = await getPayment(paymentId);
  let remainingAmount = payment.amount;
  
  // Get unpaid penalties ordered by date (oldest first)
  const penalties = await getUnpaidPenalties(payment.user_id, 'date_incurred ASC');
  
  for (const penalty of penalties) {
    if (remainingAmount <= 0) break;
    
    const unpaidAmount = penalty.amount - penalty.paid_amount;
    const amountToApply = Math.min(remainingAmount, unpaidAmount);
    
    // Create penalty_payment record
    await createPenaltyPayment({
      penalty_id: penalty.id,
      payment_id: payment.id,
      amount_applied: amountToApply
    });
    
    // Update penalty
    await updatePenalty(penalty.id, {
      paid_amount: penalty.paid_amount + amountToApply,
      status: (penalty.paid_amount + amountToApply >= penalty.amount) ? 'paid' : 'unpaid'
    });
    
    remainingAmount -= amountToApply;
  }
  
  // Update payment status
  await updatePayment(paymentId, {
    status: 'approved',
    reviewed_by: currentAdminId,
    reviewed_at: new Date()
  });
  
  // Update user statistics
  await recalculateUserBalance(payment.user_id);
  
  // Send notification to user
  await sendNotification(payment.user_id, 'payment_approved', {
    amount: payment.amount,
    balance: await getUserPenaltyBalance(payment.user_id)
  });
  
  // Check if user can be reactivated
  const balance = await getUserPenaltyBalance(payment.user_id);
  const user = await getUser(payment.user_id);
  
  if (user.account_status === 'auto_deactivated' && balance < threshold) {
    // User must still be manually reactivated by admin
    // Just notify admin that balance is now under threshold
    await notifyAdmins('user_eligible_for_reactivation', {
      user_id: payment.user_id,
      new_balance: balance
    });
  }
}
```

### **Report Submission & Deed Calculation**

**Trigger:** When user submits report

**Logic:**
```javascript
async function submitReport(reportId) {
  const report = await getReport(reportId);
  const deedEntries = await getDeedEntries(reportId);
  
  let totalDeeds = 0;
  let sunnahCount = 0;
  let faraidCount = 0;
  
  // Calculate totals
  for (const entry of deedEntries) {
    const template = await getDeedTemplate(entry.deed_template_id);
    totalDeeds += entry.deed_value;
    
    if (template.category === 'sunnah') {
      sunnahCount += entry.deed_value;
    } else if (template.category === 'faraid') {
      faraidCount += entry.deed_value;
    }
  }
  
  // Update report
  await updateReport(reportId, {
    total_deeds: totalDeeds,
    sunnah_count: sunnahCount,
    faraid_count: faraidCount,
    status: 'submitted',
    submitted_at: new Date()
  });
  
  // Update user statistics
  await updateUserStatistics(report.user_id);
  
  // Check for special tags (e.g., Fajr Champion)
  await checkAndAwardTags(report.user_id);
  
  // Update leaderboard
  await updateLeaderboard(report.user_id);
  
  return {
    success: true,
    total_deeds: totalDeeds,
    sunnah_count: sunnahCount,
    faraid_count: faraidCount
  };
}
```

### **User Statistics Recalculation**

**Trigger:** After report submission, payment approval, penalty incurred

**Logic:**
```javascript
async function recalculateUserStatistics(userId) {
  // Get all submitted reports
  const reports = await getSubmittedReports(userId);
  
  // Calculate totals
  const totalDeeds = reports.reduce((sum, r) => sum + r.total_deeds, 0);
  const totalReports = reports.length;
  const avgDeeds = totalReports > 0 ? (totalDeeds / totalReports) : 0;
  
  // Calculate streaks
  const streaks = calculateStreaks(reports);
  
  // Calculate Fajr completion rate
  const fajrTemplate = await getDeedTemplateByKey('fajr_prayer');
  const fajrEntries = await getDeedEntriesForUser(userId, fajrTemplate.id);
  const fajrRate = (fajrEntries.filter(e => e.deed_value === 1).length / totalReports) * 100;
  
  // Calculate category rates
  const faraidRate = await calculateCategoryRate(userId, 'faraid');
  const sunnahRate = await calculateCategoryRate(userId, 'sunnah');
  
  // Get financial data
  const penalties = await getUserPenalties(userId);
  const totalIncurred = penalties.reduce((sum, p) => sum + p.amount, 0);
  const totalPaid = penalties.reduce((sum, p) => sum + p.paid_amount, 0);
  const currentBalance = totalIncurred - totalPaid;
  
  // Update statistics table
  await updateOrCreateStatistics(userId, {
    total_deeds: totalDeeds,
    total_reports_submitted: totalReports,
    total_penalties_incurred: totalIncurred,
    total_penalties_paid: totalPaid,
    current_penalty_balance: currentBalance,
    average_daily_deeds: avgDeeds,
    best_streak_days: streaks.best,
    current_streak_days: streaks.current,
    fajr_completion_rate: fajrRate,
    faraid_completion_rate: faraidRate,
    sunnah_completion_rate: sunnahRate,
    last_report_date: reports[reports.length - 1]?.report_date,
    last_calculated_at: new Date()
  });
}
```

### **Fajr Champion Tag Assignment**

**Trigger:** Daily calculation or after report submission

**Logic:**
```javascript
async function checkFajrChampionTag(userId) {
  const tag = await getTagByKey('fajr_champion');
  const criteria = tag.criteria; // {deed_key: "fajr_prayer", completion_rate: 90, days: 30}
  
  // Get last 30 days of reports
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - criteria.days);
  
  const reports = await getUserReportsInDateRange(userId, startDate, new Date());
  
  // Get Fajr deed entries for these reports
  const fajrTemplate = await getDeedTemplateByKey(criteria.deed_key);
  const fajrEntries = await getDeedEntriesForReports(
    reports.map(r => r.id), 
    fajrTemplate.id
  );
  
  // Calculate completion rate
  const completedCount = fajrEntries.filter(e => e.deed_value === 1).length;
  const totalDays = reports.length;
  const completionRate = (completedCount / totalDays) * 100;
  
  // Check if user meets criteria
  if (completionRate >= criteria.completion_rate) {
    // Award tag if not already awarded
    const existingTag = await getUserTag(userId, tag.id);
    if (!existingTag) {
      await awardTag(userId, tag.id);
      await sendNotification(userId, 'tag_awarded', {
        tag_name: tag.display_name
      });
    }
  } else {
    // Remove tag if criteria no longer met
    await removeUserTag(userId, tag.id);
  }
}
```

### **Leaderboard Calculation**

**Trigger:** Daily calculation (midnight) or on-demand

**Logic:**
```javascript
async function updateLeaderboards() {
  const periodTypes = ['daily', 'weekly', 'monthly', 'all_time'];
  
  for (const periodType of periodTypes) {
    const {startDate, endDate} = getPeriodDates(periodType);
    
    // Get all active users
    const users = await getActiveUsers();
    const leaderboardData = [];
    
    for (const user of users) {
      // Get reports in period
      const reports = await getUserReportsInDateRange(user.id, startDate, endDate);
      
      if (reports.length === 0) continue;
      
      const totalDeeds = reports.reduce((sum, r) => sum + r.total_deeds, 0);
      const avgDeeds = totalDeeds / reports.length;
      
      // Get special tags
      const tags = await getUserActiveTags(user.id);
      
      leaderboardData.push({
        user_id: user.id,
        total_deeds: totalDeeds,
        average_deeds: avgDeeds,
        special_tags: tags.map(t => t.tag_key)
      });
    }
    
    // Sort by average deeds (descending)
    leaderboardData.sort((a, b) => b.average_deeds - a.average_deeds);
    
    // Assign ranks
    leaderboardData.forEach((data, index) => {
      data.rank = index + 1;
      data.period_type = periodType;
      data.period_start = startDate;
      data.period_end = endDate;
    });
    
    // Delete old leaderboard for this period
    await deleteLeaderboard(periodType, startDate, endDate);
    
    // Insert new leaderboard
    await insertLeaderboard(leaderboardData);
  }
}
```

### **Excuse Approval Impact**

**Trigger:** When supervisor/admin approves excuse

**Logic:**
```javascript
async function approveExcuse(excuseId, reviewerId) {
  const excuse = await getExcuse(excuseId);
  
  // Update excuse status
  await updateExcuse(excuseId, {
    status: 'approved',
    reviewed_by: reviewerId,
    reviewed_at: new Date()
  });
  
  // Check if penalty already applied for this date
  const penalty = await getPenaltyForUserAndDate(excuse.user_id, excuse.report_date);
  
  if (penalty) {
    // Waive the penalty
    await updatePenalty(penalty.id, {
      status: 'waived',
      waived_by: reviewerId,
      waived_reason: `Excuse approved: ${excuse.excuse_type}`
    });
    
    // Recalculate user balance
    await recalculateUserBalance(excuse.user_id);
  }
  
  // Send notification to user
  await sendNotification(excuse.user_id, 'excuse_approved', {
    deeds: getAffectedDeedsText(excuse.affected_deeds),
    date: excuse.report_date
  });
  
  // Recalculate statistics
  await recalculateUserStatistics(excuse.user_id);
}
```

### **Draft Expiration**

**Trigger:** Daily cleanup job (runs at 1 PM after grace period)

**Logic:**
```javascript
async function cleanupExpiredDrafts() {
  // Get yesterday's date
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  
  // Grace period ends at 12 PM today
  const gracePeriodEnd = new Date();
  gracePeriodEnd.setHours(12, 0, 0, 0);
  
  // If current time is past grace period end
  if (new Date() > gracePeriodEnd) {
    // Delete all draft reports for yesterday or earlier
    await deleteDrafts({
      report_date: { lte: yesterday },
      status: 'draft'
    });
  }
}
```

---

## 12. API ENDPOINTS (Backend Structure)

### **Authentication Endpoints**
```
POST   /api/auth/register          - User registration
POST   /api/auth/login             - User login
POST   /api/auth/logout            - User logout
POST   /api/auth/forgot-password   - Request password reset
POST   /api/auth/reset-password    - Reset password with token
GET    /api/auth/me                - Get current user info
PUT    /api/auth/update-profile    - Update profile (name, phone, photo)
PUT    /api/auth/change-password   - Change password
```

### **User Management Endpoints (Admin)**
```
GET    /api/admin/users                    - List all users (with filters)
GET    /api/admin/users/:id                - Get user details
PUT    /api/admin/users/:id                - Update user
DELETE /api/admin/users/:id                - Delete user
POST   /api/admin/users/:id/approve        - Approve pending user
POST   /api/admin/users/:id/reject         - Reject pending user
POST   /api/admin/users/:id/suspend        - Suspend user
POST   /api/admin/users/:id/reactivate     - Reactivate user
PUT    /api/admin/users/:id/role           - Change user role
PUT    /api/admin/users/:id/membership     - Upgrade membership status
```

### **Deed Template Endpoints (Admin)**
```
GET    /api/admin/deed-templates           - List all deed templates
GET    /api/admin/deed-templates/:id       - Get template details
POST   /api/admin/deed-templates           - Create new deed template
PUT    /api/admin/deed-templates/:id       - Update template
DELETE /api/admin/deed-templates/:id       - Delete template (if not system)
PUT    /api/admin/deed-templates/reorder   - Reorder templates
```

### **Report Endpoints**
```
GET    /api/reports                        - Get user's reports
GET    /api/reports/:id                    - Get specific report
POST   /api/reports                        - Create report (draft)
PUT    /api/reports/:id                    - Update report (draft only)
POST   /api/reports/:id/submit             - Submit report
DELETE /api/reports/:id                    - Delete draft report
GET    /api/reports/date/:date             - Get report for specific date
GET    /api/reports/statistics             - Get user's deed statistics
POST   /api/reports/export                 - Export reports (PDF/Excel)
```

### **Report Management Endpoints (Admin)**
```
GET    /api/admin/reports                  - List all user reports
GET    /api/admin/reports/user/:userId     - Get user's reports
PUT    /api/admin/reports/:id/edit-deed    - Edit deed value in submitted report
```

### **Penalty Endpoints**
```
GET    /api/penalties                      - Get user's penalties
GET    /api/penalties/balance              - Get current balance
GET    /api/penalties/history              - Get penalty history
```

### **Penalty Management Endpoints (Admin/Cashier)**
```
GET    /api/admin/penalties                - List all penalties
POST   /api/admin/penalties                - Create manual penalty
PUT    /api/admin/penalties/:id            - Update penalty
DELETE /api/admin/penalties/:id            - Delete penalty
POST   /api/admin/penalties/:id/waive      - Waive penalty
```

### **Payment Endpoints**
```
GET    /api/payments                       - Get user's payments
POST   /api/payments                       - Submit payment
GET    /api/payments/:id                   - Get payment details
GET    /api/payments/receipt/:id           - Download payment receipt (PDF)
```

### **Payment Management Endpoints (Admin/Cashier)**
```
GET    /api/admin/payments                 - List all payments
GET    /api/admin/payments/pending         - List pending payments
POST   /api/admin/payments/:id/approve     - Approve payment
POST   /api/admin/payments/:id/reject      - Reject payment
POST   /api/admin/payments/clear-balance   - Manually clear user balance
```

### **Excuse Endpoints**
```
GET    /api/excuses                        - Get user's excuses
POST   /api/excuses                        - Submit excuse
GET    /api/excuses/:id                    - Get excuse details
PUT    /api/users/excuse-mode              - Toggle excuse mode
```

### **Excuse Management Endpoints (Supervisor/Admin)**
```
GET    /api/admin/excuses                  - List all excuses
GET    /api/admin/excuses/pending          - List pending excuses
POST   /api/admin/excuses/:id/approve      - Approve excuse
POST   /api/admin/excuses/:id/reject       - Reject excuse
```

### **Notification Endpoints**
```
GET    /api/notifications                  - Get user's notifications
PUT    /api/notifications/:id/read         - Mark as read
PUT    /api/notifications/read-all         - Mark all as read
DELETE /api/notifications/:id              - Delete notification
POST   /api/notifications/settings         - Update notification preferences
```

### **Notification Management Endpoints (Admin/Supervisor)**
```
GET    /api/admin/notification-templates   - List templates
PUT    /api/admin/notification-templates/:id - Update template
GET    /api/admin/notification-schedules   - List schedules
POST   /api/admin/notification-schedules   - Create schedule
PUT    /api/admin/notification-schedules/:id - Update schedule
POST   /api/admin/notifications/send       - Send manual notification
```

### **Settings Endpoints (Admin)**
```
GET    /api/admin/settings                 - Get all settings
PUT    /api/admin/settings/:key            - Update setting
GET    /api/admin/payment-methods          - List payment methods
POST   /api/admin/payment-methods          - Add payment method
PUT    /api/admin/payment-methods/:id      - Update payment method
DELETE /api/admin/payment-methods/:id      - Delete payment method
```

### **Rest Days Endpoints (Admin)**
```
GET    /api/admin/rest-days                - List rest days
POST   /api/admin/rest-days                - Add rest day
PUT    /api/admin/rest-days/:id            - Update rest day
DELETE /api/admin/rest-days/:id            - Delete rest day
GET    /api/rest-days/upcoming             - Get upcoming rest days (all users)
```

### **Leaderboard Endpoints**
```
GET    /api/leaderboard                    - Get leaderboard (with period filter)
GET    /api/leaderboard/my-rank            - Get user's rank
```

### **Leaderboard Management Endpoints (Supervisor/Admin)**
```
POST   /api/admin/leaderboard/calculate    - Trigger leaderboard calculation
POST   /api/admin/tags/award               - Award tag to user
DELETE /api/admin/tags/remove               - Remove tag from user
```

### **Analytics Endpoints (Admin/Supervisor)**
```
GET    /api/admin/analytics/overview       - Dashboard overview stats
GET    /api/admin/analytics/users          - User metrics
GET    /api/admin/analytics/deeds          - Deed metrics
GET    /api/admin/analytics/financial      - Financial metrics
GET    /api/admin/analytics/engagement     - Engagement metrics
POST   /api/admin/analytics/export         - Export analytics report
```

### **Audit Log Endpoints (Admin)**
```
GET    /api/admin/audit-logs               - List audit logs (with filters)
GET    /api/admin/audit-logs/user/:userId  - Get logs for specific user
```

### **Content Management Endpoints (Admin)**
```
GET    /api/content/:key                   - Get content (accessible to all)
PUT    /api/admin/content/:key             - Update content
GET    /api/admin/announcements            - List announcements
POST   /api/admin/announcements            - Create announcement
PUT    /api/admin/announcements/:id        - Update announcement
DELETE /api/admin/announcements/:id        - Delete announcement
```

### **System Endpoints**
```
GET    /api/system/version                 - Get app version info
GET    /api/system/force-update            - Check if update required
GET    /api/system/health                  - Health check
```

---

## 13. CRON JOBS & SCHEDULED TASKS

### **Daily Tasks**

**1. Penalty Calculation** (Runs at 12:00 PM)

Check all users who
RetryAAContinuedidn't submit yesterday's report

Apply penalties based on missed deeds
Skip New members, rest days, and approved excuses
Send penalty notifications
Check auto-deactivation thresholds
Update user statistics


**2. Membership Status Update** (Runs at 12:01 AM)
```
- Calculate membership status for all users
- Upgrade from New to Exclusive (after 30 days)
- Upgrade from Exclusive to Legacy (after 3 years)
- Update user records
- No notifications (silent update)
```

**3. Draft Cleanup** (Runs at 12:30 PM)
```
- Delete expired draft reports
- Drafts older than grace period end time
- Free up storage space
```

**4. Statistics Recalculation** (Runs at 1:00 AM)
```
- Recalculate user_statistics for all users
- Update total deeds, averages, streaks
- Update completion rates
- Update penalty balances
```

**5. Leaderboard Update** (Runs at 2:00 AM)
```
- Calculate daily leaderboard
- Update weekly leaderboard (on Mondays)
- Update monthly leaderboard (on 1st of month)
- Update all-time leaderboard
- Assign ranks
```

**6. Special Tags Assignment** (Runs at 2:30 AM)
```
- Check Fajr Champion criteria for all users
- Award/remove tags based on performance
- Check other custom tags (if configured)
- Send notifications for newly awarded tags
```

**7. Session Cleanup** (Runs at 3:00 AM)
```
- Delete expired user sessions
- Delete expired password reset tokens
- Clean up old notification logs (older than 90 days)
```

### **Scheduled Notifications**

**Deadline Reminder** (Time configurable by admin, default: 9:00 PM)
```
- Check users who haven't submitted today's report
- Send push and/or email notification
- Remind about grace period deadline
- Show current progress if draft exists
```

**Grace Period Ending** (11:00 AM)
```
- Check users with yesterday's pending reports
- Send urgent reminder (1 hour before penalty)
- Highlight consequences of missing deadline
```

**Payment Reminder** (Time configurable, default: Weekly Sunday 10:00 AM)
```
- Check users with penalty balance > configured threshold
- Send payment reminder notification
- Include current balance and payment instructions
```

**Rest Day Announcement** (Day before rest day at 6:00 PM)
```
- Notify all users about upcoming rest day
- Include rest day description (e.g., "Eid al-Fitr")
- Remind that no reports needed
```

### **Weekly Tasks**

**1. Payment Reminder** (Runs every Sunday at 10:00 AM)
```
- Identify users with high penalty balances
- Send payment reminder notifications
- Include balance breakdown and payment link
```

**2. Weekly Report Summary** (Runs every Monday at 8:00 AM)
```
- Generate weekly summary for each user
- Show last week's performance
- Show compliance rate
- Show penalty incurred vs paid
- Send summary notification/email
```

**3. Backup Database** (Runs every Sunday at 4:00 AM)
```
- Create full database backup
- Upload to cloud storage
- Retain last 4 weekly backups
```

### **Monthly Tasks**

**1. Monthly Analytics Report** (Runs on 1st of month at 5:00 AM)
```
- Generate comprehensive analytics report
- Send to all admins via email
- Include key metrics, trends, insights
- Attach PDF and Excel files
```

**2. Archive Old Data** (Runs on 1st of month at 6:00 AM)
```
- Archive audit logs older than 1 year (if archiving enabled)
- Archive notification logs older than 90 days
- Optimize database tables
```

---

## 14. NOTIFICATION DETAILED SPECIFICATIONS

### **Push Notification Structure**
```json
{
  "notification": {
    "title": "Reminder: Submit Today's Deeds",
    "body": "You have until 12 PM tomorrow to submit today's report.",
    "sound": "default",
    "badge": 1,
    "icon": "ic_notification",
    "color": "#4CAF50"
  },
  "data": {
    "notification_type": "deadline_reminder",
    "action": "open_report_screen",
    "user_id": "uuid",
    "timestamp": "2025-10-21T21:00:00Z"
  }
}
```

### **Email Template Structure**

**Subject:** `{title}`

**HTML Body:**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .header { background: #4CAF50; color: white; padding: 20px; }
    .content { padding: 20px; }
    .button { background: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Good Deeds App</h1>
  </div>
  <div class="content">
    <h2>{title}</h2>
    <p>{body}</p>
    <a href="{action_url}" class="button">Open App</a>
  </div>
  <div class="footer">
    <p>If you have questions, contact admin@gooddeeds.app</p>
  </div>
</body>
</html>
```

### **In-App Notification Display**

- Badge count on bell icon
- List view with avatars/icons per type
- Unread notifications highlighted
- Swipe to delete
- Tap to mark as read and perform action
- Group by date (Today, Yesterday, This Week, Older)

---

## 15. EXPORT FUNCTIONALITY

### **PDF Export (Reports)**

**Structure:**
```
Header:
- Good Deeds App Logo
- Report Title: "Deed Reports - [User Name]"
- Date Range: [Start Date] to [End Date]
- Generated: [Timestamp]

Summary Section:
- Total Reports: X
- Total Deeds: X
- Average Deeds: X.XX
- Compliance Rate: XX%
- Total Penalties: X shillings
- Total Paid: X shillings
- Current Balance: X shillings

Reports Table:
| Date | Total Deeds | Fara'id | Sunnah | Status | Penalty |
|------|-------------|---------|--------|--------|---------|
| ...  | ...         | ...     | ...    | ...    | ...     |

Footer:
- Page numbers
- Disclaimer text
```

**Libraries:** 
- Flutter: `pdf` package
- Backend: `puppeteer` or similar

### **Excel Export (Reports)**

**Sheets:**
1. **Summary Sheet**
   - User information
   - Overall statistics
   - Date range

2. **Reports Sheet**
   - Columns: Date, Fajr, Duha, Dhuhr, Juz, Asr, Sunnah Prayers, Maghrib, Isha, Athkar, Witr, Total, Fara'id, Sunnah, Status, Penalty
   - Each row = one report
   - Conditional formatting (green = 10 deeds, yellow = 7-9, red = <7)

3. **Deed Breakdown Sheet**
   - Individual deed statistics
   - Completion rates
   - Charts/graphs

**Libraries:**
- Flutter: `excel` package
- Backend: `exceljs` or similar

### **Analytics Export**

**PDF Format:**
- Executive summary
- Charts and graphs (embedded images)
- Key metrics tables
- Insights and recommendations

**Excel Format:**
- Multiple sheets for different metrics
- Raw data tables
- Pivot table ready format
- Charts on separate sheet

---

## 16. OFFLINE FUNCTIONALITY

### **Offline Capabilities**

**Allowed Actions:**
- View cached reports
- Create/edit draft reports
- View cached statistics
- View rules & policies (cached)
- View cached notifications

**Not Allowed (Requires Connection):**
- Submit reports
- Submit payments
- Submit excuses
- View real-time leaderboard
- Receive new notifications
- View other users' data (Supervisor)

### **Data Sync Strategy**

**On Connection Restored:**
```javascript
1. Check for pending draft reports
2. Attempt to sync drafts to server
3. Resolve conflicts (server version wins if both exist)
4. Fetch latest user statistics
5. Fetch new notifications
6. Update cached data
7. Show sync success/failure message
```

### **Conflict Resolution**

**Scenario:** User edits draft offline, but grace period expired

**Resolution:**
```
- Show warning: "Grace period has ended for this date"
- Offer options:
  1. Discard draft
  2. Contact admin to enable past date submission
- Do not sync expired drafts
```

---

## 17. APP VERSION CONTROL & FORCE UPDATE

### **Version Check Flow**

**On App Launch:**
```javascript
1. Get current app version from device
2. Call API: GET /api/system/version
3. Compare versions:
   - If current < minimum_required: Force update (block app)
   - If current < latest_version: Show optional update dialog
   - If current >= latest_version: Proceed normally
4. Store last check timestamp (check once per day)
```

### **Force Update Screen**

**UI:**
- Large icon: Update required
- Title: "Update Required"
- Message: "A new version is available. Please update to continue using the app."
- Custom message from admin (configurable)
- "Update Now" button (links to App Store/Play Store)
- No skip or close option

### **Optional Update Dialog**

**UI:**
- Title: "Update Available"
- Message: "Version X.X.X is now available with new features and improvements."
- "Update Now" button
- "Later" button (dismiss)
- "Don't show again" checkbox (for this version)

### **Version Storage in Database**
```sql
-- In settings table
'current_app_version' = '1.0.0'
'minimum_app_version' = '1.0.0'
'update_message' = 'New features: Improved UI, bug fixes'
'force_update_enabled' = 'true'
'ios_app_url' = 'https://apps.apple.com/...'
'android_app_url' = 'https://play.google.com/...'
```

---

## 18. SECURITY & PERMISSIONS

### **Authentication & Authorization**

**JWT Token Structure:**
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "role": "user",
  "account_status": "active",
  "iat": 1634567890,
  "exp": 1634654290
}
```

**Token Expiration:**
- Access token: 24 hours
- Refresh token: 30 days
- Refresh before expiration

**Role-Based Access Control (RBAC):**

| Endpoint | User | Supervisor | Cashier | Admin |
|----------|------|------------|---------|-------|
| Submit Report | ✅ | ✅ | ✅ | ✅ |
| View Own Reports | ✅ | ✅ | ✅ | ✅ |
| View All Reports | ❌ | ✅ | ❌ | ✅ |
| Submit Payment | ✅ | ✅ | ✅ | ✅ |
| Approve Payment | ❌ | ❌ | ✅ | ✅ |
| Submit Excuse | ✅ | ✅ | ✅ | ✅ |
| Approve Excuse | ❌ | ✅ | ❌ | ✅ |
| Manage Users | ❌ | ❌ | ❌ | ✅ |
| Edit Deed Templates | ❌ | ❌ | ❌ | ✅ |
| View Analytics | ❌ | ✅ | ❌ | ✅ |
| Manage Settings | ❌ | ❌ | ❌ | ✅ |
| Send Manual Notification | ❌ | ✅ | ❌ | ✅ |

### **Data Privacy**

**User Data Protection:**
- Passwords hashed with bcrypt (cost factor: 12)
- Personal data encrypted at rest (Supabase encryption)
- API calls over HTTPS only
- No plaintext password storage
- No logging of sensitive data

**Data Access Rules:**
- Users can only see their own reports, payments, excuses
- Supervisors can see all reports but NOT payments
- Cashiers can see payments but NOT edit reports
- Admins have full access with audit trail
- All sensitive actions logged in audit_logs

### **Input Validation**

**Server-Side Validation (Critical):**
- Email format validation
- Password strength requirements (min 8 chars, 1 uppercase, 1 number)
- Deed values within allowed range (0-1 for binary, 0-1.0 for fractional)
- Date range validation (no future dates for reports)
- Amount validation (positive numbers only)
- SQL injection prevention (parameterized queries)
- XSS prevention (sanitize all user inputs)

**Client-Side Validation (User Experience):**
- Real-time form validation
- Helpful error messages
- Prevent invalid submissions

### **Rate Limiting**

**API Rate Limits:**
- General endpoints: 100 requests per minute per user
- Authentication endpoints: 5 requests per minute per IP
- Payment submission: 3 requests per hour per user
- Password reset: 3 requests per hour per email

**Implementation:** Use middleware (e.g., `express-rate-limit`)

---

## 19. ERROR HANDLING & EDGE CASES

### **Common Error Scenarios**

**1. User tries to submit report after grace period**
```
Error: "Grace period has ended for this date. Contact admin to enable submission."
Action: Show error message, disable submit button
Recovery: Admin can manually enable date for user
```

**2. User tries to pay more than balance**
```
Error: "Payment amount exceeds your penalty balance."
Action: Show current balance, adjust amount to max
Recovery: Update amount field to current balance
```

**3. Duplicate report submission**
```
Error: "You have already submitted a report for this date."
Action: Show error, redirect to view existing report
Recovery: Allow admin to delete report if needed
```

**4. Network error during report submission**
```
Error: "Connection lost. Your report has been saved as draft."
Action: Save locally, queue for sync
Recovery: Auto-sync when connection restored
```

**5. Admin edits deed template while users are reporting**
```
Error: None (graceful handling)
Action: New reports use updated template, old reports unchanged
Recovery: Recalculate affected reports if needed
```

**6. Payment approval fails (e.g., concurrent approval)**
```
Error: "This payment has already been processed."
Action: Refresh payment list, show current status
Recovery: Admin can check audit log for details
```

**7. User registration with existing email**
```
Error: "An account with this email already exists."
Action: Show error, offer "Forgot Password" link
Recovery: User can reset password or contact admin
```

**8. Penalty calculation error (edge case)**
```
Error: Log error, notify admin, skip penalty for that user
Action: Add to error log, send admin notification
Recovery: Admin can manually add penalty if needed
```

**9. Invalid deed value submitted**
```
Error: "Invalid deed value. Please check your entries."
Action: Highlight invalid field, show allowed range
Recovery: User corrects value and resubmits
```

**10. Auto-deactivation at exactly 500,000**
```
Edge Case: User pays 10,000 bringing balance to exactly 500,000
Action: Still triggers auto-deactivation (threshold is >=)
Recovery: Admin must manually reactivate
```

### **Error Logging**

**Log Structure:**
```javascript
{
  timestamp: "2025-10-21T14:30:00Z",
  level: "error",
  user_id: "uuid",
  endpoint: "/api/reports",
  method: "POST",
  error_message: "Invalid deed value",
  stack_trace: "...",
  request_body: {...},
  response_code: 400
}
```

**Error Monitoring:**
- Use service like Sentry or LogRocket
- Alert admins for critical errors
- Track error frequency and patterns
- Monthly error review

---

## 20. TESTING STRATEGY

### **Unit Tests**

**Backend (Supabase Functions):**
- Test penalty calculation logic
- Test payment FIFO application
- Test deed total calculation
- Test membership status calculation
- Test statistics recalculation
- Coverage target: 80%+

**Frontend (Flutter):**
- Test widget rendering
- Test form validation
- Test navigation flows
- Test state management
- Coverage target: 70%+

### **Integration Tests**

**API Testing:**
- Test all endpoints with various payloads
- Test authentication and authorization
- Test rate limiting
- Test error responses
- Use Postman collections or similar

**Database Testing:**
- Test database triggers
- Test foreign key constraints
- Test unique constraints
- Test indexes for performance

### **End-to-End Tests**

**Critical User Flows:**
1. **User Registration & Approval**
   - User signs up → Admin approves → User logs in

2. **Daily Report Submission**
   - User creates draft → Edits values → Submits report → Views confirmation

3. **Penalty Calculation**
   - User misses deadline → System calculates penalty → User receives notification

4. **Payment Flow**
   - User submits payment → Cashier approves → Balance updated → User notified

5. **Excuse Submission & Approval**
   - User enables excuse mode → Submits excuse → Supervisor approves → Penalty waived

### **Performance Testing**

**Load Testing:**
- Simulate 1000 concurrent users
- Test report submission at peak time (11:50 AM - 12:10 PM)
- Test notification delivery (send to 1000 users simultaneously)
- Measure response times (target: < 500ms for most endpoints)

**Database Performance:**
- Test queries with 100,000+ reports
- Test leaderboard calculation with 10,000+ users
- Optimize slow queries (use EXPLAIN ANALYZE)
- Add indexes where needed

### **User Acceptance Testing (UAT)**

**Test Groups:**
- 5-10 beta testers from target audience
- Include users of different membership statuses
- Test on both iOS and Android
- Collect feedback on UI/UX
- Fix critical bugs before launch

---

## 21. DEPLOYMENT & HOSTING

### **Infrastructure**

**Supabase:**
- Database: PostgreSQL (hosted by Supabase)
- Authentication: Supabase Auth
- Storage: Supabase Storage (for profile photos)
- Edge Functions: For serverless backend logic (if needed)

**Firebase:**
- FCM: Push notifications only
- No other Firebase services needed

**Mailgun:**
- Email sending service
- Configured via API keys in settings

**App Hosting:**
- iOS: Apple App Store
- Android: Google Play Store

### **Environment Configuration**

**Development:**
```
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=dev_anon_key
MAILGUN_API_KEY=dev_mailgun_key
FCM_SERVER_KEY=dev_fcm_key
APP_ENV=development
```

**Production:**
```
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod_anon_key
MAILGUN_API_KEY=prod_mailgun_key
FCM_SERVER_KEY=prod_fcm_key
APP_ENV=production
```

### **Database Migrations**

**Use Supabase Migrations:**
```sql
-- migrations/001_initial_schema.sql
-- migrations/002_add_deed_templates.sql
-- migrations/003_add_special_tags.sql
-- etc.
```

**Migration Strategy:**
- Version control all migrations
- Test on staging before production
- Backup database before migration
- Rollback plan for each migration

### **CI/CD Pipeline**

**Automated Build & Deploy:**

Push code to Git (main branch)
Run automated tests
Build Flutter app (iOS & Android)
Deploy backend (if applicable)
Upload to App Store/Play Store (beta track)
Manual approval for production release


**Tools:** GitHub Actions, Codemagic, or Bitrise

---

## 22. MAINTENANCE & SUPPORT

### **Regular Maintenance Tasks**

**Weekly:**
- Review error logs
- Check system performance metrics
- Review pending user approvals
- Review pending payments and excuses

**Monthly:**
- Database backup verification
- Security audit (check for vulnerabilities)
- Review and optimize slow queries
- Update dependencies (Flutter packages, backend libraries)
- Review analytics reports

**Quarterly:**
- User feedback review
- Feature prioritization
- Performance optimization
- Security updates

### **Support Channels**

**In-App Support:**
- Contact Admin button (sends email to admin)
- FAQ section
- Rules & Policies page

**External Support:**
- Email: support@gooddeeds.app
- Response time: 24-48 hours

**Admin Support:**
- Internal communication channel (e.g., Slack)
- Direct line for critical issues

### **Backup Strategy**

**Database Backups:**
- Daily automated backups (Supabase automatic)
- Weekly manual backups (exported to cloud storage)
- Retention: 30 days of daily, 12 weeks of weekly

**Recovery Plan:**
- Document restoration procedures
- Test restore process quarterly
- Designate backup admin for emergencies

---

## 23. FUTURE ENHANCEMENTS (Post-MVP)

**Phase 2 Features:**
1. **Mobile Money API Integration**
   - Direct payment via ZAAD/eDahab APIs
   - Auto-verification of payments
   - Instant balance updates

2. **Social Features**
   - User groups/circles
   - Share achievements
   - Group challenges

3. **Gamification**
   - Achievement badges beyond Fajr Champion
   - Points system
   - Rewards for consistency

4. **Advanced Analytics**
   - Predictive analytics (risk of missing target)
   - Personalized recommendations
   - Trend analysis and insights

5. **Multi-Language Support**
   - Somali language
   - Arabic language
   - English (default)

6. **Streak Tracking**
   - Visual streak calendar
   - Streak milestones
   - Streak recovery (one-time grace)

7. **Custom Deed Categories**
   - Users can suggest new deeds
   - Admin approves and adds to system
   - Flexible deed targets per user

8. **Web Dashboard**
   - Web version for admins
   - Advanced reporting
   - Bulk operations

9. **Reminder Customization**
   - Users set their own reminder times
   - Multiple reminders per day
   - Smart reminders based on habits

10. **Integration with Prayer Time APIs**
    - Auto-detect prayer times based on location
    - Reminders before each prayer
    - Track prayer timeliness

---

## 24. FINAL CHECKLIST BEFORE DEVELOPMENT

### **Design Assets Needed**
- [ ] App logo (iOS, Android, various sizes)
- [ ] App icon
- [ ] Splash screen
- [ ] Notification icon
- [ ] Category icons (Fara'id, Sunnah)
- [ ] Empty state illustrations
- [ ] Achievement badges

### **Third-Party Accounts Setup**
- [ ] Supabase project created
- [ ] Firebase project created (for FCM)
- [ ] Mailgun account setup
- [ ] Apple Developer account (for iOS)
- [ ] Google Play Developer account (for Android)

### **Documentation Needed**
- [ ] API documentation (Postman collection or Swagger)
- [ ] Database schema diagram
- [ ] User flow diagrams
- [ ] Admin manual
- [ ] User manual/guide

### **Legal Documents**
- [ ] Terms & Conditions
- [ ] Privacy Policy
- [ ] User Agreement
- [ ] Data protection compliance (GDPR if applicable)

### **Testing Checklist**
- [ ] Test plan document
- [ ] Test cases for all critical flows
- [ ] Beta tester recruitment
- [ ] Bug tracking system setup (e.g., Jira, GitHub Issues)

### **Launch Preparation**
- [ ] App Store listing (screenshots, description)
- [ ] Play Store listing
- [ ] Marketing materials
- [ ] Social media accounts
- [ ] Website (optional but recommended)

---

## 25. SUMMARY & KEY TAKEAWAYS

### **Core Application Features**

✅ **User Management:** 4 roles (User, Supervisor, Cashier, Admin) with distinct permissions  
✅ **Deed Tracking:** 10 default daily deeds (5 Fara'id, 5 Sunnah) with admin customization  
✅ **Penalty System:** 5,000 shillings per deed, 500 per 0.1 deed, auto-deactivation at 500K  
✅ **Payment System:** Manual submission, FIFO application, admin/cashier approval  
✅ **Excuse System:** 3 types (Sickness, Travel, Raining), supervisor/admin approval  
✅ **Notification System:** 15+ notification types, configurable templates and schedules  
✅ **Analytics Dashboard:** Comprehensive metrics for admin/supervisor  
✅ **Leaderboard:** Daily/weekly/monthly/all-time rankings with special tags  
✅ **Offline Support:** Draft saving, auto-sync when online  
✅ **Force Update:** Version control with mandatory updates  

### **Technology Stack**

- **Frontend:** Flutter (iOS & Android)
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Email:** Mailgun (configurable)
- **File Storage:** Supabase Storage

### **Database Tables: 24 Total**

1. users
2. deed_templates
3. deeds_reports
4. deed_entries
5. penalties
6. payments
7. penalty_payments
8. excuses
9. rest_days
10. settings
11. notification_templates
12. notification_schedules
13. notifications_log
14. audit_logs
15. password_reset_tokens
16. user_sessions
17. user_statistics
18. leaderboard
19. payment_methods
20. special_tags
21. user_tags
22. app_content
23. announcements
24. user_announcement_dismissals

### **Key Business Rules**

- Daily target: 10 deeds (configurable by adding/removing deed templates)
- Grace period: 12 PM next day (configurable)
- Training period: 30 days for New members (no penalties)
- Auto-deactivation threshold: 500,000 shillings
- Payment application: FIFO (oldest penalties first)
- Report submission: One per day, locked after submission
- Rest days: All deeds disabled, no penalties
- Excuse mode: Prevents auto-penalties, requires approval

### **Next Steps for Implementation**

1. Create new conversation for development
2. Start with database schema setup (Supabase migrations)
3. Implement authentication system
4. Build core report submission feature
5. Implement penalty calculation logic
6. Build admin dashboard
7. Implement notifications
8. Testing and refinement
9. Beta launch
10. Production launch

---

**This specification document is complete and ready for implementation. All requirements, edge cases, and technical details have been documented. You can now start a new conversation to begin building the application!** 🎉RetryClaude can make mistakes. Please double-check responses.