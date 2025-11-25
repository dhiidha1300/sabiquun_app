import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Beautiful Sidebar Drawer with smooth animations
class AdminMenuGrid extends StatefulWidget {
  const AdminMenuGrid({Key? key}) : super(key: key);

  @override
  State<AdminMenuGrid> createState() => AdminMenuGridState();

  /// Get the state to allow external toggling
  static AdminMenuGridState? of(BuildContext context) {
    return context.findAncestorStateOfType<AdminMenuGridState>();
  }
}

class AdminMenuGridState extends State<AdminMenuGrid>
    with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void closeDrawer() {
    if (_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return nothing if drawer is closed (so it doesn't interfere)
    if (!_isDrawerOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // Overlay (darkens background when drawer is open)
        GestureDetector(
          onTap: closeDrawer,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),

        // Sliding Drawer
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 280,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceVariant,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drawer Header
                    _buildDrawerHeader(),

                    // Scrollable Menu Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMenuCategory(
                              'User Management & Insights',
                              Icons.people_outline,
                              _userManagementActions,
                            ),
                            const SizedBox(height: 20),
                            _buildMenuCategory(
                              'Personal Actions',
                              Icons.person_outline,
                              _personalActions,
                            ),
                            const SizedBox(height: 20),
                            _buildMenuCategory(
                              'System Management',
                              Icons.settings_outlined,
                              _systemManagementActions,
                            ),
                            const SizedBox(height: 20),
                            _buildMenuCategory(
                              'Content & Communication',
                              Icons.campaign_outlined,
                              _contentActions,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Drawer Footer
                    _buildDrawerFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All Features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: closeDrawer,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Sabiquun v1.0',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(
    String title,
    IconData icon,
    List<_MenuItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Menu items list
        ...items.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(item.route);
            closeDrawer();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceVariant.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withValues(alpha: 0.25),
                        item.color.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 14),

                // Title
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // User Management & Insights Menu Items
  List<_MenuItem> get _userManagementActions => [
        _MenuItem(
          icon: Icons.people,
          title: 'User Management',
          route: '/admin/user-management',
          color: Colors.blue,
        ),
        _MenuItem(
          icon: Icons.leaderboard,
          title: 'Leaderboard',
          route: '/leaderboard',
          color: Colors.amber,
        ),
        _MenuItem(
          icon: Icons.warning_amber_rounded,
          title: 'Users at Risk',
          route: '/users-at-risk',
          color: Colors.red,
        ),
        _MenuItem(
          icon: Icons.assessment_outlined,
          title: 'All User Reports',
          route: '/user-reports',
          color: Colors.indigo,
        ),
        _MenuItem(
          icon: Icons.analytics_outlined,
          title: 'Analytics Dashboard',
          route: '/admin/analytics',
          color: Colors.purple,
        ),
      ];

  // Personal Actions Menu Items
  List<_MenuItem> get _personalActions => [
        _MenuItem(
          icon: Icons.today,
          title: 'Today\'s Deeds',
          route: '/today-deeds',
          color: Colors.blue,
        ),
        _MenuItem(
          icon: Icons.assignment_outlined,
          title: 'My Reports',
          route: '/my-reports',
          color: Colors.teal,
        ),
        _MenuItem(
          icon: Icons.account_balance_wallet,
          title: 'Penalty History',
          route: '/penalty-history',
          color: Colors.orange,
        ),
        _MenuItem(
          icon: Icons.payment_outlined,
          title: 'Submit Payment',
          route: '/submit-payment',
          color: Colors.green,
        ),
        _MenuItem(
          icon: Icons.receipt_long,
          title: 'Payment History',
          route: '/payment-history',
          color: Colors.indigo,
        ),
        _MenuItem(
          icon: Icons.bar_chart_outlined,
          title: 'My Analytics',
          route: '/analytics',
          color: Colors.purple,
        ),
      ];

  // System Management Menu Items
  List<_MenuItem> get _systemManagementActions => [
        _MenuItem(
          icon: Icons.assignment_turned_in,
          title: 'Deed Management',
          route: '/admin/deed-management',
          color: Colors.teal,
        ),
        _MenuItem(
          icon: Icons.event_busy,
          title: 'Rest Days',
          route: '/admin/rest-days',
          color: Colors.amber,
        ),
        _MenuItem(
          icon: Icons.settings,
          title: 'System Settings',
          route: '/admin/system-settings',
          color: Colors.purple,
        ),
        _MenuItem(
          icon: Icons.notifications_active,
          title: 'Notifications',
          route: '/admin/notification-templates',
          color: Colors.deepOrange,
        ),
        _MenuItem(
          icon: Icons.history,
          title: 'Audit Logs',
          route: '/admin/audit-logs',
          color: Colors.blueGrey,
        ),
      ];

  // Content & Communication Menu Items
  List<_MenuItem> get _contentActions => [
        _MenuItem(
          icon: Icons.description,
          title: 'Reports',
          route: '/admin/reports',
          color: Colors.teal,
        ),
        _MenuItem(
          icon: Icons.send_outlined,
          title: 'Send Notification',
          route: '/admin/manual-notification',
          color: Colors.orange,
        ),
        _MenuItem(
          icon: Icons.campaign,
          title: 'Announcements',
          route: '/admin/announcements',
          color: Colors.indigo,
        ),
        _MenuItem(
          icon: Icons.article_outlined,
          title: 'App Content',
          route: '/admin/app-content',
          color: Colors.cyan,
        ),
      ];
}

/// Menu Item Model
class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });
}
