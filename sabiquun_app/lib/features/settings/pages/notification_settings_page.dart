import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Settings state
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _reportRemindersEnabled = true;
  bool _paymentRemindersEnabled = true;
  bool _excuseUpdatesEnabled = true;
  bool _systemAnnouncementsEnabled = true;
  String _notificationSound = 'default';
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);
  bool _quietHoursEnabled = false;
  bool _isLoading = false;

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save to backend/database
      // For now, just simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // General Notifications
            _buildSectionHeader('General'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive in-app notifications'),
                    value: _pushNotificationsEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _pushNotificationsEnabled = value;
                            });
                          },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive updates via email'),
                    value: _emailNotificationsEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _emailNotificationsEnabled = value;
                            });
                          },
                  ),
                ],
              ),
            ),

            // Notification Types
            _buildSectionHeader('Notification Types'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Report Reminders'),
                    subtitle: const Text('Daily reminders to submit deeds'),
                    value: _reportRemindersEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _reportRemindersEnabled = value;
                            });
                          },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Payment Reminders'),
                    subtitle: const Text('Reminders for pending payments'),
                    value: _paymentRemindersEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _paymentRemindersEnabled = value;
                            });
                          },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Excuse Updates'),
                    subtitle: const Text('Status updates for excuse requests'),
                    value: _excuseUpdatesEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _excuseUpdatesEnabled = value;
                            });
                          },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('System Announcements'),
                    subtitle: const Text('Important app updates and news'),
                    value: _systemAnnouncementsEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _systemAnnouncementsEnabled = value;
                            });
                          },
                  ),
                ],
              ),
            ),

            // Sound Settings
            _buildSectionHeader('Sound'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: const Text('Notification Sound'),
                subtitle: Text(_notificationSound == 'default'
                    ? 'Default'
                    : _notificationSound == 'silent'
                        ? 'Silent'
                        : 'Custom'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isLoading
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Select Sound'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<String>(
                                    title: const Text('Default'),
                                    value: 'default',
                                    groupValue: _notificationSound,
                                    activeColor: const Color(0xFF2E7D32),
                                    onChanged: (value) {
                                      setState(() {
                                        _notificationSound = value!;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('Silent'),
                                    value: 'silent',
                                    groupValue: _notificationSound,
                                    activeColor: const Color(0xFF2E7D32),
                                    onChanged: (value) {
                                      setState(() {
                                        _notificationSound = value!;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
              ),
            ),

            // Quiet Hours
            _buildSectionHeader('Quiet Hours'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Quiet Hours'),
                    subtitle: const Text('Silence notifications during specific times'),
                    value: _quietHoursEnabled,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _quietHoursEnabled = value;
                            });
                          },
                  ),
                  if (_quietHoursEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _selectTime(context, true),
                        child: Text(
                          _formatTime(_quietHoursStart),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _selectTime(context, false),
                        child: Text(
                          _formatTime(_quietHoursEnd),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
