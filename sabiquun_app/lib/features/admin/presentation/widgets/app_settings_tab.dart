import 'package:flutter/material.dart';
import '../../domain/entities/system_settings_entity.dart';

class AppSettingsTab extends StatelessWidget {
  final SystemSettingsEntity settings;

  const AppSettingsTab({
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
            'App Version Control',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'Current App Version',
            settings.appVersion,
            Icons.info,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'Minimum Required Version',
            settings.minimumRequiredVersion,
            Icons.system_update,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'Force Update',
            settings.forceUpdate ? 'Enabled' : 'Disabled',
            settings.forceUpdate ? Icons.warning : Icons.check_circle,
            settings.forceUpdate ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 24),

          if (settings.iosMinVersion != null || settings.androidMinVersion != null) ...[
            Text(
              'Platform Specific',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (settings.iosMinVersion != null)
              _buildInfoCard(
                context,
                'iOS Minimum Version',
                settings.iosMinVersion!,
                Icons.phone_iphone,
                Colors.grey,
              ),
            if (settings.androidMinVersion != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                'Android Minimum Version',
                settings.androidMinVersion!,
                Icons.phone_android,
                Colors.grey,
              ),
            ],
            const SizedBox(height: 24),
          ],

          if (settings.updateTitle != null || settings.updateMessage != null) ...[
            Text(
              'Update Prompt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (settings.updateTitle != null) ...[
                      Text(
                        'Title:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.updateTitle!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                    if (settings.updateMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Message:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(settings.updateMessage!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    'App version settings editing coming soon',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version control settings can be edited in the database settings table',
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
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
