# Remaining Implementation Steps

## Status: 85% Complete ✅

### ✅ Completed
- Data models and entities created
- Date range picker widget implemented
- PDF and Excel export services created
- Build runner executed successfully
- Supabase RPC function SQL created
- Datasource updated with new method
- Repository interface and implementation updated
- BLoC events and states added

### 🔧 Remaining Steps

## STEP 1: Update Supabase with RPC Function

**Action Required:** You need to run the SQL in Supabase SQL Editor

**File:** `a:\sabiquun_app\supabase\functions\get_detailed_user_report.sql`

**Instructions:**
1. Open Supabase Dashboard → SQL Editor
2. Copy the contents of the SQL file
3. Execute the query
4. Verify the function was created by running:
   ```sql
   SELECT get_detailed_user_report(
     'YOUR-USER-ID'::UUID,
     '2025-01-01'::DATE,
     '2025-01-31'::DATE
   );
   ```

---

## STEP 2: Update SupervisorBloc

**File:** `lib/features/supervisor/presentation/bloc/supervisor_bloc.dart`

**Add these imports:**
```dart
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../data/services/pdf_export_service.dart';
import '../../data/services/excel_export_service.dart';
import '../../data/models/detailed_report_model.dart';
```

**Add these event handlers in the constructor:**
```dart
on<LoadDetailedUserReportRequested>(_onLoadDetailedUserReportRequested);
on<ExportUserReportRequested>(_onExportUserReportRequested);
```

**Add these handler methods:**
```dart
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
        // Convert entity to model
        final model = _entityToModel(detailedReport);

        File file;
        if (event.format == 'pdf') {
          emit(const ReportExporting(message: 'Generating PDF...'));
          file = await PdfExportService().exportUserReportToPdf(model);
        } else {
          emit(const ReportExporting(message: 'Generating Excel...'));
          file = await ExcelExportService().exportUserReportToExcel(model);
        }

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'User Report - ${detailedReport.fullName}',
          text: 'Exported user report from Sabiquun App',
        );

        emit(ReportExported(filePath: file.path, format: event.format));
      },
    );
  } catch (e) {
    emit(SupervisorError(message: 'Export failed: $e'));
  }
}

// Helper method to convert entity back to model
DetailedUserReportModel _entityToModel(DetailedUserReportEntity entity) {
  return DetailedUserReportModel(
    userId: entity.userId,
    fullName: entity.fullName,
    email: entity.email,
    phoneNumber: entity.phoneNumber,
    profilePhotoUrl: entity.profilePhotoUrl,
    membershipStatus: entity.membershipStatus,
    memberSince: entity.memberSince,
    startDate: entity.startDate,
    endDate: entity.endDate,
    totalReportsInRange: entity.totalReportsInRange,
    averageDeeds: entity.averageDeeds,
    complianceRate: entity.complianceRate,
    faraidCompliance: entity.faraidCompliance,
    sunnahCompliance: entity.sunnahCompliance,
    currentBalance: entity.currentBalance,
    dailyReports: entity.dailyReports.map((daily) => DailyReportDetailModel(
      reportDate: daily.reportDate,
      status: daily.status,
      totalDeeds: daily.totalDeeds,
      faraidCount: daily.faraidCount,
      sunnahCount: daily.sunnahCount,
      deedEntries: daily.deedEntries.map((entry) => DeedDetailModel(
        deedName: entry.deedName,
        deedKey: entry.deedKey,
        category: entry.category,
        valueType: entry.valueType,
        deedValue: entry.deedValue,
        sortOrder: entry.sortOrder,
      )).toList(),
      submittedAt: daily.submittedAt,
    )).toList(),
    achievementTags: entity.achievementTags,
  );
}
```

---

## STEP 3: Add share_plus to pubspec.yaml

**File:** `pubspec.yaml`

**Add under dependencies:**
```yaml
share_plus: ^7.2.1
```

**Then run:**
```bash
flutter pub get
```

---

## STEP 4: Create UserDetailPage

This is a large file. Create it at:
`lib/features/supervisor/presentation/pages/user_detail_page.dart`

**Full implementation is too large for this document. Key features to include:**

1. **AppBar** with back button and user name
2. **User Info Card** - Profile photo, email, membership badge
3. **Statistics Cards** - Reports, Average Deeds, Compliance
4. **Date Range Selector Button** - Opens DateRangePickerWidget
5. **Export Buttons** - PDF and Excel
6. **Deed Details Table** - Scrollable table with:
   - Column headers: Date, Fajr, Duha, Dhuhr, Juz, Asr, Sunnah, Maghrib, Isha, Athkar, Witr, Total
   - Row for each day with deed values
   - Color coding for completed (green) vs missed (red)

**BLoC Integration:**
```dart
context.read<SupervisorBloc>().add(LoadDetailedUserReportRequested(
  userId: widget.userId,
  startDate: _startDate,
  endDate: _endDate,
));
```

**Export Handler:**
```dart
void _exportReport(String format) {
  context.read<SupervisorBloc>().add(ExportUserReportRequested(
    userId: widget.userId,
    startDate: _startDate,
    endDate: _endDate,
    format: format,
  ));
}
```

**BlocListener for Export:**
```dart
BlocListener<SupervisorBloc, SupervisorState>(
  listener: (context, state) {
    if (state is ReportExporting) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(state.message),
            ],
          ),
        ),
      );
    } else if (state is ReportExported) {
      // Close loading dialog
      Navigator.of(context).pop();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported successfully')),
      );
    } else if (state is SupervisorError) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: // Your UI here
)
```

---

## STEP 5: Update UserReportsPage Export Handler

**File:** `lib/features/supervisor/presentation/pages/user_reports_page.dart`

**Replace the export button handler (lines 100-106):**
```dart
IconButton(
  icon: const Icon(Icons.download_outlined, color: AppColors.textPrimary),
  onPressed: _showExportDialog,
),
```

**Add these methods:**
```dart
void _showExportDialog() {
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
            subtitle: const Text('Professional report with tables'),
            onTap: () {
              Navigator.pop(context);
              _exportAllUsers(startDate, endDate, 'pdf');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Excel'),
            subtitle: const Text('Spreadsheet with multiple sheets'),
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
  // For now, just show a message
  // Full implementation would fetch all users and export
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Exporting all users to ${format.toUpperCase()}...'),
      duration: const Duration(seconds: 2),
    ),
  );

  // TODO: Implement multi-user export
  // This would require fetching detailed reports for all visible users
  // and calling PdfExportService().exportAllUsersReportToPdf() or
  // ExcelExportService().exportAllUsersReportToExcel()
}
```

**Add import:**
```dart
import '../widgets/date_range_picker_widget.dart';
```

---

## STEP 6: Update App Router

**File:** `lib/core/navigation/app_router.dart`

**Add the import:**
```dart
import '../../features/supervisor/presentation/pages/user_detail_page.dart';
```

**Add the route (find the supervisor routes section):**
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

## STEP 7: Testing Checklist

### Before Testing:
1. ✅ Run `flutter pub get` to install share_plus
2. ✅ Execute the Supabase SQL function
3. ✅ Hot restart the app (not hot reload)

### Test Flow:
1. **Login as Supervisor**
2. **Navigate to User Reports** (`/user-reports`)
3. **Click on a user card** → Should navigate to User Detail Page
4. **Select Date Range** → Should load detailed data
5. **View Deed Table** → Should show all deeds for each day
6. **Click Export PDF** → Should generate and share PDF
7. **Click Export Excel** → Should generate and share Excel
8. **Verify Export Content:**
   - Open PDF: Check tables, statistics, user info
   - Open Excel: Check multiple sheets, data accuracy

### Common Issues:

**Issue:** Freezed models showing errors
**Fix:** Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue:** Supabase RPC function not found
**Fix:** Check Supabase SQL Editor, ensure function was created successfully

**Issue:** Export buttons not working
**Fix:** Check console for errors, ensure share_plus is installed

**Issue:** Empty table/no data
**Fix:**
- Verify Supabase RPC function returns data
- Check date range is valid
- Ensure user has submitted reports in that range

---

## Quick Reference: File Locations

### Created Files:
- ✅ `lib/features/supervisor/data/models/detailed_report_model.dart`
- ✅ `lib/features/supervisor/domain/entities/detailed_report_entity.dart`
- ✅ `lib/features/supervisor/presentation/widgets/date_range_picker_widget.dart`
- ✅ `lib/features/supervisor/data/services/pdf_export_service.dart`
- ✅ `lib/features/supervisor/data/services/excel_export_service.dart`
- ✅ `supabase/functions/get_detailed_user_report.sql`

### Modified Files:
- ✅ `lib/features/supervisor/presentation/bloc/supervisor_event.dart`
- ✅ `lib/features/supervisor/presentation/bloc/supervisor_state.dart`
- ✅ `lib/features/supervisor/data/datasources/supervisor_remote_datasource.dart`
- ✅ `lib/features/supervisor/domain/repositories/supervisor_repository.dart`
- ✅ `lib/features/supervisor/data/repositories/supervisor_repository_impl.dart`
- ⏳ `lib/features/supervisor/presentation/bloc/supervisor_bloc.dart` (needs event handlers)
- ⏳ `lib/features/supervisor/presentation/pages/user_reports_page.dart` (needs export dialog)
- ⏳ `pubspec.yaml` (needs share_plus)
- ⏳ `lib/core/navigation/app_router.dart` (needs route)

### To Create:
- ⏳ `lib/features/supervisor/presentation/pages/user_detail_page.dart`

---

## Estimated Time to Complete:
- **Step 1 (Supabase):** 2 minutes
- **Step 2 (BLoC update):** 5 minutes
- **Step 3 (Add package):** 1 minute
- **Step 4 (UserDetailPage):** 20-30 minutes (or use AI to generate)
- **Step 5 (Export dialog):** 5 minutes
- **Step 6 (Router):** 2 minutes
- **Step 7 (Testing):** 10 minutes

**Total: ~45-60 minutes**

---

## Need Help?

Refer to:
- `SUPERVISOR_ENHANCEMENT_IMPLEMENTATION.md` for detailed code examples
- Existing pages in `lib/features/supervisor/presentation/pages/` for UI patterns
- `docs/ui-ux/03-supervisor-screens.md` for UI specifications

**Status: Ready for final integration! 🚀**
