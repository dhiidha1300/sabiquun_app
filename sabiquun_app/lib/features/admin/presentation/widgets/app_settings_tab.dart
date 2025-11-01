import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AppSettingsTab extends StatefulWidget {
  final SystemSettingsEntity settings;

  const AppSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  State<AppSettingsTab> createState() => _AppSettingsTabState();
}

class _AppSettingsTabState extends State<AppSettingsTab> {
  late TextEditingController _appVersionController;
  late TextEditingController _minVersionController;
  late TextEditingController _updateTitleController;
  late TextEditingController _updateMessageController;
  late TextEditingController _iosMinVersionController;
  late TextEditingController _androidMinVersionController;
  late TextEditingController _reasonController;

  final _formKey = GlobalKey<FormState>();
  bool _forceUpdate = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _appVersionController = TextEditingController(
      text: widget.settings.appVersion,
    );
    _minVersionController = TextEditingController(
      text: widget.settings.minimumRequiredVersion,
    );
    _updateTitleController = TextEditingController(
      text: widget.settings.updateTitle ?? '',
    );
    _updateMessageController = TextEditingController(
      text: widget.settings.updateMessage ?? '',
    );
    _iosMinVersionController = TextEditingController(
      text: widget.settings.iosMinVersion ?? '',
    );
    _androidMinVersionController = TextEditingController(
      text: widget.settings.androidMinVersion ?? '',
    );
    _reasonController = TextEditingController();
    _forceUpdate = widget.settings.forceUpdate;

    // Add listeners for reactive UI
    _appVersionController.addListener(() => setState(() {}));
    _minVersionController.addListener(() => setState(() {}));
    _updateTitleController.addListener(() => setState(() {}));
    _updateMessageController.addListener(() => setState(() {}));
    _iosMinVersionController.addListener(() => setState(() {}));
    _androidMinVersionController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _appVersionController.dispose();
    _minVersionController.dispose();
    _updateTitleController.dispose();
    _updateMessageController.dispose();
    _iosMinVersionController.dispose();
    _androidMinVersionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _appVersionController.text != widget.settings.appVersion ||
        _minVersionController.text != widget.settings.minimumRequiredVersion ||
        _updateTitleController.text != (widget.settings.updateTitle ?? '') ||
        _updateMessageController.text != (widget.settings.updateMessage ?? '') ||
        _iosMinVersionController.text != (widget.settings.iosMinVersion ?? '') ||
        _androidMinVersionController.text != (widget.settings.androidMinVersion ?? '') ||
        _forceUpdate != widget.settings.forceUpdate;
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for the changes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: Text(
          _forceUpdate
              ? 'WARNING: Force update is enabled. All users below version ${_minVersionController.text} will be required to update immediately.'
              : 'Are you sure you want to update these app version settings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSave();
            },
            style: _forceUpdate
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _performSave() {
    final authState = context.read<AuthBloc>().state;
    String currentUserId = 'unknown';
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    final updatedSettings = SystemSettingsEntity(
      dailyDeedTarget: widget.settings.dailyDeedTarget,
      penaltyPerDeed: widget.settings.penaltyPerDeed,
      gracePeriodHours: widget.settings.gracePeriodHours,
      trainingPeriodDays: widget.settings.trainingPeriodDays,
      autoDeactivationThreshold: widget.settings.autoDeactivationThreshold,
      warningThresholds: widget.settings.warningThresholds,
      organizationName: widget.settings.organizationName,
      receiptFooterText: widget.settings.receiptFooterText,
      emailApiKey: widget.settings.emailApiKey,
      emailDomain: widget.settings.emailDomain,
      emailSenderEmail: widget.settings.emailSenderEmail,
      emailSenderName: widget.settings.emailSenderName,
      fcmServerKey: widget.settings.fcmServerKey,
      appVersion: _appVersionController.text.trim(),
      minimumRequiredVersion: _minVersionController.text.trim(),
      forceUpdate: _forceUpdate,
      updateTitle: _updateTitleController.text.trim().isEmpty ? null : _updateTitleController.text.trim(),
      updateMessage: _updateMessageController.text.trim().isEmpty ? null : _updateMessageController.text.trim(),
      iosMinVersion: _iosMinVersionController.text.trim().isEmpty ? null : _iosMinVersionController.text.trim(),
      androidMinVersion: _androidMinVersionController.text.trim().isEmpty ? null : _androidMinVersionController.text.trim(),
    );

    context.read<AdminBloc>().add(UpdateSystemSettingsRequested(
          settings: updatedSettings,
          updatedBy: currentUserId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is SystemSettingsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App settings updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _reasonController.clear();
          // Reload settings
          context.read<AdminBloc>().add(const LoadSystemSettingsRequested());
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Version Control',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Current App Version
              TextFormField(
                controller: _appVersionController,
                decoration: const InputDecoration(
                  labelText: 'Current App Version',
                  hintText: 'e.g., 1.0.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                  helperText: 'Semantic versioning (major.minor.patch)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'App version is required';
                  }
                  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                    return 'Use format: X.Y.Z (e.g., 1.0.0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Minimum Required Version
              TextFormField(
                controller: _minVersionController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Required Version',
                  hintText: 'e.g., 1.0.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.system_update),
                  helperText: 'Users below this version will be prompted to update',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimum version is required';
                  }
                  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                    return 'Use format: X.Y.Z (e.g., 1.0.0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Force Update Toggle
              Card(
                color: _forceUpdate ? Colors.red[50] : Colors.green[50],
                child: SwitchListTile(
                  title: Text(
                    'Force Update',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _forceUpdate ? Colors.red[900] : Colors.green[900],
                    ),
                  ),
                  subtitle: Text(
                    _forceUpdate
                        ? 'Users MUST update to continue using the app'
                        : 'Users can skip the update and continue using the app',
                  ),
                  value: _forceUpdate,
                  onChanged: (value) => setState(() => _forceUpdate = value),
                  secondary: Icon(
                    _forceUpdate ? Icons.warning : Icons.check_circle,
                    color: _forceUpdate ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Platform Specific Versions
              Text(
                'Platform Specific Versions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional: Override minimum version for specific platforms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),

              // iOS Minimum Version
              TextFormField(
                controller: _iosMinVersionController,
                decoration: const InputDecoration(
                  labelText: 'iOS Minimum Version (Optional)',
                  hintText: 'e.g., 1.0.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_iphone),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                      return 'Use format: X.Y.Z (e.g., 1.0.0)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Android Minimum Version
              TextFormField(
                controller: _androidMinVersionController,
                decoration: const InputDecoration(
                  labelText: 'Android Minimum Version (Optional)',
                  hintText: 'e.g., 1.0.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                      return 'Use format: X.Y.Z (e.g., 1.0.0)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Update Prompt Customization
              Text(
                'Update Prompt Customization',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Update Title
              TextFormField(
                controller: _updateTitleController,
                decoration: const InputDecoration(
                  labelText: 'Update Dialog Title (Optional)',
                  hintText: 'e.g., Update Available',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Update Message
              TextFormField(
                controller: _updateMessageController,
                decoration: const InputDecoration(
                  labelText: 'Update Dialog Message (Optional)',
                  hintText: 'e.g., A new version is available with bug fixes and improvements.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 24),

              // Preview Card
              if (_updateTitleController.text.isNotEmpty || _updateMessageController.text.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.visibility, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Update Dialog Preview',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          _updateTitleController.text.isEmpty
                              ? 'Update Available'
                              : _updateTitleController.text,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _updateMessageController.text.isEmpty
                              ? 'A new version is available.'
                              : _updateMessageController.text,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!_forceUpdate)
                              TextButton(
                                onPressed: () {},
                                child: const Text('Later'),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Warning Card for Force Update
              if (_forceUpdate) ...[
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Force Update Enabled',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Users below version ${_minVersionController.text} will not be able to use the app until they update.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Reason field (only show if changes detected)
              if (_hasChanges()) ...[
                Text(
                  'Reason for Changes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Why are you making these changes?',
                    border: OutlineInputBorder(),
                    helperText: 'Required for audit trail',
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

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _forceUpdate ? Colors.red : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
