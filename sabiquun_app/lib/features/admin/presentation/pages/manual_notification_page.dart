import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../../../core/theme/app_colors.dart';

class ManualNotificationPage extends StatefulWidget {
  const ManualNotificationPage({super.key});

  @override
  State<ManualNotificationPage> createState() => _ManualNotificationPageState();
}

class _ManualNotificationPageState extends State<ManualNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  List<UserManagementEntity> _allUsers = [];
  final List<String> _selectedUserIds = [];
  bool _selectAll = false;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<AdminBloc>().add(LoadUsersRequested(
      accountStatus: _filterStatus,
    ));
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedUserIds.clear();
        _selectedUserIds.addAll(_allUsers.map((u) => u.id));
      } else {
        _selectedUserIds.clear();
      }
    });
  }

  void _toggleUser(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
        _selectAll = false;
      } else {
        _selectedUserIds.add(userId);
        if (_selectedUserIds.length == _allUsers.length) {
          _selectAll = true;
        }
      }
    });
  }

  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one user'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Send Notification'),
          content: Text(
            'Send notification to ${_selectedUserIds.length} user(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AdminBloc>().add(SendManualNotificationRequested(
                  userIds: _selectedUserIds,
                  title: _titleController.text.trim(),
                  body: _bodyController.text.trim(),
                  notificationType: 'manual',
                ));
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Manual Notification'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Users',
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'all' ? null : value;
                _selectedUserIds.clear();
                _selectAll = false;
              });
              _loadUsers();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Users')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(value: 'pending', child: Text('Pending Only')),
              const PopupMenuItem(value: 'suspended', child: Text('Suspended Only')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
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
          } else if (state is ManualNotificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification sent to ${state.userCount} user(s)'),
                backgroundColor: Colors.green,
              ),
            );
            // Clear form
            _titleController.clear();
            _bodyController.clear();
            _selectedUserIds.clear();
            setState(() => _selectAll = false);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsersLoaded) {
            _allUsers = state.users;
          }

          return Column(
            children: [
              // Notification Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                          hintText: 'Enter your notification message...',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_selectedUserIds.length} user(s) selected',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _sendNotification,
                            icon: const Icon(Icons.send),
                            label: const Text('Send Notification'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // User Selection
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Select Recipients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _toggleSelectAll,
                      icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
                      label: Text(_selectAll ? 'Deselect All' : 'Select All'),
                    ),
                  ],
                ),
              ),
              // User List
              Expanded(
                child: _allUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _allUsers.length,
                        itemBuilder: (context, index) {
                          final user = _allUsers[index];
                          final isSelected = _selectedUserIds.contains(user.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (_) => _toggleUser(user.id),
                              title: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _StatusBadge(status: user.accountStatus.value),
                                      const SizedBox(width: 8),
                                      _RoleBadge(role: user.role.value),
                                    ],
                                  ),
                                ],
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      case 'auto_deactivated':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case 'admin':
        color = Colors.purple;
        break;
      case 'cashier':
        color = Colors.blue;
        break;
      case 'supervisor':
        color = Colors.teal;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
