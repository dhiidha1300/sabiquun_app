import 'package:flutter/material.dart';
import '../../domain/entities/system_settings_entity.dart';

class NotificationSettingsTab extends StatelessWidget {
  final SystemSettingsEntity settings;

  const NotificationSettingsTab({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const SizedBox(height: 16),

          Text(
            'Email Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'Email API Key',
            settings.emailApiKey != null ? '••••••••' : 'Not configured',
            Icons.key,
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            'Email Domain',
            settings.emailDomain ?? 'Not configured',
            Icons.domain,
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            'Sender Email',
            settings.emailSenderEmail ?? 'Not configured',
            Icons.email,
          ),
          const SizedBox(height: 24),

          Text(
            'Push Notification Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'FCM Server Key',
            settings.fcmServerKey != null ? '••••••••' : 'Not configured',
            Icons.vpn_key,
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    'Notification settings editing coming soon',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email and push notification settings can be edited in the database settings table',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
