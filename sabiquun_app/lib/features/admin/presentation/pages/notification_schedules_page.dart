import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/notification_schedule_entity.dart';
import '../../domain/entities/notification_template_entity.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationSchedulesPage extends StatefulWidget {
  const NotificationSchedulesPage({super.key});

  @override
  State<NotificationSchedulesPage> createState() => _NotificationSchedulesPageState();
}

class _NotificationSchedulesPageState extends State<NotificationSchedulesPage> {
  List<NotificationScheduleEntity> _schedules = [];
  List<NotificationTemplateEntity> _templates = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentUser();
  }

  void _loadData() {
    context.read<AdminBloc>().add(const LoadNotificationSchedulesRequested());
    context.read<AdminBloc>().add(const LoadNotificationTemplatesRequested());
  }

  void _getCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _showScheduleDialog({NotificationScheduleEntity? schedule}) {
    if (_templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create notification templates first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ScheduleFormDialog(
        schedule: schedule,
        templates: _templates,
        currentUserId: _currentUserId ?? '',
        onSave: (templateId, time, frequency, daysOfWeek, conditions) {
          if (schedule == null) {
            // Create new schedule
            context.read<AdminBloc>().add(CreateNotificationScheduleRequested(
              notificationTemplateId: templateId,
              scheduledTime: time,
              frequency: frequency,
              daysOfWeek: daysOfWeek,
              conditions: conditions,
              createdBy: _currentUserId ?? '',
            ));
          } else {
            // Update existing schedule
            context.read<AdminBloc>().add(UpdateNotificationScheduleRequested(
              scheduleId: schedule.id,
              notificationTemplateId: templateId,
              scheduledTime: time,
              frequency: frequency,
              daysOfWeek: daysOfWeek,
              conditions: conditions,
            ));
          }
        },
      ),
    );
  }

  void _deleteSchedule(NotificationScheduleEntity schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(DeleteNotificationScheduleRequested(
                scheduleId: schedule.id,
              ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleSchedule(NotificationScheduleEntity schedule) {
    context.read<AdminBloc>().add(ToggleNotificationScheduleRequested(
      scheduleId: schedule.id,
      isActive: !schedule.isActive,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationScheduleCreated) {
            Navigator.pop(context); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationScheduleUpdated) {
            Navigator.pop(context); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationScheduleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationScheduleToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule status updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationSchedulesLoaded) {
            _schedules = state.schedules.cast<NotificationScheduleEntity>();
          } else if (state is NotificationTemplatesLoaded) {
            _templates = state.templates.cast<NotificationTemplateEntity>();
          }

          if (_schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notification schedules found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showScheduleDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Schedule'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                final template = _templates.firstWhere(
                  (t) => t.id == schedule.notificationTemplateId,
                  orElse: () => NotificationTemplateEntity(
                    id: '',
                    templateKey: '',
                    title: 'Unknown Template',
                    body: '',
                    notificationType: '',
                    isEnabled: false,
                    isSystemDefault: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );

                return _ScheduleCard(
                  schedule: schedule,
                  template: template,
                  onEdit: () => _showScheduleDialog(schedule: schedule),
                  onDelete: () => _deleteSchedule(schedule),
                  onToggle: () => _toggleSchedule(schedule),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final NotificationScheduleEntity schedule;
  final NotificationTemplateEntity template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ScheduleCard({
    required this.schedule,
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                template.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: schedule.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                schedule.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('Time: ${schedule.scheduledTime}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.repeat, size: 16),
                const SizedBox(width: 4),
                Text('Frequency: ${_formatFrequency(schedule.frequency)}'),
              ],
            ),
            if (schedule.frequency == 'weekly' && schedule.daysOfWeek != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Days: ${_formatDaysOfWeek(schedule.daysOfWeek!)}'),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'toggle':
                onToggle();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
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
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    schedule.isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(schedule.isActive ? 'Disable' : 'Enable'),
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
        ),
      ),
    );
  }

  String _formatFrequency(String frequency) {
    return frequency[0].toUpperCase() + frequency.substring(1);
  }

  String _formatDaysOfWeek(List<int> days) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((d) => dayNames[d]).join(', ');
  }
}

class _ScheduleFormDialog extends StatefulWidget {
  final NotificationScheduleEntity? schedule;
  final List<NotificationTemplateEntity> templates;
  final String currentUserId;
  final Function(String templateId, String time, String frequency, List<int>? daysOfWeek, Map<String, dynamic>? conditions) onSave;

  const _ScheduleFormDialog({
    this.schedule,
    required this.templates,
    required this.currentUserId,
    required this.onSave,
  });

  @override
  State<_ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<_ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTemplateId;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _frequency = 'daily';
  final List<int> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _selectedTemplateId = widget.schedule!.notificationTemplateId;
      final timeParts = widget.schedule!.scheduledTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _frequency = widget.schedule!.frequency;
      if (widget.schedule!.daysOfWeek != null) {
        _selectedDays.addAll(widget.schedule!.daysOfWeek!);
      }
    } else {
      _selectedTemplateId = widget.templates.first.id;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.schedule != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Schedule' : 'Create Schedule'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTemplateId,
                decoration: const InputDecoration(
                  labelText: 'Notification Template',
                  border: OutlineInputBorder(),
                ),
                items: widget.templates
                    .map((template) => DropdownMenuItem(
                          value: template.id,
                          child: Text(template.title),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedTemplateId = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a template';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'once', child: Text('Once')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                    if (_frequency != 'weekly') {
                      _selectedDays.clear();
                    }
                  });
                },
              ),
              if (_frequency == 'weekly') ...[
                const SizedBox(height: 16),
                const Text(
                  'Select Days:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _DayChip(day: 0, label: 'Sun', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 1, label: 'Mon', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 2, label: 'Tue', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 3, label: 'Wed', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 4, label: 'Thu', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 5, label: 'Fri', selectedDays: _selectedDays, onToggle: _toggleDay),
                    _DayChip(day: 6, label: 'Sat', selectedDays: _selectedDays, onToggle: _toggleDay),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_frequency == 'weekly' && _selectedDays.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one day'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

              widget.onSave(
                _selectedTemplateId!,
                timeString,
                _frequency,
                _frequency == 'weekly' ? _selectedDays : null,
                null, // conditions - can be added later
              );
            }
          },
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final String label;
  final List<int> selectedDays;
  final Function(int) onToggle;

  const _DayChip({
    required this.day,
    required this.label,
    required this.selectedDays,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDays.contains(day);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onToggle(day),
      selectedColor: AppColors.primary.withValues(alpha: 0.3),
      checkmarkColor: AppColors.primary,
    );
  }
}
