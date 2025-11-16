import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_bloc.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_event.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_state.dart';
import 'package:intl/intl.dart';

class ExcuseHistoryPage extends StatefulWidget {
  const ExcuseHistoryPage({super.key});

  @override
  State<ExcuseHistoryPage> createState() => _ExcuseHistoryPageState();
}

class _ExcuseHistoryPageState extends State<ExcuseHistoryPage> {
  ExcuseStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadExcuses();
  }

  void _loadExcuses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ExcuseBloc>().add(
        LoadMyExcusesRequested(
          userId: authState.user.id,
          status: _statusFilter,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ExcuseStatus?>(
                title: const Text('All'),
                value: null,
                groupValue: _statusFilter,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (value) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadExcuses();
                },
              ),
              RadioListTile<ExcuseStatus?>(
                title: const Text('Pending'),
                value: ExcuseStatus.pending,
                groupValue: _statusFilter,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (value) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadExcuses();
                },
              ),
              RadioListTile<ExcuseStatus?>(
                title: const Text('Approved'),
                value: ExcuseStatus.approved,
                groupValue: _statusFilter,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (value) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadExcuses();
                },
              ),
              RadioListTile<ExcuseStatus?>(
                title: const Text('Rejected'),
                value: ExcuseStatus.rejected,
                groupValue: _statusFilter,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (value) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadExcuses();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExcuseDetail(ExcuseEntity excuse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(excuse.excuseType.displayName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(excuse.excuseDate)),
                _buildDetailRow('Status', excuse.status.displayName),
                _buildDetailRow('Affected Deeds', excuse.affectedDeedsDisplay),
                if (excuse.description != null && excuse.description!.isNotEmpty)
                  _buildDetailRow('Description', excuse.description!),
                if (excuse.reviewedBy != null) ...[
                  const Divider(height: 24),
                  const Text(
                    'Review Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Reviewed By', excuse.reviewedBy!),
                  if (excuse.reviewedAt != null)
                    _buildDetailRow(
                      'Reviewed At',
                      DateFormat('MMM dd, yyyy HH:mm').format(excuse.reviewedAt!),
                    ),
                  if (excuse.reviewNotes != null && excuse.reviewNotes!.isNotEmpty)
                    _buildDetailRow('Notes', excuse.reviewNotes!),
                ],
              ],
            ),
          ),
          actions: [
            if (excuse.status.isPending)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(excuse.id);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String excuseId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Excuse'),
          content: const Text('Are you sure you want to delete this excuse request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ExcuseBloc>().add(DeleteExcuseRequested(excuseId));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(ExcuseStatus status) {
    switch (status) {
      case ExcuseStatus.pending:
        return Colors.orange;
      case ExcuseStatus.approved:
        return Colors.green;
      case ExcuseStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ExcuseStatus status) {
    switch (status) {
      case ExcuseStatus.pending:
        return Icons.hourglass_empty;
      case ExcuseStatus.approved:
        return Icons.check_circle;
      case ExcuseStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excuse History'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: BlocConsumer<ExcuseBloc, ExcuseState>(
        listener: (context, state) {
          if (state is ExcuseDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Excuse deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadExcuses();
          } else if (state is ExcuseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExcuseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExcusesLoaded) {
            if (state.excuses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusFilter == null
                          ? 'No excuses yet'
                          : 'No ${_statusFilter!.displayName.toLowerCase()} excuses',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit an excuse when you need one',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadExcuses(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.excuses.length,
                itemBuilder: (context, index) {
                  final excuse = state.excuses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showExcuseDetail(excuse),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(excuse.status),
                                  color: _getStatusColor(excuse.status),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('MMMM dd, yyyy').format(excuse.excuseDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(excuse.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(excuse.status),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    excuse.status.displayName,
                                    style: TextStyle(
                                      color: _getStatusColor(excuse.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  excuse.excuseType.displayName,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.event_note, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    excuse.affectedDeedsDisplay,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            if (excuse.reviewNotes != null && excuse.reviewNotes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Review Notes:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      excuse.reviewNotes!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/excuses/submit'),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: const Text('Submit Excuse'),
      ),
    );
  }
}
