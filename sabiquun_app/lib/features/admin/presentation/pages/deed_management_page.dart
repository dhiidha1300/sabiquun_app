import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/deed_form_dialog.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Deed Management Page for managing deed templates
/// Features:
/// - List all deed templates (active and inactive)
/// - Drag and drop to reorder templates
/// - Create new deed templates
/// - Edit existing templates
/// - Deactivate/delete templates
/// - Visual distinction between Fara'id and Sunnah deeds
/// - System default protection (cannot delete system deeds)
class DeedManagementPage extends StatefulWidget {
  const DeedManagementPage({super.key});

  @override
  State<DeedManagementPage> createState() => _DeedManagementPageState();
}

class _DeedManagementPageState extends State<DeedManagementPage> {
  List<DeedTemplateEntity> _templates = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _getCurrentUser();
  }

  void _loadTemplates() {
    context.read<AdminBloc>().add(const LoadDeedTemplatesRequested());
  }

  void _getCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deed Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTemplates,
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
          } else if (state is DeedTemplateCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deed template created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeedTemplateUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deed template updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeedTemplateDeactivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deed template deactivated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeedTemplatesReordered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deed templates reordered successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeedTemplatesLoaded) {
            _templates = state.templates;
          }

          if (_templates.isEmpty) {
            return const Center(
              child: Text('No deed templates found'),
            );
          }

          return _buildDeedList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeedDialog,
        tooltip: 'Add New Deed',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeedList() {
    // Separate into Fara'id and Sunnah
    final faraidDeeds = _templates.where((t) => t.category == 'faraid').toList();
    final sunnahDeeds = _templates.where((t) => t.category == 'sunnah').toList();

    return RefreshIndicator(
      onRefresh: () async => _loadTemplates(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Deed Target',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_templates.where((t) => t.isActive).length} deeds',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${faraidDeeds.where((t) => t.isActive).length} Fara\'id + ${sunnahDeeds.where((t) => t.isActive).length} Sunnah',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Fara'id Section
          _buildSectionHeader(
            '🕌 Fara\'id Deeds',
            faraidDeeds.length,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          ...faraidDeeds.map((deed) => _buildDeedCard(deed)),

          const SizedBox(height: 24),

          // Sunnah Section
          _buildSectionHeader(
            '📖 Sunnah Deeds',
            sunnahDeeds.length,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          ...sunnahDeeds.map((deed) => _buildDeedCard(deed)),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _reorderDeeds(),
          child: const Row(
            children: [
              Icon(Icons.swap_vert, size: 18),
              SizedBox(width: 4),
              Text('Reorder'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeedCard(DeedTemplateEntity deed) {
    final isActive = deed.isActive;
    final isSystemDefault = deed.isSystemDefault;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 2 : 0,
      color: isActive ? null : Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: deed.category == 'faraid'
                ? Colors.purple.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              deed.category == 'faraid' ? '🕌' : '📖',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                deed.deedName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? null : Colors.grey,
                ),
              ),
            ),
            if (isSystemDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 12, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'System',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(
                  deed.valueType == 'binary' ? 'Binary' : 'Fractional',
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  'Order: ${deed.sortOrder}',
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  isActive ? 'Active' : 'Inactive',
                  isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleDeedAction(value, deed),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (!isSystemDefault)
              PopupMenuItem(
                value: isActive ? 'deactivate' : 'activate',
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(isActive ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
            if (!isSystemDefault)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleDeedAction(String action, DeedTemplateEntity deed) {
    switch (action) {
      case 'edit':
        _showEditDeedDialog(deed);
        break;
      case 'deactivate':
        _deactivateDeed(deed);
        break;
      case 'activate':
        _activateDeed(deed);
        break;
      case 'delete':
        _deleteDeed(deed);
        break;
    }
  }

  void _showAddDeedDialog() {
    // Calculate next sort order
    final nextSortOrder = _templates.isEmpty
        ? 1
        : (_templates.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1);

    showDialog(
      context: context,
      builder: (context) => DeedFormDialog(
        nextSortOrder: nextSortOrder,
      ),
    );
  }

  void _showEditDeedDialog(DeedTemplateEntity deed) {
    showDialog(
      context: context,
      builder: (context) => DeedFormDialog(
        deed: deed,
        nextSortOrder: deed.sortOrder,
      ),
    );
  }

  void _deactivateDeed(DeedTemplateEntity deed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Deed'),
        content: Text(
          'Are you sure you want to deactivate "${deed.deedName}"?\n\n'
          'This will:\n'
          '• Remove it from daily reports\n'
          '• Reduce the daily deed target\n'
          '• Keep historical data intact',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentUserId != null) {
                context.read<AdminBloc>().add(
                      DeactivateDeedTemplateRequested(
                        templateId: deed.id,
                        deactivatedBy: _currentUserId!,
                        reason: 'Deactivated by admin',
                      ),
                    );
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _activateDeed(DeedTemplateEntity deed) {
    if (_currentUserId != null) {
      context.read<AdminBloc>().add(
            UpdateDeedTemplateRequested(
              templateId: deed.id,
              isActive: true,
              updatedBy: _currentUserId!,
            ),
          );
    }
  }

  void _deleteDeed(DeedTemplateEntity deed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deed'),
        content: Text(
          'Are you sure you want to delete "${deed.deedName}"?\n\n'
          'This action will deactivate the deed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (_currentUserId != null) {
                context.read<AdminBloc>().add(
                      DeactivateDeedTemplateRequested(
                        templateId: deed.id,
                        deactivatedBy: _currentUserId!,
                        reason: 'Deleted by admin',
                      ),
                    );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reorderDeeds() {
    showDialog(
      context: context,
      builder: (dialogContext) => _ReorderDeedsDialog(
        templates: _templates,
        onReorder: (reorderedTemplateIds) {
          if (_currentUserId != null) {
            context.read<AdminBloc>().add(
                  ReorderDeedTemplatesRequested(
                    templateIds: reorderedTemplateIds,
                    updatedBy: _currentUserId!,
                  ),
                );
          }
        },
      ),
    );
  }
}

/// Dialog for reordering deed templates with drag-and-drop
class _ReorderDeedsDialog extends StatefulWidget {
  final List<DeedTemplateEntity> templates;
  final Function(List<String>) onReorder;

  const _ReorderDeedsDialog({
    required this.templates,
    required this.onReorder,
  });

  @override
  State<_ReorderDeedsDialog> createState() => _ReorderDeedsDialogState();
}

class _ReorderDeedsDialogState extends State<_ReorderDeedsDialog> {
  late List<DeedTemplateEntity> _reorderedTemplates;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Create a copy sorted by current sort_order
    _reorderedTemplates = List.from(widget.templates)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      _hasChanges = true;
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _reorderedTemplates.removeAt(oldIndex);
      _reorderedTemplates.insert(newIndex, item);
    });
  }

  void _save() {
    final templateIds = _reorderedTemplates.map((t) => t.id).toList();
    widget.onReorder(templateIds);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Separate by category for better UX
    final faraidDeeds = _reorderedTemplates.where((t) => t.category == 'faraid').toList();
    final sunnahDeeds = _reorderedTemplates.where((t) => t.category == 'sunnah').toList();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.swap_vert),
          SizedBox(width: 8),
          Text('Reorder Deeds'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Drag to reorder deeds. This will affect the order shown in daily reports.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Fara'id Section
              if (faraidDeeds.isNotEmpty) ...[
                const Text(
                  '🕌 Fara\'id Deeds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildReorderableSection(faraidDeeds, 'faraid'),
                const SizedBox(height: 16),
              ],

              // Sunnah Section
              if (sunnahDeeds.isNotEmpty) ...[
                const Text(
                  '📖 Sunnah Deeds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildReorderableSection(sunnahDeeds, 'sunnah'),
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
        FilledButton(
          onPressed: _hasChanges ? _save : null,
          child: const Text('Save Order'),
        ),
      ],
    );
  }

  Widget _buildReorderableSection(List<DeedTemplateEntity> deeds, String category) {
    final categoryColor = category == 'faraid' ? Colors.purple : Colors.blue;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deeds.length,
      onReorder: (oldIndex, newIndex) {
        // Find the actual indices in the full list
        final oldItem = deeds[oldIndex];
        final fullOldIndex = _reorderedTemplates.indexWhere((t) => t.id == oldItem.id);

        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final newItem = deeds[newIndex];
        final fullNewIndex = _reorderedTemplates.indexWhere((t) => t.id == newItem.id);

        _onReorder(fullOldIndex, fullNewIndex);
      },
      itemBuilder: (context, index) {
        final deed = deeds[index];
        return Card(
          key: ValueKey(deed.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      category == 'faraid' ? '🕌' : '📖',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              deed.deedName,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              '${deed.valueType} • Order: ${deed.sortOrder}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: deed.isSystemDefault
                ? const Icon(Icons.lock, size: 16, color: Colors.orange)
                : null,
          ),
        );
      },
    );
  }
}
