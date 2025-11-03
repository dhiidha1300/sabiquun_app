import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../domain/entities/notification_template_entity.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationTemplatesPage extends StatefulWidget {
  const NotificationTemplatesPage({super.key});

  @override
  State<NotificationTemplatesPage> createState() => _NotificationTemplatesPageState();
}

class _NotificationTemplatesPageState extends State<NotificationTemplatesPage> {
  List<NotificationTemplateEntity> _templates = [];
  String? _filterType;
  bool? _filterActive;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    context.read<AdminBloc>().add(LoadNotificationTemplatesRequested(
      templateType: _filterType,
      isActive: _filterActive,
    ));
  }

  void _showTemplateDialog({NotificationTemplateEntity? template}) {
    showDialog(
      context: context,
      builder: (context) => _TemplateFormDialog(
        template: template,
        onSave: (templateKey, title, body, emailSubject, emailBody, notificationType) {
          if (template == null) {
            // Create new template
            context.read<AdminBloc>().add(CreateNotificationTemplateRequested(
              templateKey: templateKey,
              title: title,
              body: body,
              emailSubject: emailSubject.isEmpty ? null : emailSubject,
              emailBody: emailBody.isEmpty ? null : emailBody,
              notificationType: notificationType,
            ));
          } else {
            // Update existing template
            context.read<AdminBloc>().add(UpdateNotificationTemplateRequested(
              templateId: template.id,
              title: title,
              body: body,
              emailSubject: emailSubject.isEmpty ? null : emailSubject,
              emailBody: emailBody.isEmpty ? null : emailBody,
            ));
          }
        },
      ),
    );
  }

  void _deleteTemplate(NotificationTemplateEntity template) {
    if (template.isSystemDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete system default templates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(DeleteNotificationTemplateRequested(
                templateId: template.id,
              ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTemplate(NotificationTemplateEntity template) {
    context.read<AdminBloc>().add(ToggleNotificationTemplateRequested(
      templateId: template.id,
      isEnabled: !template.isEnabled,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Templates'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _filterType = null;
                  _filterActive = null;
                } else if (value == 'active') {
                  _filterActive = true;
                  _filterType = null;
                } else if (value == 'inactive') {
                  _filterActive = false;
                  _filterType = null;
                } else {
                  _filterType = value;
                  _filterActive = null;
                }
              });
              _loadTemplates();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Templates')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(value: 'inactive', child: Text('Inactive Only')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'daily_reminder', child: Text('Daily Reminders')),
              const PopupMenuItem(value: 'grace_warning', child: Text('Grace Warnings')),
              const PopupMenuItem(value: 'weekly_leaderboard', child: Text('Weekly Leaderboards')),
              const PopupMenuItem(value: 'manual', child: Text('Manual Notifications')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTemplates,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(),
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
          } else if (state is NotificationTemplateCreated) {
            Navigator.pop(context); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationTemplateUpdated) {
            Navigator.pop(context); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationTemplateDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationTemplateToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template status updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationTemplatesLoaded) {
            _templates = state.templates.cast<NotificationTemplateEntity>();
          }

          if (_templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notification templates found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showTemplateDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                  ),
                ],
              ),
            );
          }

          // Group templates by type
          final groupedTemplates = <String, List<NotificationTemplateEntity>>{};
          for (var template in _templates) {
            groupedTemplates.putIfAbsent(template.notificationType, () => []).add(template);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadTemplates(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: groupedTemplates.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _formatNotificationType(entry.key),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map((template) => _TemplateCard(
                      template: template,
                      onEdit: () => _showTemplateDialog(template: template),
                      onDelete: () => _deleteTemplate(template),
                      onToggle: () => _toggleTemplate(template),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _formatNotificationType(String type) {
    return type.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}

class _TemplateCard extends StatelessWidget {
  final NotificationTemplateEntity template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    template.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (template.isSystemDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'System',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: template.isEnabled ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    template.isEnabled ? 'Active' : 'Inactive',
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
                Text(
                  'Push: ${template.body}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (template.emailSubject != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Email: ${template.emailSubject}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Key: ${template.templateKey}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
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
                        template.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(template.isEnabled ? 'Disable' : 'Enable'),
                    ],
                  ),
                ),
                if (!template.isSystemDefault)
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
        ],
      ),
    );
  }
}

class _TemplateFormDialog extends StatefulWidget {
  final NotificationTemplateEntity? template;
  final Function(String templateKey, String title, String body, String emailSubject, String emailBody, String notificationType) onSave;

  const _TemplateFormDialog({
    this.template,
    required this.onSave,
  });

  @override
  State<_TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<_TemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _templateKeyController;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _emailSubjectController;
  late TextEditingController _emailBodyController;
  String _notificationType = 'manual';

  @override
  void initState() {
    super.initState();
    _templateKeyController = TextEditingController(text: widget.template?.templateKey ?? '');
    _titleController = TextEditingController(text: widget.template?.title ?? '');
    _bodyController = TextEditingController(text: widget.template?.body ?? '');
    _emailSubjectController = TextEditingController(text: widget.template?.emailSubject ?? '');
    _emailBodyController = TextEditingController(text: widget.template?.emailBody ?? '');
    _notificationType = widget.template?.notificationType ?? 'manual';
  }

  @override
  void dispose() {
    _templateKeyController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.template != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Template' : 'Create Template'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit)
                TextFormField(
                  controller: _templateKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Template Key',
                    hintText: 'e.g., daily_reminder_v1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a template key';
                    }
                    return null;
                  },
                ),
              if (!isEdit) const SizedBox(height: 16),
              if (!isEdit)
                DropdownButtonFormField<String>(
                  initialValue: _notificationType,
                  decoration: const InputDecoration(
                    labelText: 'Notification Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily_reminder', child: Text('Daily Reminder')),
                    DropdownMenuItem(value: 'grace_warning', child: Text('Grace Warning')),
                    DropdownMenuItem(value: 'weekly_leaderboard', child: Text('Weekly Leaderboard')),
                    DropdownMenuItem(value: 'manual', child: Text('Manual Notification')),
                    DropdownMenuItem(value: 'payment_reminder', child: Text('Payment Reminder')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _notificationType = value);
                    }
                  },
                ),
              if (!isEdit) const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Push Notification Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Push Notification Body',
                  hintText: 'Use {{user_name}}, {{balance}}, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a body';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Email Notification (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailSubjectController,
                decoration: const InputDecoration(
                  labelText: 'Email Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailBodyController,
                decoration: const InputDecoration(
                  labelText: 'Email Body',
                  hintText: 'Use {{user_name}}, {{balance}}, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _templateKeyController.text.trim(),
                _titleController.text.trim(),
                _bodyController.text.trim(),
                _emailSubjectController.text.trim(),
                _emailBodyController.text.trim(),
                _notificationType,
              );
            }
          },
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
