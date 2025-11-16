import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';

/// Achievement Tags Management Page
class AchievementTagsPage extends StatefulWidget {
  const AchievementTagsPage({super.key});

  @override
  State<AchievementTagsPage> createState() => _AchievementTagsPageState();
}

class _AchievementTagsPageState extends State<AchievementTagsPage> {
  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() {
    context.read<SupervisorBloc>().add(const LoadAchievementTagsRequested());
  }

  void _showCreateTagDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIcon = '⭐';
    bool autoAssign = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Achievement Tag'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tag Name',
                        hintText: 'e.g., Fajr Champion',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What does this achievement represent?',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Icon',
                      ),
                      items: ['⭐', '🔥', '🏆', '💎', '🌅', '🌙', '✨', '👑']
                          .map((icon) => DropdownMenuItem(
                                value: icon,
                                child: Text(icon, style: const TextStyle(fontSize: 24)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedIcon = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto-assign'),
                      subtitle: const Text('Automatically assign to qualifying users'),
                      value: autoAssign,
                      onChanged: (value) {
                        setState(() => autoAssign = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a tag name')),
                      );
                      return;
                    }

                    context.read<SupervisorBloc>().add(CreateAchievementTagRequested(
                          name: nameController.text,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                          icon: selectedIcon,
                          autoAssign: autoAssign,
                        ));

                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievement Tags'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTags();
        },
        child: BlocConsumer<SupervisorBloc, SupervisorState>(
          listener: (context, state) {
            if (state is AchievementTagCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Achievement tag created successfully')),
              );
              _loadTags();
            } else if (state is AchievementTagDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _loadTags();
            } else if (state is SupervisorError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is SupervisorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AchievementTagsLoaded) {
              if (state.tags.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No achievement tags yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showCreateTagDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Tag'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.tags.length,
                itemBuilder: (context, index) {
                  final tag = state.tags[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            tag.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      title: Text(
                        tag.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tag.description != null) ...[
                            const SizedBox(height: 4),
                            Text(tag.description!),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tag.autoAssign
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag.autoAssign ? 'Auto-assign' : 'Manual',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tag.autoAssign ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${tag.activeUserCount} users',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Achievement Tag'),
                              content: Text(
                                  'Are you sure you want to delete "${tag.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<SupervisorBloc>().add(
                                          DeleteAchievementTagRequested(tagId: tag.id),
                                        );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTagDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
