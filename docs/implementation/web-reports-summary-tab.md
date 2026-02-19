# Web Admin Reports - User Summary Tab

## Overview
Added a new "User Summary" tab to the Reports Management page that provides aggregated statistics per user over a date range.

## Changes Made

### File: `sabiquun-web/src/app/dashboard/reports/page.tsx`

### 1. New User Interface
```typescript
interface UserSummary {
  user_id: string
  user_name: string
  user_email: string
  total_reports: number
  total_deeds: number
  average_deeds: number
  compliance_percentage: number
  current_penalty_balance: number
  expected_reports: number
}
```

### 2. New State Variables
- `userSummaries`: Array of UserSummary objects
- `isSummaryLoading`: Loading state for summary tab
- `activeTab`: Tracks current tab ('reports' | 'summary')

### 3. Tabs Component
Added shadcn/ui Tabs component with two tabs:
- **Daily Reports**: Existing report list view
- **User Summary**: New aggregated user statistics view

### 4. User Summary Calculation Logic

#### Date Range Handling
```typescript
// Default to last 30 days if no range specified
if (!startDate && !endDate) {
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
  dateRangeStart = thirtyDaysAgo.toISOString().split('T')[0]
}

// Calculate expected reports in date range
const daysDiff = Math.floor((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1
const expectedReports = daysDiff > 0 ? daysDiff : 1
```

#### Aggregation by User
For each user with reports in the date range:
1. **Total Reports**: Count of submitted reports
2. **Total Deeds**: Sum of all deeds from all reports
3. **Average Deeds/Day**: `total_deeds / total_reports` (rounded to 1 decimal)
4. **Compliance %**: `(total_reports / expected_reports) * 100`
5. **Unpaid Penalty**: From `user_statistics.current_penalty_balance`

#### Sorting
Users are sorted by compliance percentage (ascending) - worst performers first.

### 5. Summary Table Columns

| Column | Description | Badge Variants |
|--------|-------------|----------------|
| **User** | Name and email | - |
| **Reports Submitted** | `actual/expected` reports | `outline` |
| **Total Deeds** | Sum of all deeds | - |
| **Avg Deeds/Day** | Average per report | `default` if ≥10, `secondary` otherwise |
| **Compliance %** | Percentage of expected reports submitted | `default` if ≥90%, `secondary` if ≥70%, `destructive` otherwise |
| **Unpaid Penalty** | Current penalty balance in SOS | `destructive` if > 0, `secondary` otherwise |

### 6. Export Functionality

#### Daily Reports Export
```csv
Date, User, Total Deeds, Fara'id, Sunnah, Unpaid Penalty (SOS), Status, Submitted At
```

#### User Summary Export
```csv
User Name, Email, Reports Submitted, Expected Reports, Total Deeds, Avg Deeds/Day, Compliance %, Unpaid Penalty (SOS)
```

Export button dynamically changes:
- "Export Reports" on Daily Reports tab
- "Export Summary" on User Summary tab

### 7. Filters

Both tabs share common filters:
- **Search User**: Name or email search
- **From Date**: Start of date range
- **To Date**: End of date range

Daily Reports tab additionally has:
- **Status Filter**: All, Draft, Submitted

### 8. Use Cases

#### 1. Performance Review
Identify users with low compliance percentages for follow-up.

#### 2. Financial Analysis
Quick view of users with high unpaid penalty balances.

#### 3. Accountability Tracking
Monitor who is consistently submitting reports vs. who is falling behind.

#### 4. Period Comparisons
Compare user performance across different date ranges (weekly, monthly, quarterly).

## Example Summary Output

```
User: Ahmed Hassan (ahmed@example.com)
Reports Submitted: 25/30 (83%)
Total Deeds: 245
Avg Deeds/Day: 9.8
Compliance %: 83% (secondary badge)
Unpaid Penalty: 15,000 SOS (destructive badge)
```

## Technical Implementation Details

### Query Optimization
- Single query fetches all reports with user joins
- Aggregation done in JavaScript (client-side)
- Future optimization: Move aggregation to database view or stored procedure

### Performance Considerations
- Default 30-day range if no dates specified
- Search filter applies before aggregation
- Lazy loading: Summary only fetched when tab is active

### React Hooks
```typescript
useEffect(() => {
  if (activeTab === 'summary') {
    fetchUserSummaries()
  }
}, [activeTab, searchQuery, startDate, endDate])
```

## UI/UX Enhancements

### Visual Indicators
- **Green (default)**: Good performance (≥90% compliance, ≥10 deeds/day)
- **Gray (secondary)**: Average performance (70-89% compliance, <10 deeds/day)
- **Red (destructive)**: Poor performance (<70% compliance, unpaid penalties)

### Empty States
- "No user data found for the selected date range" with icon
- Loading skeletons during data fetch

### Responsive Design
- Filters adapt to screen size (1-3 columns)
- Table scrollable on mobile
- All badges remain readable

## Future Enhancements

- [ ] Add charts/graphs for visual analysis
- [ ] Export to PDF with charts
- [ ] Email summary reports to admins
- [ ] Click user row to see detailed breakdown
- [ ] Add trend indicators (↑ ↓ compared to previous period)
- [ ] Filter by compliance ranges
- [ ] Add "At Risk" users section (compliance < 50%)

---

**Date:** 2026-02-03  
**Status:** ✅ Implemented
