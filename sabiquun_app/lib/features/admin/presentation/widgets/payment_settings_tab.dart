import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class PaymentSettingsTab extends StatefulWidget {
  final SystemSettingsEntity settings;

  const PaymentSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  State<PaymentSettingsTab> createState() => _PaymentSettingsTabState();
}

class _PaymentSettingsTabState extends State<PaymentSettingsTab> {
  late TextEditingController _organizationNameController;
  late TextEditingController _receiptFooterController;
  late TextEditingController _reasonController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _organizationNameController = TextEditingController(
      text: widget.settings.organizationName,
    );
    _receiptFooterController = TextEditingController(
      text: widget.settings.receiptFooterText,
    );
    _reasonController = TextEditingController();

    // Add listeners for reactive UI
    _organizationNameController.addListener(() => setState(() {}));
    _receiptFooterController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _receiptFooterController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _organizationNameController.text != widget.settings.organizationName ||
        _receiptFooterController.text != widget.settings.receiptFooterText;
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
          'Are you sure you want to update these payment settings?',
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
      organizationName: _organizationNameController.text.trim(),
      receiptFooterText: _receiptFooterController.text.trim(),
      emailApiKey: widget.settings.emailApiKey,
      emailDomain: widget.settings.emailDomain,
      emailSenderEmail: widget.settings.emailSenderEmail,
      emailSenderName: widget.settings.emailSenderName,
      fcmServerKey: widget.settings.fcmServerKey,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is SystemSettingsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment settings updated successfully'),
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
                'Payment Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Organization Name
              TextFormField(
                controller: _organizationNameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name',
                  hintText: 'Name of your organization',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Organization name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Receipt Footer Text
              TextFormField(
                controller: _receiptFooterController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Footer Text',
                  hintText: 'Text to display at the bottom of receipts',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                  helperText: 'This text will appear on all payment receipts',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Receipt footer text is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Receipt Preview Card
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
                            'Receipt Preview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _organizationNameController.text.trim().isEmpty
                              ? 'Organization Name'
                              : _organizationNameController.text,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Receipt #: 001234'),
                      const Text('Date: 2025-11-01'),
                      const Text('Amount: 50,000 Shillings'),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        _receiptFooterController.text.trim().isEmpty
                            ? 'Receipt footer text will appear here'
                            : _receiptFooterController.text,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
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
