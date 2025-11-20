# Supervisor Features Enhancement - Implementation Guide

## Overview
This document outlines the implementation of enhanced supervisor features for the Sabiquun App, including detailed user reports with full deed breakdowns, date range filtering, and export to PDF/Excel.

## ✅ Completed Work

### 1. Data Models Created
**Location:** `lib/features/supervisor/data/models/detailed_report_model.dart`

**Models:**
- `DeedDetailModel` - Individual deed entry with template details
- `DailyReportDetailModel` - Single day's report with all deed entries
- `DetailedUserReportModel` - Complete user report with date range and daily reports

**Entities:**
**Location:** `lib/features/supervisor/domain/entities/detailed_report_entity.dart`

- `DeedDetailEntity`
- `DailyReportDetailEntity`
- `DetailedUserReportEntity`

### 2. Date Range Picker Widget
**Location:** `lib/features/supervisor/presentation/widgets/date_range_picker_widget.dart`

**Features:**
- Quick presets (Last 7/30/90 days, This/Last Month, This Year)
- Custom date range selection
- Material Design date pickers
- Visual feedback for selected range
- Days counter display

**Usage:**
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => DateRangePickerWidget(
    initialStartDate: startDate,
    initialEndDate: endDate,
    onDateRangeSelected: (start, end) {
      // Handle date range selection
    },
  ),
);
```

### 3. PDF Export Service
**Location:** `lib/features/supervisor/data/services/pdf_export_service.dart`

**Features:**
- Export single user report with full deed details table
- Export all users report with summary and individual pages
- Professional PDF formatting with headers, tables, and statistics
- Automatic deed name abbreviation for table headers
- Color-coded compliance indicators

**Methods:**
- `exportUserReportToPdf(DetailedUserReportModel report)` - Single user export
- `exportAllUsersReportToPdf(List<DetailedUserReportModel> users, DateTime startDate, DateTime endDate)` - Multi-user export

### 4. Excel Export Service
**Location:** `lib/features/supervisor/data/services/excel_export_service.dart`

**Features:**
- Multi-sheet workbooks (Summary, Deed Details, Statistics, etc.)
- Export single user with detailed breakdown
- Export all users with overview and individual sheets
- Formatted cells with bold headers and proper styling

**Methods:**
- `exportUserReportToExcel(DetailedUserReportModel report)` - Single user export
- `exportAllUsersReportToExcel(List<DetailedUserReportModel> users, DateTime startDate, DateTime endDate)` - Multi-user export

---

## 🔧 Remaining Implementation Tasks

### STEP 1: Run build_runner to Generate Freezed Files

**What:** Generate the freezed model files (`.freezed.dart` and `.g.dart`)

**Why:** The Freezed package requires code generation to create the model classes with all their methods and properties.

**How:**
```bash
cd a:\sabiquun_app\sabiquun_app
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected Output:**
- `detailed_report_model.freezed.dart`
- `detailed_report_model.g.dart`

**Note:** This must be done before the models can be used in the rest of the code.

---

### STEP 2: Create Supabase RPC Function

**What:** Create a PostgreSQL function to fetch detailed user reports with date range

**Location:** Supabase SQL Editor

**Function Name:** `get_detailed_user_report`

**SQL Code:**
```sql
CREATE OR REPLACE FUNCTION get_detailed_user_report(
  p_user_id UUID,
  p_start_date DATE,
  p_end_date DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
  v_user_info JSON;
  v_daily_reports JSON;
BEGIN
  -- Get user information
  SELECT json_build_object(
    'user_id', u.id,
    'full_name', u.name,
    'email', u.email,
    'phone_number', u.phone,
    'profile_photo_url', u.photo_url,
    'membership_status', u.membership_status,
    'member_since', u.created_at,
    'start_date', p_start_date,
    'end_date', p_end_date,
    'current_balance', COALESCE(us.current_penalty_balance, 0),
    'total_reports_in_range', COUNT(DISTINCT dr.id),
    'average_deeds', COALESCE(AVG(dr.total_deeds), 0),
    'compliance_rate',
      CASE
        WHEN COUNT(dr.id) > 0
        THEN (SUM(CASE WHEN dr.total_deeds >= 10 THEN 1 ELSE 0 END)::FLOAT / COUNT(dr.id)::FLOAT * 100)
        ELSE 0
      END,
    'faraid_compliance',
      CASE
        WHEN COUNT(dr.id) > 0
        THEN (AVG(dr.faraid_count) / 5.0 * 100)
        ELSE 0
      END,
    'sunnah_compliance',
      CASE
        WHEN COUNT(dr.id) > 0
        THEN (AVG(dr.sunnah_count) / 5.0 * 100)
        ELSE 0
      END,
    'achievement_tags', COALESCE(
      (SELECT json_agg(st.display_name)
       FROM user_tags ut
       JOIN special_tags st ON st.id = ut.tag_id
       WHERE ut.user_id = p_user_id),
      '[]'::json
    )
  ) INTO v_user_info
  FROM users u
  LEFT JOIN user_statistics us ON us.user_id = u.id
  LEFT JOIN deeds_reports dr ON dr.user_id = u.id
    AND dr.report_date BETWEEN p_start_date AND p_end_date
    AND dr.status = 'submitted'
  WHERE u.id = p_user_id
  GROUP BY u.id, u.name, u.email, u.phone, u.photo_url,
           u.membership_status, u.created_at, us.current_penalty_balance;

  -- Get daily reports with deed entries
  SELECT json_agg(
    json_build_object(
      'report_date', dr.report_date,
      'status', dr.status,
      'total_deeds', dr.total_deeds,
      'faraid_count', dr.faraid_count,
      'sunnah_count', dr.sunnah_count,
      'submitted_at', dr.submitted_at,
      'deed_entries', (
        SELECT json_agg(
          json_build_object(
            'deed_name', dt.deed_name,
            'deed_key', dt.deed_key,
            'category', dt.category,
            'value_type', dt.value_type,
            'deed_value', de.deed_value,
            'sort_order', dt.sort_order
          ) ORDER BY dt.sort_order
        )
        FROM deed_entries de
        JOIN deed_templates dt ON dt.id = de.deed_template_id
        WHERE de.report_id = dr.id
      )
    ) ORDER BY dr.report_date DESC
  ) INTO v_daily_reports
  FROM deeds_reports dr
  WHERE dr.user_id = p_user_id
    AND dr.report_date BETWEEN p_start_date AND p_end_date
    AND dr.status = 'submitted';

  -- Combine results
  v_result := json_build_object(
    'user_info', v_user_info,
    'daily_reports', COALESCE(v_daily_reports, '[]'::json)
  );

  RETURN v_result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_detailed_user_report(UUID, DATE, DATE) TO authenticated;
```

**Testing:**
```sql
-- Test the function
SELECT get_detailed_user_report(
  'user-uuid-here'::UUID,
  '2025-01-01'::DATE,
  '2025-01-31'::DATE
);
```

---

### STEP 3: Update Supervisor Data Source

**What:** Add method to fetch detailed reports from Supabase

**Location:** `lib/features/supervisor/data/datasources/supervisor_remote_datasource.dart`

**Add Method:**
```dart
Future<DetailedUserReportModel> getDetailedUserReport({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    final response = await _supabaseClient.rpc(
      'get_detailed_user_report',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String().split('T')[0],
        'p_end_date': endDate.toIso8601String().split('T')[0],
      },
    );

    if (response == null) {
      throw Exception('No data returned from Supabase');
    }

    // Parse the response
    final userInfo = response['user_info'] as Map<String, dynamic>;
    final dailyReportsJson = response['daily_reports'] as List;

    // Convert daily reports
    final dailyReports = dailyReportsJson.map((reportJson) {
      final deedEntriesJson = reportJson['deed_entries'] as List;
      final deedEntries = deedEntriesJson.map((entryJson) {
        return DeedDetailModel.fromJson(entryJson as Map<String, dynamic>);
      }).toList();

      return DailyReportDetailModel(
        reportDate: DateTime.parse(reportJson['report_date']),
        status: reportJson['status'],
        totalDeeds: (reportJson['total_deeds'] as num).toDouble(),
        faraidCount: (reportJson['faraid_count'] as num).toDouble(),
        sunnahCount: (reportJson['sunnah_count'] as num).toDouble(),
        deedEntries: deedEntries,
        submittedAt: reportJson['submitted_at'] != null
            ? DateTime.parse(reportJson['submitted_at'])
            : null,
      );
    }).toList();

    // Build the complete model
    return DetailedUserReportModel(
      userId: userInfo['user_id'],
      fullName: userInfo['full_name'],
      email: userInfo['email'],
      phoneNumber: userInfo['phone_number'],
      profilePhotoUrl: userInfo['profile_photo_url'],
      membershipStatus: userInfo['membership_status'],
      memberSince: userInfo['member_since'] != null
          ? DateTime.parse(userInfo['member_since'])
          : null,
      startDate: startDate,
      endDate: endDate,
      totalReportsInRange: userInfo['total_reports_in_range'],
      averageDeeds: (userInfo['average_deeds'] as num).toDouble(),
      complianceRate: (userInfo['compliance_rate'] as num).toDouble(),
      faraidCompliance: (userInfo['faraid_compliance'] as num).toDouble(),
      sunnahCompliance: (userInfo['sunnah_compliance'] as num).toDouble(),
      currentBalance: (userInfo['current_balance'] as num).toDouble(),
      dailyReports: dailyReports,
      achievementTags: List<String>.from(userInfo['achievement_tags']),
    );
  } catch (e) {
    throw Exception('Failed to fetch detailed user report: $e');
  }
}
```

---

### STEP 4: Update Supervisor Repository

**Location:** `lib/features/supervisor/domain/repositories/supervisor_repository.dart` (interface)
**Location:** `lib/features/supervisor/data/repositories/supervisor_repository_impl.dart` (implementation)

**Add to Interface:**
```dart
Future<Either<Failure, DetailedUserReportEntity>> getDetailedUserReport({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
});
```

**Add to Implementation:**
```dart
@override
Future<Either<Failure, DetailedUserReportEntity>> getDetailedUserReport({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    final model = await _remoteDataSource.getDetailedUserReport(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    return Right(model.toEntity());
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

---

### STEP 5: Update Supervisor BLoC

**Location:** `lib/features/supervisor/presentation/bloc/`

**Add Event (supervisor_event.dart):**
```dart
/// Load detailed user report with date range
class LoadDetailedUserReportRequested extends SupervisorEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDetailedUserReportRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Export user report
class ExportUserReportRequested extends SupervisorEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String format; // 'pdf' or 'excel'

  const ExportUserReportRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.format,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, format];
}
```

**Add State (supervisor_state.dart):**
```dart
/// Detailed user report loaded
class DetailedUserReportLoaded extends SupervisorState {
  final DetailedUserReportEntity detailedReport;

  const DetailedUserReportLoaded({required this.detailedReport});

  @override
  List<Object?> get props => [detailedReport];
}

/// Export in progress
class ReportExporting extends SupervisorState {
  final String message;

  const ReportExporting({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Export completed
class ReportExported extends SupervisorState {
  final String filePath;
  final String format;

  const ReportExported({required this.filePath, required this.format});

  @override
  List<Object?> get props => [filePath, format];
}
```

**Add Event Handlers (supervisor_bloc.dart):**
```dart
on<LoadDetailedUserReportRequested>(_onLoadDetailedUserReportRequested);
on<ExportUserReportRequested>(_onExportUserReportRequested);

Future<void> _onLoadDetailedUserReportRequested(
  LoadDetailedUserReportRequested event,
  Emitter<SupervisorState> emit,
) async {
  emit(const SupervisorLoading());

  final result = await _repository.getDetailedUserReport(
    userId: event.userId,
    startDate: event.startDate,
    endDate: event.endDate,
  );

  result.fold(
    (failure) => emit(SupervisorError(message: failure.message)),
    (detailedReport) => emit(DetailedUserReportLoaded(detailedReport: detailedReport)),
  );
}

Future<void> _onExportUserReportRequested(
  ExportUserReportRequested event,
  Emitter<SupervisorState> emit,
) async {
  emit(const ReportExporting(message: 'Preparing export...'));

  try {
    // First, fetch the detailed report
    final result = await _repository.getDetailedUserReport(
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    await result.fold(
      (failure) async => emit(SupervisorError(message: failure.message)),
      (detailedReport) async {
        // Convert entity to model (you'll need to add a method for this)
        final model = _entityToModel(detailedReport);

        File file;
        if (event.format == 'pdf') {
          emit(const ReportExporting(message: 'Generating PDF...'));
          file = await PdfExportService().exportUserReportToPdf(model);
        } else {
          emit(const ReportExporting(message: 'Generating Excel...'));
          file = await ExcelExportService().exportUserReportToExcel(model);
        }

        emit(ReportExported(filePath: file.path, format: event.format));
      },
    );
  } catch (e) {
    emit(SupervisorError(message: 'Export failed: $e'));
  }
}

// Helper method to convert entity back to model
DetailedUserReportModel _entityToModel(DetailedUserReportEntity entity) {
  // Implementation here
}
```

---

### STEP 6: Create User Detail Page

**What:** Create a comprehensive user detail page with deed table

**Location:** `lib/features/supervisor/presentation/pages/user_detail_page.dart`

**Key Features:**
- User profile header with photo and membership badge
- Summary statistics cards
- Date range selector
- Deed details table with all daily reports
- Export buttons (PDF/Excel)
- Scrollable table with fixed headers

**UI Structure:**
```
┌─────────────────────────────────────┐
│  [←]  User Name                     │
├─────────────────────────────────────┤
│  [Profile Photo] User Info          │
│  Membership Badge                   │
├─────────────────────────────────────┤
│  📊 Statistics Cards                │
│  [Reports] [Avg] [Compliance]       │
├─────────────────────────────────────┤
│  📅 Date Range: [Select Range]      │
│  [📥 PDF] [📥 Excel]                │
├─────────────────────────────────────┤
│  Deed Details Table                 │
│  Date | Fajr | Duha | ... | Total  │
│  ──────────────────────────────────│
│  Jan 15 | ✓ | ✓ | ... | 9.5       │
│  Jan 14 | ✓ | ✗ | ... | 8.0       │
│  ...                                │
└─────────────────────────────────────┘
```

---

### STEP 7: Update User Reports Page with Export

**What:** Add export functionality to the existing UserReportsPage

**Location:** `lib/features/supervisor/presentation/pages/user_reports_page.dart`

**Replace Export Button Handler (line 100-106):**
```dart
IconButton(
  icon: const Icon(Icons.download_outlined, color: AppColors.textPrimary),
  onPressed: () {
    _showExportDialog();
  },
),
```

**Add Export Dialog Method:**
```dart
void _showExportDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Export Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select date range and export format'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _selectDateRangeAndExport();
            },
            icon: const Icon(Icons.date_range),
            label: const Text('Select Date Range'),
          ),
        ],
      ),
    ),
  );
}

void _selectDateRangeAndExport() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DateRangePickerWidget(
      onDateRangeSelected: (startDate, endDate) {
        _showFormatDialog(startDate, endDate);
      },
    ),
  );
}

void _showFormatDialog(DateTime startDate, DateTime endDate) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Export Format'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('PDF'),
            onTap: () {
              Navigator.pop(context);
              _exportAllUsers(startDate, endDate, 'pdf');
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Excel'),
            onTap: () {
              Navigator.pop(context);
              _exportAllUsers(startDate, endDate, 'excel');
            },
          ),
        ],
      ),
    ),
  );
}

void _exportAllUsers(DateTime startDate, DateTime endDate, String format) {
  // Trigger BLoC event to export all users
  // This will require fetching detailed reports for all visible users
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Exporting to ${format.toUpperCase()}...'),
      duration: const Duration(seconds: 2),
    ),
  );

  // TODO: Implement export logic with BLoC
}
```

---

### STEP 8: Update App Router

**What:** Add route for User Detail Page

**Location:** `lib/core/navigation/app_router.dart`

**Add Route:**
```dart
GoRoute(
  path: '/user-detail/:userId',
  name: 'user-detail',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserDetailPage(userId: userId);
  },
),
```

---

### STEP 9: Add Share Functionality

**What:** Add sharing capability for exported files

**Package:** `share_plus: ^7.2.1` (add to pubspec.yaml)

**Usage in BLoC:**
```dart
import 'package:share_plus/share_plus.dart';

// After export completes
await Share.shareXFiles(
  [XFile(file.path)],
  subject: 'User Report - ${DateTime.now()}',
  text: 'Exported user report from Sabiquun App',
);
```

---

## 📋 Testing Checklist

### Unit Tests
- [ ] Test data model serialization/deserialization
- [ ] Test date range picker preset calculations
- [ ] Test PDF generation with sample data
- [ ] Test Excel generation with sample data
- [ ] Test Supabase RPC function with various date ranges

### Integration Tests
- [ ] Test BLoC event handling for detailed report loading
- [ ] Test BLoC event handling for export operations
- [ ] Test repository error handling
- [ ] Test data source error handling

### UI Tests
- [ ] Test User Detail Page rendering
- [ ] Test date range picker interactions
- [ ] Test export button functionality
- [ ] Test loading states during export
- [ ] Test error states and messages
- [ ] Test table scrolling and responsiveness

### End-to-End Tests
- [ ] Test complete flow: Select user → View details → Select date range → Export PDF
- [ ] Test complete flow: All users → Select date range → Export Excel
- [ ] Test with edge cases (no data, single day, large date range)
- [ ] Test with various membership statuses
- [ ] Test with users having missing deed entries

---

## 🚀 Deployment Steps

1. **Run build_runner**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Create Supabase RPC function** (use SQL code from STEP 2)

3. **Test RPC function** in Supabase SQL Editor

4. **Run Flutter app**
   ```bash
   flutter run
   ```

5. **Test supervisor features**
   - Navigate to User Reports
   - Click on a user
   - Select date range
   - Export to PDF/Excel
   - Verify file contents

6. **Fix any runtime errors** and iterate

---

## 📝 Notes

- **Freezed Models:** The models use Freezed for immutability and code generation. Always run build_runner after modifying model files.

- **Performance:** For large date ranges or many users, consider implementing:
  - Pagination for daily reports
  - Background processing for exports
  - Progress indicators with percentages

- **File Storage:** Exported files are currently saved to temporary directory. Consider adding options to:
  - Save to device storage
  - Upload to cloud storage
  - Email to supervisor

- **Permissions:** Ensure the app has necessary permissions for:
  - File writing (Android/iOS storage permissions)
  - Sharing files

- **Error Handling:** Add comprehensive error handling for:
  - Network failures
  - Invalid date ranges
  - Missing data
  - Export failures

---

## 🎯 Success Criteria

The implementation is complete when:

1. ✅ Supervisors can view detailed user reports with full deed breakdowns
2. ✅ Date range filtering works correctly with presets and custom ranges
3. ✅ PDF exports contain properly formatted tables with all deed details
4. ✅ Excel exports contain multiple sheets with comprehensive data
5. ✅ Export functionality works for both single users and all users
6. ✅ UI is responsive and provides clear feedback during operations
7. ✅ Error states are handled gracefully with user-friendly messages
8. ✅ All tests pass

---

**Implementation Status:** 60% Complete (Foundation laid, integration remaining)

**Next Priority:** Run build_runner and implement Supabase RPC function
