import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Dialog for adding or editing deed templates
class DeedFormDialog extends StatefulWidget {
  final DeedTemplateEntity? deed; // Null for add, populated for edit
  final int nextSortOrder; // For new deeds

  const DeedFormDialog({
    super.key,
    this.deed,
    required this.nextSortOrder,
  });

  @override
  State<DeedFormDialog> createState() => _DeedFormDialogState();
}

class _DeedFormDialogState extends State<DeedFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late String _selectedCategory;
  late String _selectedValueType;
  late bool _isActive;
  bool _autoGenerateKey = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deed?.deedName ?? '');
    _keyController = TextEditingController(text: widget.deed?.deedKey ?? '');
    _selectedCategory = widget.deed?.category ?? 'faraid';
    _selectedValueType = widget.deed?.valueType ?? 'binary';
    _isActive = widget.deed?.isActive ?? true;
    _autoGenerateKey = widget.deed == null;

    // Listen to name changes to auto-generate key
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_autoGenerateKey && _nameController.text.isNotEmpty) {
      final key = _generateKey(_nameController.text);
      _keyController.text = key;
    }
  }

  String _generateKey(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.pop(context);
      return;
    }

    final currentUserId = authState.user.id;

    if (widget.deed == null) {
      // Create new deed
      context.read<AdminBloc>().add(
            CreateDeedTemplateRequested(
              deedName: _nameController.text.trim(),
              deedKey: _keyController.text.trim(),
              category: _selectedCategory,
              valueType: _selectedValueType,
              sortOrder: widget.nextSortOrder,
              isActive: _isActive,
              createdBy: currentUserId,
            ),
          );
    } else {
      // Update existing deed
      context.read<AdminBloc>().add(
            UpdateDeedTemplateRequested(
              templateId: widget.deed!.id,
              deedName: _nameController.text.trim(),
              category: _selectedCategory,
              valueType: _selectedValueType,
              isActive: _isActive,
              updatedBy: currentUserId,
            ),
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.deed != null;
    final isSystemDefault = widget.deed?.isSystemDefault ?? false;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Deed Template' : 'Add New Deed'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deed Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Deed Name *',
                  hintText: 'e.g., Tahajjud Prayer',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSystemDefault,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deed name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Deed name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deed Key
              TextFormField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Deed Key *',
                  hintText: 'e.g., tahajjud_prayer',
                  border: const OutlineInputBorder(),
                  helperText: 'Used for internal identification',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _autoGenerateKey ? Icons.link : Icons.link_off,
                      color: _autoGenerateKey ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _autoGenerateKey = !_autoGenerateKey;
                        if (_autoGenerateKey) {
                          _onNameChanged();
                        }
                      });
                    },
                    tooltip: _autoGenerateKey
                        ? 'Auto-generate from name'
                        : 'Manual input',
                  ),
                ),
                enabled: !isEdit, // Cannot change key after creation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deed key is required';
                  }
                  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                    return 'Only lowercase letters, numbers, and underscores';
                  }
                  return null;
                },
              ),
              if (isEdit)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Key cannot be changed after creation',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 16),

              // Category
              const Text(
                'Category *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Row(
                        children: [
                          Text('🕌'),
                          SizedBox(width: 8),
                          Text('Fara\'id'),
                        ],
                      ),
                      subtitle: const Text('Required'),
                      value: 'faraid',
                      groupValue: _selectedCategory,
                      onChanged: isSystemDefault
                          ? null
                          : (value) {
                              setState(() => _selectedCategory = value!);
                            },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Row(
                        children: [
                          Text('📖'),
                          SizedBox(width: 8),
                          Text('Sunnah'),
                        ],
                      ),
                      subtitle: const Text('Recommended'),
                      value: 'sunnah',
                      groupValue: _selectedCategory,
                      onChanged: isSystemDefault
                          ? null
                          : (value) {
                              setState(() => _selectedCategory = value!);
                            },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Value Type
              const Text(
                'Value Type *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Binary'),
                      subtitle: const Text('Yes/No'),
                      value: 'binary',
                      groupValue: _selectedValueType,
                      onChanged: isSystemDefault
                          ? null
                          : (value) {
                              setState(() => _selectedValueType = value!);
                            },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Fractional'),
                      subtitle: const Text('0.0 - 1.0'),
                      value: 'fractional',
                      groupValue: _selectedValueType,
                      onChanged: isSystemDefault
                          ? null
                          : (value) {
                              setState(() => _selectedValueType = value!);
                            },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Show in daily reports'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Impact Notice
              if (!isEdit)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Impact Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adding this ${_selectedCategory == 'faraid' ? 'Fara\'id' : 'Sunnah'} deed will:\n'
                        '• ${_isActive ? 'Increase' : 'Not affect'} daily target\n'
                        '• Apply to all users immediately\n'
                        '• ${_selectedCategory == 'faraid' ? 'Affect penalty calculations' : 'Not affect penalties'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

              if (isSystemDefault)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'System default deeds cannot be fully edited',
                          style: TextStyle(fontSize: 13, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
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
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
