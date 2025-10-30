import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class GeneralSettingsTab extends StatefulWidget {
  final SystemSettingsEntity settings;

  const GeneralSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  late TextEditingController _dailyDeedTargetController;
  late TextEditingController _penaltyPerDeedController;
  late TextEditingController _gracePeriodController;
  late TextEditingController _trainingPeriodController;
  late TextEditingController _autoDeactivationController;
  late TextEditingController _warningThreshold1Controller;
  late TextEditingController _warningThreshold2Controller;
  late TextEditingController _reasonController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _dailyDeedTargetController = TextEditingController(
      text: widget.settings.dailyDeedTarget.toString(),
    );
    _penaltyPerDeedController = TextEditingController(
      text: widget.settings.penaltyPerDeed.toString(),
    );
    _gracePeriodController = TextEditingController(
      text: widget.settings.gracePeriodHours.toString(),
    );
    _trainingPeriodController = TextEditingController(
      text: widget.settings.trainingPeriodDays.toString(),
    );
    _autoDeactivationController = TextEditingController(
      text: widget.settings.autoDeactivationThreshold.toString(),
    );
    _warningThreshold1Controller = TextEditingController(
      text: widget.settings.warningThresholds.isNotEmpty
          ? widget.settings.warningThresholds[0].toString()
          : '200000',
    );
    _warningThreshold2Controller = TextEditingController(
      text: widget.settings.warningThresholds.length > 1
          ? widget.settings.warningThresholds[1].toString()
          : '350000',
    );
    _reasonController = TextEditingController();

    // Add listeners for reactive UI
    _dailyDeedTargetController.addListener(() => setState(() {}));
    _penaltyPerDeedController.addListener(() => setState(() {}));
    _gracePeriodController.addListener(() => setState(() {}));
    _trainingPeriodController.addListener(() => setState(() {}));
    _autoDeactivationController.addListener(() => setState(() {}));
    _warningThreshold1Controller.addListener(() => setState(() {}));
    _warningThreshold2Controller.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dailyDeedTargetController.dispose();
    _penaltyPerDeedController.dispose();
    _gracePeriodController.dispose();
    _trainingPeriodController.dispose();
    _autoDeactivationController.dispose();
    _warningThreshold1Controller.dispose();
    _warningThreshold2Controller.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _dailyDeedTargetController.text != widget.settings.dailyDeedTarget.toString() ||
        _penaltyPerDeedController.text != widget.settings.penaltyPerDeed.toString() ||
        _gracePeriodController.text != widget.settings.gracePeriodHours.toString() ||
        _trainingPeriodController.text != widget.settings.trainingPeriodDays.toString() ||
        _autoDeactivationController.text != widget.settings.autoDeactivationThreshold.toString() ||
        _warningThreshold1Controller.text !=
            (widget.settings.warningThresholds.isNotEmpty
                ? widget.settings.warningThresholds[0].toString()
                : '200000') ||
        _warningThreshold2Controller.text !=
            (widget.settings.warningThresholds.length > 1
                ? widget.settings.warningThresholds[1].toString()
                : '350000');
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
          'Are you sure you want to update these system settings? This will affect all users.',
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
      dailyDeedTarget: int.parse(_dailyDeedTargetController.text),
      penaltyPerDeed: double.parse(_penaltyPerDeedController.text),
      gracePeriodHours: int.parse(_gracePeriodController.text),
      trainingPeriodDays: int.parse(_trainingPeriodController.text),
      autoDeactivationThreshold: double.parse(_autoDeactivationController.text),
      warningThresholds: [
        double.parse(_warningThreshold1Controller.text),
        double.parse(_warningThreshold2Controller.text),
      ],
      organizationName: widget.settings.organizationName,
      receiptFooterText: widget.settings.receiptFooterText,
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
              content: Text('Settings updated successfully'),
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
                'Deed & Penalty Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Daily Deed Target
              TextFormField(
                controller: _dailyDeedTargetController,
                decoration: const InputDecoration(
                  labelText: 'Daily Deed Target',
                  hintText: 'Number of deeds required per day',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Penalty Per Deed
              TextFormField(
                controller: _penaltyPerDeedController,
                decoration: const InputDecoration(
                  labelText: 'Penalty Per Deed (Shillings)',
                  hintText: 'Amount charged for each missed deed',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Must be 0 or greater';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grace Period
              TextFormField(
                controller: _gracePeriodController,
                decoration: const InputDecoration(
                  labelText: 'Grace Period (Hours)',
                  hintText: 'Hours after midnight before penalties apply',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0 || num > 24) {
                    return 'Must be between 0 and 24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Training Period
              TextFormField(
                controller: _trainingPeriodController,
                decoration: const InputDecoration(
                  labelText: 'Training Period (Days)',
                  hintText: 'Days before penalties apply to new users',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Must be 0 or greater';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Text(
                'Auto-Deactivation & Warnings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Auto-deactivation Threshold
              TextFormField(
                controller: _autoDeactivationController,
                decoration: const InputDecoration(
                  labelText: 'Auto-Deactivation Threshold (Shillings)',
                  hintText: 'Balance at which users are auto-deactivated',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Must be 0 or greater';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Warning Threshold 1
              TextFormField(
                controller: _warningThreshold1Controller,
                decoration: const InputDecoration(
                  labelText: 'First Warning Threshold (Shillings)',
                  hintText: 'Balance for first warning',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Must be 0 or greater';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Warning Threshold 2
              TextFormField(
                controller: _warningThreshold2Controller,
                decoration: const InputDecoration(
                  labelText: 'Second Warning Threshold (Shillings)',
                  hintText: 'Balance for second warning',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Must be 0 or greater';
                  }
                  final threshold1 = double.tryParse(_warningThreshold1Controller.text);
                  if (threshold1 != null && num <= threshold1) {
                    return 'Must be greater than first warning';
                  }
                  return null;
                },
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
