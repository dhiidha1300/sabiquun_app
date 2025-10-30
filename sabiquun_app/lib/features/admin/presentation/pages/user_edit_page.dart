import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/account_status.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../domain/entities/user_management_entity.dart';

class UserEditPage extends StatefulWidget {
  final String userId;

  const UserEditPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  UserRole? _selectedRole;
  String? _selectedMembershipStatus;
  AccountStatus? _selectedAccountStatus;

  UserManagementEntity? _originalUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add listeners to text controllers to trigger rebuilds
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    context.read<AdminBloc>().add(LoadUserByIdRequested(widget.userId));
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _populateForm(UserManagementEntity user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _selectedRole = user.role;
    _selectedMembershipStatus = user.membershipStatus;
    _selectedAccountStatus = user.accountStatus;
    _originalUser = user;
  }

  bool _hasChanges() {
    if (_originalUser == null) return false;

    return _nameController.text != _originalUser!.name ||
        _emailController.text != _originalUser!.email ||
        _phoneController.text != (_originalUser!.phone ?? '') ||
        _selectedRole != _originalUser!.role ||
        _selectedMembershipStatus != _originalUser!.membershipStatus ||
        _selectedAccountStatus != _originalUser!.accountStatus;
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for the changes')),
      );
      return;
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify current user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare update data
    String? name;
    String? email;
    String? phone;
    String? role;
    String? membershipStatus;
    String? accountStatus;

    if (_nameController.text != _originalUser!.name) {
      name = _nameController.text;
    }
    if (_emailController.text != _originalUser!.email) {
      email = _emailController.text;
    }
    if (_phoneController.text != (_originalUser!.phone ?? '')) {
      phone = _phoneController.text.isEmpty ? null : _phoneController.text;
    }
    if (_selectedRole != _originalUser!.role) {
      role = _selectedRole!.name;
    }
    if (_selectedMembershipStatus != _originalUser!.membershipStatus) {
      membershipStatus = _selectedMembershipStatus;
    }
    if (_selectedAccountStatus != _originalUser!.accountStatus) {
      accountStatus = _selectedAccountStatus!.name;
    }

    context.read<AdminBloc>().add(UpdateUserRequested(
          userId: widget.userId,
          name: name,
          email: email,
          phone: phone,
          role: role,
          membershipStatus: membershipStatus,
          accountStatus: accountStatus,
          updatedBy: currentUserId,
          reason: reason,
        ));
  }

  void _changeRole() async {
    if (_originalUser == null) return;

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify current user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRole = await _showRoleDialog();
    if (newRole == null || newRole == _originalUser!.role) return;

    final reason = await _showReasonDialog(
      title: 'Change User Role',
      message: 'Please provide a reason for changing the role:',
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<AdminBloc>().add(ChangeUserRoleRequested(
            userId: widget.userId,
            newRole: newRole.name,
            changedBy: currentUserId,
            reason: reason,
          ));
    }
  }

  Future<UserRole?> _showRoleDialog() {
    return showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<UserRole>(
              title: Text(role.displayName),
              subtitle: Text(_getRoleDescription(role)),
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrative access';
      case UserRole.supervisor:
        return 'Supervisor access';
      case UserRole.cashier:
        return 'Cashier access';
      case UserRole.user:
        return 'Standard user access';
    }
  }

  Future<String?> _showReasonDialog({
    required String title,
    required String message,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(context, reason);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        actions: [
          if (_originalUser != null && _originalUser!.role != UserRole.admin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Change Role',
              onPressed: _changeRole,
            ),
          if (_hasChanges())
            TextButton.icon(
              onPressed: _isLoading ? null : _saveChanges,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is UserDetailLoaded) {
            setState(() {
              _isLoading = false;
            });
            _populateForm(state.user);
          } else if (state is UserUpdated || state is UserRoleChanged) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload user data
            _loadUserData();
            // Clear reason field
            _reasonController.clear();
          } else if (state is AdminError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        builder: (context, state) {
          if (state is AdminLoading && _originalUser == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_originalUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load user data'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadUserData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info card
                  _buildUserInfoCard(),
                  const SizedBox(height: 24),

                  // Edit form
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Role dropdown
                  Text(
                    'Role & Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Membership status dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMembershipStatus,
                    decoration: const InputDecoration(
                      labelText: 'Membership Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_membership),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'new', child: Text('New Member')),
                      DropdownMenuItem(value: 'exclusive', child: Text('Exclusive')),
                      DropdownMenuItem(value: 'legacy', child: Text('Legacy')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMembershipStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account status dropdown
                  DropdownButtonFormField<AccountStatus>(
                    value: _selectedAccountStatus,
                    decoration: const InputDecoration(
                      labelText: 'Account Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                    items: AccountStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Reason field (only show if there are changes)
                  if (_hasChanges()) ...[
                    Text(
                      'Reason for Changes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Explain why these changes are being made...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (_hasChanges() && (value == null || value.trim().isEmpty)) {
                          return 'Please provide a reason for the changes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _saveChanges,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_originalUser == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    _originalUser!.name.isNotEmpty ? _originalUser!.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _originalUser!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _originalUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Balance', '${_originalUser!.currentBalance.toStringAsFixed(0)} Sh'),
                _buildStatItem('Reports', _originalUser!.totalReports.toString()),
                _buildStatItem('Compliance', '${(_originalUser!.complianceRate * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
