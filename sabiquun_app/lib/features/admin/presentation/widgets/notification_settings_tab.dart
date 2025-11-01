import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class NotificationSettingsTab extends StatefulWidget {
  final SystemSettingsEntity settings;

  const NotificationSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  State<NotificationSettingsTab> createState() => _NotificationSettingsTabState();
}

class _NotificationSettingsTabState extends State<NotificationSettingsTab> {
  late TextEditingController _emailApiKeyController;
  late TextEditingController _emailDomainController;
  late TextEditingController _emailSenderEmailController;
  late TextEditingController _emailSenderNameController;
  late TextEditingController _fcmServerKeyController;
  late TextEditingController _reasonController;

  final _formKey = GlobalKey<FormState>();
  bool _obscureEmailApiKey = true;
  bool _obscureFcmKey = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _emailApiKeyController = TextEditingController(
      text: widget.settings.emailApiKey ?? '',
    );
    _emailDomainController = TextEditingController(
      text: widget.settings.emailDomain ?? '',
    );
    _emailSenderEmailController = TextEditingController(
      text: widget.settings.emailSenderEmail ?? '',
    );
    _emailSenderNameController = TextEditingController(
      text: widget.settings.emailSenderName ?? '',
    );
    _fcmServerKeyController = TextEditingController(
      text: widget.settings.fcmServerKey ?? '',
    );
    _reasonController = TextEditingController();

    // Add listeners for reactive UI
    _emailApiKeyController.addListener(() => setState(() {}));
    _emailDomainController.addListener(() => setState(() {}));
    _emailSenderEmailController.addListener(() => setState(() {}));
    _emailSenderNameController.addListener(() => setState(() {}));
    _fcmServerKeyController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailApiKeyController.dispose();
    _emailDomainController.dispose();
    _emailSenderEmailController.dispose();
    _emailSenderNameController.dispose();
    _fcmServerKeyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _emailApiKeyController.text != (widget.settings.emailApiKey ?? '') ||
        _emailDomainController.text != (widget.settings.emailDomain ?? '') ||
        _emailSenderEmailController.text != (widget.settings.emailSenderEmail ?? '') ||
        _emailSenderNameController.text != (widget.settings.emailSenderName ?? '') ||
        _fcmServerKeyController.text != (widget.settings.fcmServerKey ?? '');
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
        content: const Text(
          'Are you sure you want to update these notification settings? API keys will be stored securely.',
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
      emailApiKey: _emailApiKeyController.text.trim().isEmpty ? null : _emailApiKeyController.text.trim(),
      emailDomain: _emailDomainController.text.trim().isEmpty ? null : _emailDomainController.text.trim(),
      emailSenderEmail: _emailSenderEmailController.text.trim().isEmpty ? null : _emailSenderEmailController.text.trim(),
      emailSenderName: _emailSenderNameController.text.trim().isEmpty ? null : _emailSenderNameController.text.trim(),
      fcmServerKey: _fcmServerKeyController.text.trim().isEmpty ? null : _fcmServerKeyController.text.trim(),
      appVersion: widget.settings.appVersion,
      minimumRequiredVersion: widget.settings.minimumRequiredVersion,
      forceUpdate: widget.settings.forceUpdate,
      updateTitle: widget.settings.updateTitle,
      updateMessage: widget.settings.updateMessage,
      iosMinVersion: widget.settings.iosMinVersion,
      androidMinVersion: widget.settings.androidMinVersion,
    );

    context.read<AdminBloc>().add(UpdateSystemSettingsRequested(
          settings: updatedSettings,
          updatedBy: currentUserId,
        ));
  }

  void _testEmailConfiguration() {
    // TODO: Implement email test functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email test functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _testPushNotification() {
    // TODO: Implement push notification test functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Push notification test functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is SystemSettingsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification settings updated successfully'),
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
                'Notification Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Email Settings Section
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Email Settings (Mailgun)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email API Key
              TextFormField(
                controller: _emailApiKeyController,
                decoration: InputDecoration(
                  labelText: 'Mailgun API Key',
                  hintText: 'Enter your Mailgun API key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureEmailApiKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureEmailApiKey = !_obscureEmailApiKey),
                  ),
                  helperText: 'Stored securely, never exposed in logs',
                ),
                obscureText: _obscureEmailApiKey,
              ),
              const SizedBox(height: 16),

              // Email Domain
              TextFormField(
                controller: _emailDomainController,
                decoration: const InputDecoration(
                  labelText: 'Email Domain',
                  hintText: 'e.g., mg.yourdomain.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.domain),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('.')) {
                    return 'Enter a valid domain';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sender Email
              TextFormField(
                controller: _emailSenderEmailController,
                decoration: const InputDecoration(
                  labelText: 'Sender Email',
                  hintText: 'e.g., noreply@yourdomain.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sender Name
              TextFormField(
                controller: _emailSenderNameController,
                decoration: const InputDecoration(
                  labelText: 'Sender Name',
                  hintText: 'e.g., Good Deeds App',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 8),

              // Test Email Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testEmailConfiguration,
                  icon: const Icon(Icons.send),
                  label: const Text('Test Email Configuration'),
                ),
              ),
              const SizedBox(height: 32),

              // Push Notification Settings Section
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Push Notification Settings (FCM)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // FCM Server Key
              TextFormField(
                controller: _fcmServerKeyController,
                decoration: InputDecoration(
                  labelText: 'Firebase Cloud Messaging Server Key',
                  hintText: 'Enter your FCM server key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureFcmKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureFcmKey = !_obscureFcmKey),
                  ),
                  helperText: 'Stored securely, never exposed in logs',
                ),
                obscureText: _obscureFcmKey,
                maxLines: 1,
              ),
              const SizedBox(height: 8),

              // Test Push Notification Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testPushNotification,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Test Push Notification'),
                ),
              ),
              const SizedBox(height: 24),

              // Security Notice Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security Notice',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'API keys are stored securely and never exposed in application logs or error messages.',
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
