import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class WhatsAppSettingsTab extends StatefulWidget {
  final SystemSettingsEntity settings;

  const WhatsAppSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  State<WhatsAppSettingsTab> createState() => _WhatsAppSettingsTabState();
}

class _WhatsAppSettingsTabState extends State<WhatsAppSettingsTab> {
  late TextEditingController _phoneNumberIdController;
  late TextEditingController _businessAccountIdController;
  late TextEditingController _accessTokenController;
  late TextEditingController _reasonController;

  final _formKey = GlobalKey<FormState>();
  bool _whatsappEnabled = false;
  String _apiVersion = 'v18.0';
  bool _obscureAccessToken = true;
  bool _obscurePhoneNumberId = true;
  bool _obscureBusinessAccountId = true;

  final List<String> _apiVersionOptions = ['v17.0', 'v18.0', 'v19.0', 'v20.0'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _whatsappEnabled = widget.settings.whatsappEnabled;
    _apiVersion = widget.settings.whatsappApiVersion ?? 'v18.0';

    _phoneNumberIdController = TextEditingController(
      text: widget.settings.whatsappPhoneNumberId ?? '',
    );
    _businessAccountIdController = TextEditingController(
      text: widget.settings.whatsappBusinessAccountId ?? '',
    );
    _accessTokenController = TextEditingController(
      text: widget.settings.whatsappAccessToken ?? '',
    );
    _reasonController = TextEditingController();

    _phoneNumberIdController.addListener(() => setState(() {}));
    _businessAccountIdController.addListener(() => setState(() {}));
    _accessTokenController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneNumberIdController.dispose();
    _businessAccountIdController.dispose();
    _accessTokenController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _whatsappEnabled != widget.settings.whatsappEnabled ||
        _phoneNumberIdController.text != (widget.settings.whatsappPhoneNumberId ?? '') ||
        _businessAccountIdController.text != (widget.settings.whatsappBusinessAccountId ?? '') ||
        _accessTokenController.text != (widget.settings.whatsappAccessToken ?? '') ||
        _apiVersion != (widget.settings.whatsappApiVersion ?? 'v18.0');
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
          'Are you sure you want to update WhatsApp settings? API credentials will be stored securely.',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
            ),
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
      whatsappEnabled: _whatsappEnabled,
      whatsappPhoneNumberId: _phoneNumberIdController.text.trim().isEmpty
          ? null
          : _phoneNumberIdController.text.trim(),
      whatsappBusinessAccountId: _businessAccountIdController.text.trim().isEmpty
          ? null
          : _businessAccountIdController.text.trim(),
      whatsappAccessToken: _accessTokenController.text.trim().isEmpty
          ? null
          : _accessTokenController.text.trim(),
      whatsappApiVersion: _apiVersion,
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

  Future<void> _testWhatsAppConnection() async {
    if (_phoneNumberIdController.text.isEmpty || _accessTokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Phone Number ID and Access Token first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Flag to track if loading dialog has been dismissed
    bool loadingDialogDismissed = false;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                ),
                SizedBox(height: 16),
                Text('Testing WhatsApp connection...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Helper function to safely dismiss loading dialog
    void dismissLoadingDialog() {
      if (!loadingDialogDismissed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingDialogDismissed = true;
      }
    }

    try {
      final phoneNumberId = _phoneNumberIdController.text.trim();
      final accessToken = _accessTokenController.text.trim();
      final apiVersion = _apiVersion;

      // Test WhatsApp API by fetching phone number details
      final url = 'https://graph.facebook.com/$apiVersion/$phoneNumberId';

      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => true, // Accept all status codes
        ),
      );

      // Close loading dialog
      dismissLoadingDialog();

      if (response.statusCode == 200) {
        // Success - parse response data safely
        String phoneNumber = 'Unknown';
        String verifiedName = 'N/A';

        try {
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            phoneNumber = data['display_phone_number']?.toString() ?? 'Unknown';
            verifiedName = data['verified_name']?.toString() ?? 'N/A';
          }
        } catch (e) {
          // If parsing fails, use defaults
          phoneNumber = 'Unknown';
          verifiedName = 'N/A';
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF25D366)),
                  SizedBox(width: 8),
                  Text('Connection Successful'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WhatsApp API credentials are valid!'),
                  const SizedBox(height: 16),
                  Text(
                    'Phone Number: $phoneNumber',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verified Name: $verifiedName',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - invalid token
        if (mounted) {
          _showErrorDialog(
            'Invalid Access Token',
            'The access token is invalid or expired. Please check your credentials.',
          );
        }
      } else if (response.statusCode == 404) {
        // Phone Number ID not found
        if (mounted) {
          _showErrorDialog(
            'Invalid Phone Number ID',
            'The Phone Number ID was not found. Please verify it in Meta Business Suite.',
          );
        }
      } else {
        // Other error - parse error message safely
        String errorMessage = 'HTTP ${response.statusCode}';

        try {
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('error') && data['error'] is Map) {
              final error = data['error'] as Map<String, dynamic>;
              errorMessage = error['message']?.toString() ?? errorMessage;
            }
          }
        } catch (e) {
          // If parsing fails, use default error message
        }

        if (mounted) {
          _showErrorDialog(
            'Connection Failed',
            errorMessage,
          );
        }
      }
    } on DioException catch (e) {
      // Close loading dialog if still open
      dismissLoadingDialog();

      if (mounted) {
        _showErrorDialog(
          'Connection Error',
          'Failed to test connection: ${e.message ?? e.toString()}',
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      dismissLoadingDialog();

      if (mounted) {
        _showErrorDialog(
          'Connection Error',
          'Failed to test connection: ${e.toString()}',
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Connection Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is SystemSettingsUpdated) {
          _reasonController.clear();
          context.read<AdminBloc>().add(const LoadSystemSettingsRequested());

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF25D366)),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: const Text('WhatsApp settings have been saved successfully!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is AdminError) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error'),
                ],
              ),
              content: Text('Failed to save WhatsApp settings:\n\n${state.message}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WhatsApp Business Cloud API',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Configure WhatsApp Business Cloud API to send notifications via WhatsApp.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // Enable WhatsApp Toggle
              Card(
                color: _whatsappEnabled ? const Color(0xFF25D366).withValues(alpha: 0.1) : null,
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.chat,
                        color: Color(0xFF25D366),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Enable WhatsApp Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _whatsappEnabled
                        ? 'WhatsApp notifications are enabled'
                        : 'WhatsApp notifications are disabled',
                  ),
                  value: _whatsappEnabled,
                  activeTrackColor: const Color(0xFF25D366).withValues(alpha: 0.5),
                  activeThumbColor: const Color(0xFF25D366),
                  onChanged: (value) => setState(() => _whatsappEnabled = value),
                ),
              ),
              SizedBox(height: 24),

              // API Credentials Section
              Row(
                children: [
                  const Icon(Icons.vpn_key, color: Color(0xFF25D366)),
                  SizedBox(width: 8),
                  Text(
                    'API Credentials',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Phone Number ID
              TextFormField(
                controller: _phoneNumberIdController,
                decoration: InputDecoration(
                  labelText: 'Phone Number ID',
                  hintText: 'Enter your WhatsApp Phone Number ID',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePhoneNumberId ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePhoneNumberId = !_obscurePhoneNumberId),
                  ),
                  helperText: 'Found in Meta Business Suite > WhatsApp > Phone Numbers',
                ),
                obscureText: _obscurePhoneNumberId,
                enabled: _whatsappEnabled,
              ),
              const SizedBox(height: 16),

              // Business Account ID
              TextFormField(
                controller: _businessAccountIdController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp Business Account ID',
                  hintText: 'Enter your WABA ID',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.business),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureBusinessAccountId ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureBusinessAccountId = !_obscureBusinessAccountId),
                  ),
                  helperText: 'Found in Meta Business Suite > WhatsApp > Account',
                ),
                obscureText: _obscureBusinessAccountId,
                enabled: _whatsappEnabled,
              ),
              const SizedBox(height: 16),

              // Access Token
              TextFormField(
                controller: _accessTokenController,
                decoration: InputDecoration(
                  labelText: 'Permanent Access Token',
                  hintText: 'Enter your permanent access token',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureAccessToken ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureAccessToken = !_obscureAccessToken),
                  ),
                  helperText: 'Create a System User in Business Settings to generate a permanent token',
                ),
                obscureText: _obscureAccessToken,
                enabled: _whatsappEnabled,
                maxLines: 1,
              ),
              const SizedBox(height: 16),

              // API Version Dropdown
              DropdownButtonFormField<String>(
                initialValue: _apiVersion,
                decoration: const InputDecoration(
                  labelText: 'API Version',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                items: _apiVersionOptions.map((version) {
                  return DropdownMenuItem(
                    value: version,
                    child: Text(version),
                  );
                }).toList(),
                onChanged: _whatsappEnabled
                    ? (value) {
                        if (value != null) {
                          setState(() => _apiVersion = value);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 16),

              // Test Connection Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _whatsappEnabled ? _testWhatsAppConnection : null,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Card about Templates
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            'Message Templates Required',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'WhatsApp Business API requires pre-approved message templates. Create templates in Meta Business Suite and map them in the Notification Templates section.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[800],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security Notice
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security Notice',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Access tokens are stored securely and never exposed in logs. Use a System User with limited permissions for production.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green[800],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

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
                    label: const Text('Save WhatsApp Settings'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFF25D366),
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
