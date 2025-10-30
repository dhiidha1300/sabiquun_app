import 'package:flutter/material.dart';
import '../../domain/entities/system_settings_entity.dart';

class PaymentSettingsTab extends StatelessWidget {
  final SystemSettingsEntity settings;

  const PaymentSettingsTab({
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
            'Payment Configuration',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'Organization Name',
            settings.organizationName,
            Icons.business,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'Receipt Footer Text',
            settings.receiptFooterText,
            Icons.receipt,
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
                    'Payment settings editing coming soon',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organization name and receipt text can be edited in the database settings table',
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
