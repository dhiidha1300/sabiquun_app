import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/payments/domain/entities/payment_entity.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/payment_card.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/approve_payment_dialog.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/reject_payment_dialog.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/payment_details_modal.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/payment_filter_panel.dart';
import 'package:sabiquun_app/features/payments/data/services/export_service.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/home/widgets/role_based_scaffold.dart';

/// Payment Review Dashboard for Cashiers
/// Allows cashiers to review, approve, and reject pending payments
class PaymentReviewPage extends StatefulWidget {
  final int initialTab;

  const PaymentReviewPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<PaymentReviewPage> createState() => _PaymentReviewPageState();
}

class _PaymentReviewPageState extends State<PaymentReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PaymentFilterOptions _filterOptions = PaymentFilterOptions();
  final ExportService _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    // Add listener to reload data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          // Pending tab
          context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());
        } else {
          // History tab
          context.read<PaymentBloc>().add(const LoadAllReviewedPaymentsRequested());
        }
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showPaymentDetails(PaymentEntity payment) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PaymentBloc>()),
          BlocProvider.value(value: context.read<PenaltyBloc>()),
        ],
        child: PaymentDetailsModal(
          payment: payment,
          onPaymentApproved: () {
            _loadData();
          },
          onPaymentRejected: () {
            _loadData();
          },
        ),
      ),
    );
  }

  void _approvePayment(PaymentEntity payment) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => ApprovePaymentDialog(
        payment: payment,
        onApprove: (notes) {
          context.read<PaymentBloc>().add(
                ApprovePaymentRequested(
                  paymentId: payment.id,
                  reviewedBy: authState.user.id,
                ),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _rejectPayment(PaymentEntity payment) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => RejectPaymentDialog(
        payment: payment,
        onReject: (reason) {
          context.read<PaymentBloc>().add(
                RejectPaymentRequested(
                  paymentId: payment.id,
                  reviewedBy: authState.user.id,
                  reason: reason,
                ),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => PaymentFilterPanel(
        initialFilters: _filterOptions,
        onApply: (options) {
          setState(() {
            _filterOptions = options;
          });
        },
      ),
    );
  }

  Future<void> _exportToExcel(List<PaymentEntity> payments) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final fileName = 'payments_${DateTime.now().millisecondsSinceEpoch}';
      final fileBytes = await _exportService.exportPaymentsToExcel(
        payments: payments,
        filename: fileName,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Share the file
      await _exportService.shareExcel(fileBytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Excel exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf(List<PaymentEntity> payments) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final fileName = 'payment_report_${DateTime.now().millisecondsSinceEpoch}';
      final pdf = await _exportService.exportPaymentsToPdf(
        payments: payments,
        title: 'Payment Report',
        subtitle: 'Generated on ${DateTime.now()}',
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Share the PDF
      await _exportService.sharePdf(pdf, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ PDF exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExportOptions(List<PaymentEntity> payments) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Payment Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${payments.length} payment(s) will be exported',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export to Excel'),
              subtitle: const Text('Spreadsheet with detailed payment data'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel(payments);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export to PDF'),
              subtitle: const Text('Formatted report with summary statistics'),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf(payments);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedScaffold(
      currentIndex: 1, // Pending tab in cashier nav
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        title: const Text(
          'Payment Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Filter button with active filter badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                tooltip: 'Filter Payments',
              ),
              if (_filterOptions.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_filterOptions.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Export button
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              List<PaymentEntity> payments = [];

              if (state is PendingPaymentsLoaded) {
                payments = state.payments;
              } else if (state is AllReviewedPaymentsLoaded) {
                payments = state.payments;
              }

              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: payments.isEmpty ? null : () => _showExportOptions(payments),
                tooltip: 'Export Data',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by user or reference...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: [
                  BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      int count = 0;
                      if (state is PendingPaymentsLoaded) {
                        count = state.payments.length;
                      }
                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Pending'),
                            if (count > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const Tab(text: 'History'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✓ Payment approved successfully'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'View Receipt',
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Navigate to receipt or generate receipt
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt generation coming soon'),
                      ),
                    );
                  },
                ),
              ),
            );
            _loadData(); // Reload to update UI
          } else if (state is PaymentRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✗ Payment rejected'),
                backgroundColor: Colors.orange,
              ),
            );
            _loadData(); // Reload to update UI
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Pending Payments Tab
            _buildPendingTab(),
            // History Tab
            _buildHistoryTab(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: BlocBuilder<PaymentBloc, PaymentState>(
        buildWhen: (previous, current) {
          // Only rebuild when we have pending payments data or loading/error states
          return current is PaymentLoading ||
                 current is PendingPaymentsLoaded ||
                 current is PaymentError;
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingPaymentsLoaded) {
            final payments = _filterPayments(state.payments);

            if (payments.isEmpty && _searchQuery.isEmpty && !_filterOptions.hasActiveFilters) {
              return _buildEmptyState(
                icon: Icons.check_circle_outline,
                title: 'No Pending Payments',
                subtitle: 'All payments have been reviewed',
              );
            }

            if (payments.isEmpty) {
              return _buildEmptyState(
                icon: Icons.search_off,
                title: 'No Results Found',
                subtitle: 'Try adjusting your search',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetails(payment),
                  onApprove: () => _approvePayment(payment),
                  onReject: () => _rejectPayment(payment),
                );
              },
            );
          }

          if (state is PaymentError) {
            return _buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: state.message,
            );
          }

          // Initial state or other states - trigger load
          Future.microtask(() {
            if (mounted) {
              context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Load all reviewed payments (not filtered by user)
        context.read<PaymentBloc>().add(
              const LoadAllReviewedPaymentsRequested(),
            );
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: BlocBuilder<PaymentBloc, PaymentState>(
        buildWhen: (previous, current) {
          // Only rebuild when we have history payments data or loading/error states
          return current is PaymentLoading ||
                 current is AllReviewedPaymentsLoaded ||
                 current is PaymentError;
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AllReviewedPaymentsLoaded) {
            final payments = _filterPayments(state.payments);

            if (payments.isEmpty && _searchQuery.isEmpty && !_filterOptions.hasActiveFilters) {
              return _buildEmptyState(
                icon: Icons.history,
                title: 'No Payment History',
                subtitle: 'Reviewed payments will appear here',
              );
            }

            if (payments.isEmpty) {
              return _buildEmptyState(
                icon: Icons.search_off,
                title: 'No Results Found',
                subtitle: 'Try adjusting your filters or search',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetails(payment),
                  showActions: false, // Don't show approve/reject for history
                );
              },
            );
          }

          if (state is PaymentError) {
            return _buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: state.message,
            );
          }

          // Initial state - load data
          Future.microtask(() {
            if (mounted) {
              context.read<PaymentBloc>().add(
                    const LoadAllReviewedPaymentsRequested(),
                  );
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  List<PaymentEntity> _filterPayments(List<PaymentEntity> payments) {
    var filtered = payments;

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final ref = payment.referenceNumber?.toLowerCase() ?? '';
        final method = payment.paymentMethodName?.toLowerCase() ?? '';
        final userName = payment.userName?.toLowerCase() ?? '';
        final userEmail = payment.userEmail?.toLowerCase() ?? '';
        return ref.contains(_searchQuery) ||
            method.contains(_searchQuery) ||
            userName.contains(_searchQuery) ||
            userEmail.contains(_searchQuery);
      }).toList();
    }

    // Apply filter options
    if (_filterOptions.paymentMethod != null) {
      filtered = filtered.where((payment) {
        return payment.paymentMethodName == _filterOptions.paymentMethod;
      }).toList();
    }

    if (_filterOptions.startDate != null) {
      filtered = filtered.where((payment) {
        return payment.createdAt.isAfter(_filterOptions.startDate!) ||
            payment.createdAt.isAtSameMomentAs(_filterOptions.startDate!);
      }).toList();
    }

    if (_filterOptions.endDate != null) {
      final endOfDay = DateTime(
        _filterOptions.endDate!.year,
        _filterOptions.endDate!.month,
        _filterOptions.endDate!.day,
        23,
        59,
        59,
      );
      filtered = filtered.where((payment) {
        return payment.createdAt.isBefore(endOfDay) ||
            payment.createdAt.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    if (_filterOptions.minAmount != null) {
      filtered = filtered.where((payment) {
        return payment.amount >= _filterOptions.minAmount!;
      }).toList();
    }

    if (_filterOptions.maxAmount != null) {
      filtered = filtered.where((payment) {
        return payment.amount <= _filterOptions.maxAmount!;
      }).toList();
    }

    if (_filterOptions.status != null) {
      filtered = filtered.where((payment) {
        return payment.status.name == _filterOptions.status;
      }).toList();
    }

    return filtered;
  }
}
