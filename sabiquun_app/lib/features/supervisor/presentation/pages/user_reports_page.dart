import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/user_report_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/users_table_view.dart';

/// User Reports Dashboard Page
class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _membershipFilter;
  String? _complianceFilter;
  String? _reportStatusFilter;
  String _sortBy = 'name';
  bool _isTableView = false; // Toggle between card and table view
  DateTime? _dateRangeStart;
  DateTime? _dateRangeEnd;

  @override
  void initState() {
    super.initState();
    // Initialize with last 7 days
    _dateRangeEnd = DateTime.now();
    _dateRangeStart = _dateRangeEnd!.subtract(const Duration(days: 6));
    _loadUserReports();
  }

  void _loadDailyDeeds() {
    if (_dateRangeStart != null && _dateRangeEnd != null) {
      context.read<SupervisorBloc>().add(LoadDailyDeedsRequested(
            startDate: _dateRangeStart!,
            endDate: _dateRangeEnd!,
          ));
    }
  }

  void _loadUserReports() {
    context.read<SupervisorBloc>().add(LoadUserReportsRequested(
          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
          membershipStatus: _membershipFilter,
          complianceFilter: _complianceFilter,
          reportStatus: _reportStatusFilter,
          sortBy: _sortBy,
        ));
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        membershipFilter: _membershipFilter,
        complianceFilter: _complianceFilter,
        reportStatusFilter: _reportStatusFilter,
        sortBy: _sortBy,
        onApply: (membership, compliance, reportStatus, sortBy) {
          setState(() {
            _membershipFilter = membership;
            _complianceFilter = compliance;
            _reportStatusFilter = reportStatus;
            _sortBy = sortBy;
          });
          _loadUserReports();
        },
        onClear: () {
          setState(() {
            _membershipFilter = null;
            _complianceFilter = null;
            _reportStatusFilter = null;
            _sortBy = 'name';
          });
          _loadUserReports();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All User Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          // View toggle button
          IconButton(
            icon: Icon(
              _isTableView ? Icons.view_list : Icons.table_chart,
              color: AppColors.textPrimary,
            ),
            tooltip: _isTableView ? 'Card View' : 'Table View',
            onPressed: () {
              setState(() {
                _isTableView = !_isTableView;
              });
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _membershipFilter != null ||
                  _complianceFilter != null ||
                  _reportStatusFilter != null,
              child: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadUserReports();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadUserReports();
                  }
                });
              },
            ),
          ),

          // User Reports List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadUserReports();
              },
              child: BlocConsumer<SupervisorBloc, SupervisorState>(
                listener: (context, state) {
                  // Load daily deeds when user reports are loaded
                  if (state is UserReportsLoaded && state.dailyDeeds == null) {
                    _loadDailyDeeds();
                  }
                },
                builder: (context, state) {
                  if (state is SupervisorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SupervisorError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUserReports,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UserReportsLoaded) {
                    if (state.userReports.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show table or card view based on toggle
                    if (_isTableView) {
                      return UsersTableView(
                        users: state.userReports,
                        dailyDeeds: state.dailyDeeds,
                        dateRangeStart: state.dateRangeStart ?? _dateRangeStart,
                        dateRangeEnd: state.dateRangeEnd ?? _dateRangeEnd,
                        onExport: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Exporting table...')),
                          );
                          // TODO: Implement table export
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.userReports.length,
                      itemBuilder: (context, index) {
                        final userReport = state.userReports[index];
                        return UserReportCard(
                          userReport: userReport,
                          onTap: () {
                            context.push('/user-detail/${userReport.userId}');
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
