import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/user_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load pending users by default
    _loadUsers('pending');

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final status = _getStatusForTab(_tabController.index);
        _loadUsers(status);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers(String? status) {
    context.read<AdminBloc>().add(LoadUsersRequested(
          accountStatus: status,
          searchQuery: _searchQuery,
        ));
  }

  String _getStatusForTab(int index) {
    switch (index) {
      case 0:
        return 'pending';
      case 1:
        return 'active';
      case 2:
        return 'suspended';
      case 3:
        return 'auto_deactivated';
      default:
        return 'active';
    }
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
    final status = _getStatusForTab(_tabController.index);
    _loadUsers(status);
  }

  void _onApproveUser(String userId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmDialog(
      title: 'Approve User',
      message: 'Are you sure you want to approve this user?',
    );

    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(ApproveUserRequested(
            userId: userId,
            approvedBy: currentUserId,
          ));
    }
  }

  void _onRejectUser(String userId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    // Show reason dialog
    final reason = await _showReasonDialog(
      title: 'Reject User',
      message: 'Please provide a reason for rejecting this user:',
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<AdminBloc>().add(RejectUserRequested(
            userId: userId,
            rejectedBy: currentUserId,
            reason: reason,
          ));
    }
  }

  void _onSuspendUser(String userId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    // Show reason dialog
    final reason = await _showReasonDialog(
      title: 'Suspend User',
      message: 'Please provide a reason for suspending this user:',
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<AdminBloc>().add(SuspendUserRequested(
            userId: userId,
            suspendedBy: currentUserId,
            reason: reason,
          ));
    }
  }

  void _onActivateUser(String userId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      _showError('Unable to identify current user');
      return;
    }

    // Show reason dialog
    final reason = await _showReasonDialog(
      title: 'Activate User',
      message: 'Please provide a reason for activating this user:',
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<AdminBloc>().add(ActivateUserRequested(
            userId: userId,
            activatedBy: currentUserId,
            reason: reason,
          ));
    }
  }

  void _onEditUser(String userId) {
    context.push('/admin/user-edit/$userId');
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Suspended'),
            Tab(text: 'Deactivated'),
          ],
        ),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is UserApproved) {
            _showSuccess('User approved successfully');
            // Reload the current tab
            final status = _getStatusForTab(_tabController.index);
            _loadUsers(status);
          } else if (state is UserRejected) {
            _showSuccess('User rejected successfully');
            final status = _getStatusForTab(_tabController.index);
            _loadUsers(status);
          } else if (state is UserSuspended) {
            _showSuccess('User suspended successfully');
            final status = _getStatusForTab(_tabController.index);
            _loadUsers(status);
          } else if (state is UserActivated) {
            _showSuccess('User activated successfully');
            final status = _getStatusForTab(_tabController.index);
            _loadUsers(status);
          } else if (state is UserUpdated) {
            _showSuccess('User updated successfully');
            final status = _getStatusForTab(_tabController.index);
            _loadUsers(status);
          } else if (state is AdminError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onSearch,
                ),
              ),

              // Content area
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AdminState state) {
    if (state is AdminLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is UsersLoaded) {
      if (state.users.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          final status = _getStatusForTab(_tabController.index);
          _loadUsers(status);
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            return UserCard(
              user: user,
              onTap: () => _onEditUser(user.id),
              actions: _buildActionsForUser(user),
            );
          },
        ),
      );
    }

    if (state is AdminError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox.shrink();
  }

  List<UserAction> _buildActionsForUser(user) {
    final actions = <UserAction>[];
    final tabIndex = _tabController.index;

    // Pending tab actions
    if (tabIndex == 0 && user.isPending) {
      actions.addAll([
        UserAction(
          label: 'Approve',
          icon: Icons.check_circle,
          onPressed: () => _onApproveUser(user.id),
          color: Colors.green,
        ),
        UserAction(
          label: 'Reject',
          icon: Icons.cancel,
          onPressed: () => _onRejectUser(user.id),
          color: Colors.red,
        ),
      ]);
    }

    // Active tab actions
    if (tabIndex == 1 && user.isActive) {
      actions.addAll([
        UserAction(
          label: 'Edit',
          icon: Icons.edit,
          onPressed: () => _onEditUser(user.id),
          color: Colors.blue,
        ),
        UserAction(
          label: 'Suspend',
          icon: Icons.block,
          onPressed: () => _onSuspendUser(user.id),
          color: Colors.orange,
        ),
      ]);
    }

    // Suspended tab actions
    if (tabIndex == 2 && user.isSuspended) {
      actions.addAll([
        UserAction(
          label: 'Activate',
          icon: Icons.check_circle,
          onPressed: () => _onActivateUser(user.id),
          color: Colors.green,
        ),
      ]);
    }

    return actions;
  }

  Widget _buildEmptyState() {
    final tabIndex = _tabController.index;
    String message = 'No users found';
    IconData icon = Icons.people_outline;

    switch (tabIndex) {
      case 0:
        message = 'No pending approvals';
        icon = Icons.pending_outlined;
        break;
      case 1:
        message = 'No active users';
        icon = Icons.people;
        break;
      case 2:
        message = 'No suspended users';
        icon = Icons.block;
        break;
      case 3:
        message = 'No deactivated users';
        icon = Icons.person_off;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              final status = _getStatusForTab(_tabController.index);
              _loadUsers(status);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
