import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class RestDaysManagementPage extends StatefulWidget {
  const RestDaysManagementPage({super.key});

  @override
  State<RestDaysManagementPage> createState() => _RestDaysManagementPageState();
}

class _RestDaysManagementPageState extends State<RestDaysManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _filterYear;
  List<dynamic> _allRestDays = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filterYear = DateTime.now().year;
    _loadRestDays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRestDays() {
    context.read<AdminBloc>().add(LoadRestDaysRequested(year: _filterYear));
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return null;
  }

  List<dynamic> _getRestDaysForDate(DateTime date) {
    return _allRestDays.where((restDay) {
      try {
        // Handle both entity and dynamic types safely
        // Check for both 'rest_date' and 'date' keys for compatibility
        final dateValue = restDay is Map
            ? (restDay['date'] ?? restDay['rest_date'])
            : restDay.date;
        final endDateValue = restDay is Map ? restDay['end_date'] : restDay.endDate;

        if (dateValue == null) return false;

        final restDayDate = dateValue is DateTime ? dateValue : DateTime.parse(dateValue.toString());
        final checkDate = DateTime(date.year, date.month, date.day);
        final restDate = DateTime(restDayDate.year, restDayDate.month, restDayDate.day);

        // Check if single date matches
        if (endDateValue == null) {
          return restDate.isAtSameMomentAs(checkDate);
        }

        // Check if date falls within range
        final endDayDate = endDateValue is DateTime ? endDateValue : DateTime.parse(endDateValue.toString());
        final endDate = DateTime(endDayDate.year, endDayDate.month, endDayDate.day);
        return (checkDate.isAtSameMomentAs(restDate) || checkDate.isAfter(restDate)) &&
            (checkDate.isAtSameMomentAs(endDate) || checkDate.isBefore(endDate));
      } catch (e) {
        // Silently handle invalid rest day data
        return false;
      }
    }).toList();
  }

  void _showAddRestDayDialog() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _RestDayFormDialog(),
    );

    if (result != null && mounted) {
      context.read<AdminBloc>().add(CreateRestDayRequested(
            date: result['date'],
            endDate: result['endDate'],
            description: result['description'],
            isRecurring: result['isRecurring'],
            createdBy: currentUserId,
          ));
    }
  }

  void _showEditRestDayDialog(dynamic restDay) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RestDayFormDialog(restDay: restDay),
    );

    if (result != null && mounted) {
      // Safely access id
      final id = restDay is Map ? restDay['id'] : restDay.id;

      context.read<AdminBloc>().add(UpdateRestDayRequested(
            restDayId: id,
            date: result['date'],
            endDate: result['endDate'],
            description: result['description'],
            isRecurring: result['isRecurring'],
            updatedBy: currentUserId,
          ));
    }
  }

  void _deleteRestDay(dynamic restDay) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    // Safely access description
    final description = restDay is Map ? (restDay['description'] ?? 'this rest day') : restDay.description;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rest Day'),
        content: Text('Are you sure you want to delete "$description"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Safely access id
      final id = restDay is Map ? restDay['id'] : restDay.id;

      context.read<AdminBloc>().add(DeleteRestDayRequested(
            restDayId: id,
            deletedBy: currentUserId,
          ));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatRestDayDate(Map<String, dynamic> restDay) {
    try {
      // Check for both 'rest_date' and 'date' keys for compatibility
      final dateValue = restDay['date'] ?? restDay['rest_date'];
      final endDateValue = restDay['end_date'];

      final date = dateValue is DateTime ? dateValue : DateTime.parse(dateValue.toString());

      if (endDateValue == null) {
        return '${date.day}/${date.month}/${date.year}';
      }

      final endDate = endDateValue is DateTime ? endDateValue : DateTime.parse(endDateValue.toString());
      return '${date.day}/${date.month}/${date.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  int _calculateDayCount(dynamic restDay) {
    try {
      // Check for both 'rest_date' and 'date' keys for compatibility
      final dateValue = restDay is Map
          ? (restDay['date'] ?? restDay['rest_date'])
          : restDay.date;
      final endDateValue = restDay is Map ? restDay['end_date'] : restDay.endDate;

      if (endDateValue == null) return 1;

      final date = dateValue is DateTime ? dateValue : DateTime.parse(dateValue.toString());
      final endDate = endDateValue is DateTime ? endDateValue : DateTime.parse(endDateValue.toString());

      return endDate.difference(date).inDays + 1;
    } catch (e) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest Days Management'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by year',
            onSelected: (year) {
              setState(() {
                _filterYear = year == 0 ? null : year;
              });
              _loadRestDays();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('All Years')),
              PopupMenuItem(
                value: DateTime.now().year,
                child: Text(DateTime.now().year.toString()),
              ),
              PopupMenuItem(
                value: DateTime.now().year + 1,
                child: Text((DateTime.now().year + 1).toString()),
              ),
              PopupMenuItem(
                value: DateTime.now().year - 1,
                child: Text((DateTime.now().year - 1).toString()),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRestDays,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.list), text: 'List'),
          ],
        ),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is RestDayCreated) {
            _showSuccess('Rest day created successfully');
          } else if (state is RestDayUpdated) {
            _showSuccess('Rest day updated successfully');
          } else if (state is RestDayDeleted) {
            _showSuccess('Rest day deleted successfully');
          } else if (state is AdminError) {
            _showError(state.message);
          } else if (state is RestDaysLoaded) {
            setState(() {
              _allRestDays = state.restDays;
            });
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarView(state),
              _buildListView(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRestDayDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Rest Day'),
      ),
    );
  }

  Widget _buildCalendarView(AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_allRestDays.length} Rest Days',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_filterYear != null)
                    Text(
                      'in $_filterYear',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Calendar
          Card(
            child: TableCalendar(
              firstDay: DateTime(_filterYear ?? 2020, 1, 1),
              lastDay: DateTime(_filterYear ?? 2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getRestDaysForDate,
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),

          // Selected day details
          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDayDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    final restDays = _getRestDaysForDate(_selectedDay!);
    final dateStr = '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (restDays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No rest days on this date'),
              )
            else
              ...restDays.map((restDay) {
                    // Safely access properties from dynamic object
                    final isRecurring = restDay is Map ? (restDay['is_recurring'] ?? false) : restDay.isRecurring;
                    final description = restDay is Map ? (restDay['description'] ?? '') : restDay.description;
                    final isDateRange = restDay is Map ? (restDay['end_date'] != null) : restDay.isDateRange;
                    final formattedDate = restDay is Map
                        ? _formatRestDayDate(Map<String, dynamic>.from(restDay))
                        : restDay.formattedDate;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isRecurring ? Icons.loop : Icons.event_available,
                        color: Colors.green,
                      ),
                      title: Text(description),
                      subtitle: Text(
                        isDateRange
                            ? 'Range: $formattedDate'
                            : 'Single day',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditRestDayDialog(restDay),
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allRestDays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No rest days found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _filterYear != null
                  ? 'Try changing the year filter'
                  : 'Add your first rest day',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadRestDays(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allRestDays.length,
        itemBuilder: (context, index) {
          final restDay = _allRestDays[index];

          // Safely access properties from dynamic object
          final isRecurring = restDay is Map ? (restDay['is_recurring'] ?? false) : restDay.isRecurring;
          final description = restDay is Map ? (restDay['description'] ?? '') : restDay.description;
          final isDateRange = restDay is Map ? (restDay['end_date'] != null) : restDay.isDateRange;
          final formattedDate = restDay is Map
              ? _formatRestDayDate(Map<String, dynamic>.from(restDay))
              : restDay.formattedDate;
          final dayCount = restDay is Map ? _calculateDayCount(restDay) : restDay.dayCount;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isRecurring
                    ? Colors.purple.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
                child: Icon(
                  isRecurring ? Icons.loop : Icons.event,
                  color: isRecurring ? Colors.purple : Colors.green,
                ),
              ),
              title: Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(formattedDate),
                    ],
                  ),
                  if (isRecurring) ...[
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.loop, size: 16),
                        SizedBox(width: 4),
                        Text('Recurring annually'),
                      ],
                    ),
                  ],
                  if (isDateRange) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 16),
                        const SizedBox(width: 4),
                        Text('$dayCount days'),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditRestDayDialog(restDay);
                  } else if (value == 'delete') {
                    _deleteRestDay(restDay);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestDayFormDialog extends StatefulWidget {
  final dynamic restDay;

  const _RestDayFormDialog({this.restDay});

  @override
  State<_RestDayFormDialog> createState() => _RestDayFormDialogState();
}

class _RestDayFormDialogState extends State<_RestDayFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isDateRange = false;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.restDay != null) {
      final restDay = widget.restDay;

      // Safely access properties from dynamic object
      final description = restDay is Map ? (restDay['description'] ?? '') : restDay.description;
      // Check for both 'rest_date' and 'date' keys for compatibility
      final dateValue = restDay is Map
          ? (restDay['date'] ?? restDay['rest_date'])
          : restDay.date;
      final endDateValue = restDay is Map ? restDay['end_date'] : restDay.endDate;
      final isRecurring = restDay is Map ? (restDay['is_recurring'] ?? false) : restDay.isRecurring;

      _descriptionController.text = description;
      _startDate = dateValue is DateTime ? dateValue : DateTime.parse(dateValue.toString());

      if (endDateValue != null) {
        _endDate = endDateValue is DateTime ? endDateValue : DateTime.parse(endDateValue.toString());
        _isDateRange = true;
      }

      _isRecurring = isRecurring;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }
    if (_isDateRange && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date for the range')),
      );
      return;
    }

    Navigator.pop(context, {
      'date': _startDate!,
      'endDate': _isDateRange ? _endDate : null,
      'description': _descriptionController.text.trim(),
      'isRecurring': _isRecurring,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.restDay == null ? 'Add Rest Day' : 'Edit Rest Day'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Eid al-Fitr, Ramadan, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Date Range'),
                subtitle: const Text('Select a range of dates'),
                value: _isDateRange,
                onChanged: (value) {
                  setState(() {
                    _isDateRange = value;
                    if (!value) _endDate = null;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date'),
                subtitle: Text(_startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.edit),
                onTap: _selectStartDate,
              ),
              if (_isDateRange) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: const Text('End Date'),
                  subtitle: Text(_endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Not selected'),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectEndDate,
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Recurring Annually'),
                subtitle: const Text('Repeat this rest day every year'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.restDay == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
