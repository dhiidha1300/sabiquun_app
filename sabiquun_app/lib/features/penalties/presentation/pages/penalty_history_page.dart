import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/penalty_bloc.dart';
import '../bloc/penalty_event.dart';
import '../bloc/penalty_state.dart';
import '../widgets/penalty_card.dart';
import '../widgets/penalty_balance_card.dart';

class PenaltyHistoryPage extends StatefulWidget {
  final String userId;

  const PenaltyHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<PenaltyHistoryPage> createState() => _PenaltyHistoryPageState();
}

class _PenaltyHistoryPageState extends State<PenaltyHistoryPage> {
  String? _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<PenaltyBloc>().add(LoadPenaltyBalanceRequested(widget.userId));
    context.read<PenaltyBloc>().add(LoadPenaltiesRequested(
          userId: widget.userId,
          statusFilter: _selectedFilter,
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty History'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<PenaltyBloc, PenaltyState>(
        listener: (context, state) {
          if (state is PenaltyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PenaltyLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
            },
            child: CustomScrollView(
              slivers: [
                // Balance Card
                SliverToBoxAdapter(
                  child: BlocBuilder<PenaltyBloc, PenaltyState>(
                    builder: (context, state) {
                      if (state is PenaltyBalanceLoaded) {
                        return PenaltyBalanceCard(
                          balance: state.balance,
                          onPayNow: () {
                            Navigator.pushNamed(context, '/payments');
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Active Filters
                if (_selectedFilter != null || _startDate != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_selectedFilter != null)
                            Chip(
                              label: Text(_selectedFilter!),
                              onDeleted: () {
                                setState(() {
                                  _selectedFilter = null;
                                });
                                _loadData();
                              },
                            ),
                          if (_startDate != null)
                            Chip(
                              label: Text(
                                'From: ${DateFormat('MMM dd').format(_startDate!)}',
                              ),
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                });
                                _loadData();
                              },
                            ),
                          if (_endDate != null)
                            Chip(
                              label: Text(
                                'To: ${DateFormat('MMM dd').format(_endDate!)}',
                              ),
                              onDeleted: () {
                                setState(() {
                                  _endDate = null;
                                });
                                _loadData();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                // Penalties List
                if (state is PenaltiesLoaded) ...[
                  if (state.penalties.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No penalties found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Keep up the good work!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final penalty = state.penalties[index];
                          return PenaltyCard(
                            penalty: penalty,
                            onTap: () {
                              _showPenaltyDetails(penalty.id);
                            },
                          );
                        },
                        childCount: state.penalties.length,
                      ),
                    ),
                ] else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('Load penalties to view history'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Penalties'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Filter
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedFilter = null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Unpaid'),
                      selected: _selectedFilter == 'unpaid',
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedFilter = selected ? 'unpaid' : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Paid'),
                      selected: _selectedFilter == 'paid',
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedFilter = selected ? 'paid' : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Waived'),
                      selected: _selectedFilter == 'waived',
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedFilter = selected ? 'waived' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Range
                const Text(
                  'Date Range',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Start Date',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _endDate = date;
                            });
                          }
                        },
                        child: Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'End Date',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _loadData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showPenaltyDetails(String penaltyId) {
    Navigator.pushNamed(
      context,
      '/penalty-details',
      arguments: penaltyId,
    );
  }
}
