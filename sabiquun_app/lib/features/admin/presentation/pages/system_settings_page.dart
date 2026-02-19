import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/general_settings_tab.dart';
import '../widgets/payment_settings_tab.dart';
import '../widgets/notification_settings_tab.dart';
import '../widgets/app_settings_tab.dart';
import '../widgets/whatsapp_settings_tab.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    context.read<AdminBloc>().add(const LoadSystemSettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        title: const Text('System Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.settings)),
            Tab(text: 'Payment', icon: Icon(Icons.payment)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
            Tab(text: 'App', icon: Icon(Icons.phone_android)),
            Tab(text: 'WhatsApp', icon: Icon(Icons.chat, color: Color(0xFF25D366))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadSettings,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SystemSettingsLoaded) {
            final settings = state.settings;

            return TabBarView(
              controller: _tabController,
              children: [
                GeneralSettingsTab(settings: settings),
                PaymentSettingsTab(settings: settings),
                NotificationSettingsTab(settings: settings),
                AppSettingsTab(settings: settings),
                WhatsAppSettingsTab(settings: settings),
              ],
            );
          }

          return const Center(
            child: Text('No settings loaded'),
          );
        },
      ),
    );
  }
}
