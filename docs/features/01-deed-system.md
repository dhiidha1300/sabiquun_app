# Deed System (Core Feature)

The deed system is the heart of the application, enabling users to track their daily good deeds with configurable templates and comprehensive reporting.

## Default 10 Daily Deeds

| # | Deed Name | Category | Value Type | Possible Values |
|---|-----------|----------|------------|-----------------|
| 1 | Fajr Prayer | Fara'id | Binary | 0 or 1 |
| 2 | Duha Prayer | Sunnah | Binary | 0 or 1 |
| 3 | Dhuhr Prayer | Fara'id | Binary | 0 or 1 |
| 4 | Juz of Quran | Sunnah | Binary | 0 or 1 |
| 5 | Asr Prayer | Fara'id | Binary | 0 or 1 |
| 6 | Sunnah Prayers | Sunnah | Fractional | 0, 0.1, 0.2, ..., 1.0 |
| 7 | Maghrib Prayer | Fara'id | Binary | 0 or 1 |
| 8 | Isha Prayer | Fara'id | Binary | 0 or 1 |
| 9 | Athkar | Sunnah | Binary | 0 or 1 |
| 10 | Witr | Sunnah | Binary | 0 or 1 |

### Category Breakdown

- **Fara'id (Obligatory):** 5 deeds (the 5 daily prayers)
- **Sunnah (Recommended):** 5 deeds (Duha, Juz, Sunnah Prayers, Athkar, Witr)

### Note on Sunnah Prayers

The "Sunnah Prayers" deed combines 10 different Sunnah prayers as one fractional deed:
- **0.1** = 1 Sunnah prayer completed
- **1.0** = All 10 Sunnah prayers completed

Users are expected to be familiar with this system; no helper text is needed in the UI.

---

## Deed Management (Admin)

### Admin Capabilities

- ✅ Add new deeds beyond the default 10
- ✅ Edit existing deed properties (name, category, value type)
- ✅ Change deed sort order (drag-and-drop interface)
- ✅ Deactivate deeds (does not delete - preserves historical data)
- ✅ When new deed added: Daily target automatically increases
- ✅ System default deeds can be modified but are flagged as "system deeds"

### Deed Template Properties

Each deed template has the following properties:

| Property | Description | Example |
|----------|-------------|---------|
| **Deed Name** | Display name | "Fajr Prayer" |
| **Deed Key** | Unique identifier (slug) | "fajr_prayer" |
| **Category** | Fara'id or Sunnah | "faraid" |
| **Value Type** | Binary or Fractional | "binary" |
| **Sort Order** | Display order in report form | 1, 2, 3, ... |
| **Is Active** | Can be deactivated/reactivated | true/false |
| **Is System Default** | Flag for original 10 deeds | true/false |

**Important:** System default deeds cannot be deleted, only deactivated.

---

## Daily Reporting Rules

### Report Period

- **Day starts:** Midnight (00:00)
- **Day ends:** 11:59 PM (23:59)
- **Grace period:** Until 12 PM (noon) next day (configurable by admin)
- **Single timezone** for entire system (no per-user timezones)

### Reporting Constraints

| Constraint | Details |
|------------|---------|
| **One report per day** | Users cannot submit multiple reports for the same date |
| **Draft saving** | Users can save incomplete reports as drafts |
| **Offline drafts** | Drafts auto-save when offline, sync when online |
| **Draft expiration** | Drafts are deleted automatically after grace period ends |
| **Submission locks report** | Once submitted, users cannot edit (only admins can) |
| **Past date restrictions** | Past dates disabled after grace period ends (unless admin overrides) |

### Rest Days

**Admin-configured rest days** affect deed submissions:
- ❌ No deed submissions allowed on rest days
- ❌ No penalties applied on rest days
- 🔒 All deeds disabled in report form
- 📅 Users can view rest day schedule in advance

**Use Cases:**
- Eid al-Fitr
- Eid al-Adha
- System maintenance days

---

## Report Form UI

### Display Layout

The report submission form displays all active deeds in sort order:

**Binary Deeds:**
- UI: Toggle switch or checkbox
- Values: 0 (not done) or 1 (done)
- Example: Fajr Prayer ☑️

**Fractional Deeds:**
- UI: Slider with 0.1 increments
- Range: 0.0 to 1.0
- Numeric display next to slider
- Example: Sunnah Prayers [======•---] 0.6

### Real-Time Features

As the user fills the form, the app shows:

1. **Total Calculation**
   - "7.5 / 10 deeds"
   - Updates in real-time

2. **Visual Indicators**
   - Fara'id deeds: Different color/icon (e.g., green mosque icon)
   - Sunnah deeds: Different color/icon (e.g., blue star icon)

3. **Penalty Preview**
   - If total < target: "2 deeds missed = 10,000 penalty"
   - Color-coded warning (red if penalty)

4. **Category Breakdown**
   - "5/5 Fara'id ✅ | 2.5/5 Sunnah ⚠️"
   - Shows compliance per category

### Action Buttons

- **Save as Draft** (secondary button)
  - Saves current state without submitting
  - Can edit later
  - No penalties while draft

- **Submit Report** (primary button)
  - Confirmation dialog: "Submit report for {date}? You cannot edit after submission."
  - Locks the report upon submission
  - Triggers penalty calculation if below target

---

## Deed Calculation Examples

### Example 1: Full Compliance ✅

**Deeds Completed:**
- All 5 Fara'id prayers: **5.0**
- Duha, Juz, Athkar, Witr: **4.0**
- Sunnah Prayers: **1.0**

**Total:** 10.0 deeds ✅
**Penalty:** None

---

### Example 2: Partial Completion ⚠️

**Deeds Completed:**
- Fajr, Dhuhr, Asr, Maghrib, Isha: **5.0**
- Duha, Athkar: **2.0**
- Sunnah Prayers: **0.5**
- Juz, Witr: **0.0**

**Total:** 7.5 deeds ❌
**Missing:** 2.5 deeds
**Penalty:** 2.5 × 5,000 = **12,500 shillings**

**Breakdown:**
- Fara'id: 5/5 ✅ (100%)
- Sunnah: 2.5/5 ⚠️ (50%)

---

### Example 3: Near Perfect ⚠️

**Deeds Completed:**
- All deeds except Sunnah Prayers: **9.0**
- Sunnah Prayers: **0.8** (instead of 1.0)

**Total:** 9.8 deeds ❌
**Missing:** 0.2 deeds
**Penalty:** 0.2 × 5,000 = **1,000 shillings**

**Note:** Even small shortfalls incur penalties (500 shillings per 0.1 deed).

---

## Deed Reporting Workflow

### User Journey

```
1. User opens app
   ↓
2. Navigates to "Submit Report" (or taps FAB)
   ↓
3. Selects date (defaults to today)
   ↓
4. Fills in deed values (binary toggles, fractional sliders)
   ↓
5. Views real-time total and penalty preview
   ↓
6. (Optional) Saves as draft → Can edit later
   ↓
7. Submits report → Confirmation dialog
   ↓
8. Report locked → User sees success message
   ↓
9. Penalty calculated (if applicable) after grace period
```

### Draft Workflow

**Saving Draft:**
- User can save incomplete report
- Draft syncs to server (or saves locally if offline)
- Draft appears in "Reports" list with "Draft" badge

**Resuming Draft:**
- User taps on draft report
- Form loads with previously saved values
- User continues editing
- Can submit or save again

**Draft Expiration:**
- If grace period expires without submission:
  - Draft is deleted automatically
  - Penalty calculation triggered (as if no report)
  - User receives notification: "Report draft expired for {date}. Penalty applied."

---

## Admin Features

### Editing Submitted Reports

**Capability:**
- Admins can edit deed values in submitted reports
- Requires reason field (mandatory)
- All changes logged in audit trail

**Use Cases:**
- User made data entry error
- Dispute resolution
- Correction after review

**Workflow:**
1. Admin searches for report
2. Clicks "Edit Report"
3. Modifies deed values
4. Enters reason: "User corrected Sunnah Prayer count"
5. Confirms edit
6. System recalculates total and penalties
7. User receives notification: "Your report for {date} was edited by admin"

**Audit Log Entry:**
```
Action: report_edited
Performed by: Admin Name
User affected: User Name
Date: 2025-10-15
Old value: {"fajr_prayer": 1, "sunnah_prayers": 0.5, ...}
New value: {"fajr_prayer": 1, "sunnah_prayers": 0.8, ...}
Reason: "User corrected Sunnah Prayer count"
```

---

## Rest Day Management

### Admin Configuration

**Add Rest Day:**
1. Admin navigates to "Rest Days" section
2. Selects date(s) from calendar
3. Enters description: "Eid al-Fitr"
4. (Optional) Sets as recurring annually
5. Saves rest day

**View Rest Days:**
- Calendar view with rest days highlighted
- List view with upcoming rest days
- Export rest day schedule

**User View:**
- Users see rest day badge on calendar
- Cannot submit reports on rest days
- Message: "Today is a rest day. No report needed."

---

## Offline Support

### Draft Saving Offline

**Behavior:**
1. User fills report form while offline
2. Taps "Save as Draft"
3. App saves draft to local storage (SQLite/Hive)
4. User sees "Draft saved offline" message
5. When connection restored:
   - App auto-syncs draft to server
   - User sees "Draft synced" notification

### Conflict Resolution

If user edits draft on multiple devices:
- **Last-write-wins** strategy
- Warning shown: "This draft was edited on another device. Loading latest version."

---

## Database Tables Used

### `deed_templates`
Stores deed definitions (admin-configurable).

```sql
CREATE TABLE deed_templates (
  id UUID PRIMARY KEY,
  deed_name VARCHAR(255),
  deed_key VARCHAR(100) UNIQUE,
  category VARCHAR(50),  -- 'faraid' or 'sunnah'
  value_type VARCHAR(50), -- 'binary' or 'fractional'
  sort_order INTEGER,
  is_active BOOLEAN DEFAULT TRUE,
  is_system_default BOOLEAN DEFAULT FALSE
);
```

### `deeds_reports`
Stores daily report submissions.

```sql
CREATE TABLE deeds_reports (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  report_date DATE NOT NULL,
  total_deeds DECIMAL(4,1), -- e.g., 9.5
  sunnah_count DECIMAL(4,1),
  faraid_count DECIMAL(4,1),
  status VARCHAR(50), -- 'draft' or 'submitted'
  submitted_at TIMESTAMP,
  UNIQUE(user_id, report_date)
);
```

### `deed_entries`
Stores individual deed values for each report.

```sql
CREATE TABLE deed_entries (
  id UUID PRIMARY KEY,
  report_id UUID REFERENCES deeds_reports(id),
  deed_template_id UUID REFERENCES deed_templates(id),
  deed_value DECIMAL(3,1), -- 0, 1, or 0.1-1.0
  UNIQUE(report_id, deed_template_id)
);
```

---

## API Endpoints

### Get Active Deeds
```
GET /api/deed-templates?active=true
```

**Response:**
```json
{
  "deeds": [
    {
      "id": "uuid",
      "deed_name": "Fajr Prayer",
      "deed_key": "fajr_prayer",
      "category": "faraid",
      "value_type": "binary",
      "sort_order": 1
    },
    ...
  ]
}
```

### Submit Report
```
POST /api/reports
```

**Request:**
```json
{
  "report_date": "2025-10-22",
  "deed_entries": [
    {"deed_template_id": "uuid1", "deed_value": 1},
    {"deed_template_id": "uuid2", "deed_value": 0.7},
    ...
  ]
}
```

**Response:**
```json
{
  "report_id": "uuid",
  "total_deeds": 9.5,
  "faraid_count": 5.0,
  "sunnah_count": 4.5,
  "penalty": 2500,
  "status": "submitted"
}
```

### Save Draft
```
POST /api/reports/draft
```

(Same request format, but `status: "draft"`)

---

## Edge Cases

### What if user submits after grace period?
- Submission blocked
- Message: "Grace period expired. Contact admin if you need to submit."

### What if daily target changes mid-day?
- Reports use deed templates active at time of submission
- Historical reports unaffected by template changes

### What if admin deactivates a deed?
- New reports won't include that deed
- Existing reports retain the deed value
- Daily target decreases accordingly

### What if user's internet drops during submission?
- Submission saved as draft locally
- Auto-retry when connection restored
- User notified of retry status

---

## Performance Considerations

- **Deed template caching:** Cache active deeds in app to reduce API calls
- **Report validation:** Validate deed values client-side before submission
- **Offline-first:** All draft operations work offline, sync later
- **Optimistic UI:** Show success immediately, handle server errors gracefully

---

[← Back to Main README](../../README.md) | [Next: Penalty System →](02-penalty-system.md) | [Database Schema →](../database/01-schema.md)
