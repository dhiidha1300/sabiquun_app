import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Modern Interactive Sidebar Menu with hover effects and animations
class AdminMenuGrid extends StatefulWidget {
  const AdminMenuGrid({Key? key}) : super(key: key);

  @override
  State<AdminMenuGrid> createState() => AdminMenuGridState();

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
  String? _hoveredRoute;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
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
        curve: Curves.easeInOut,
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
    if (!_isDrawerOpen) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [
          // Dark overlay
          GestureDetector(
            onTap: closeDrawer,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Sidebar
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                elevation: 24,
                shadowColor: Colors.black.withValues(alpha: 0.6),
                child: Container(
                  width: 300,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.surface.withValues(alpha: 0.98),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildModernHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: Column(
                              children: [
                                _buildSection('User Management', Icons.people_rounded, _userManagementActions),
                                _buildSection('Personal', Icons.person_rounded, _personalActions),
                                _buildSection('System', Icons.settings_rounded, _systemManagementActions),
                                _buildSection('Content', Icons.campaign_rounded, _contentActions),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/icons/adaptive-icon.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sabiquun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: closeDrawer,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildInteractiveItem(item)),
      ],
    );
  }

  Widget _buildInteractiveItem(_MenuItem item) {
    final isHovered = _hoveredRoute == item.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredRoute = item.route),
        onExit: (_) => setState(() => _hoveredRoute = null),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              closeDrawer();
              context.push(item.route);
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                gradient: isHovered
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          item.color.withValues(alpha: 0.15),
                          item.color.withValues(alpha: 0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered
                      ? item.color.withValues(alpha: 0.4)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.color.withValues(alpha: isHovered ? 0.3 : 0.2),
                          item.color.withValues(alpha: isHovered ? 0.2 : 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: item.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                        color: isHovered ? item.color : AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isHovered ? 0 : -0.125,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isHovered ? item.color : AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Menu Items
  List<_MenuItem> get _userManagementActions => [
        _MenuItem(icon: Icons.people_rounded, title: 'User Management', route: '/admin/user-management', color: Colors.blue),
        _MenuItem(icon: Icons.leaderboard_rounded, title: 'Leaderboard', route: '/leaderboard', color: Colors.amber),
        _MenuItem(icon: Icons.warning_amber_rounded, title: 'Users at Risk', route: '/users-at-risk', color: Colors.red),
        _MenuItem(icon: Icons.assessment_rounded, title: 'All User Reports', route: '/user-reports', color: Colors.indigo),
        _MenuItem(icon: Icons.analytics_rounded, title: 'Analytics Dashboard', route: '/admin/analytics', color: Colors.purple),
      ];

  List<_MenuItem> get _personalActions => [
        _MenuItem(icon: Icons.account_circle_rounded, title: 'Profile', route: '/profile', color: Colors.blueGrey),
        _MenuItem(icon: Icons.today_rounded, title: 'Today\'s Deeds', route: '/today-deeds', color: Colors.blue),
        _MenuItem(icon: Icons.assignment_rounded, title: 'My Reports', route: '/my-reports', color: Colors.teal),
        _MenuItem(icon: Icons.account_balance_wallet_rounded, title: 'Penalty History', route: '/penalty-history', color: Colors.orange),
        _MenuItem(icon: Icons.payment_rounded, title: 'Submit Payment', route: '/submit-payment', color: Colors.green),
        _MenuItem(icon: Icons.receipt_long_rounded, title: 'Payment History', route: '/payment-history', color: Colors.indigo),
        _MenuItem(icon: Icons.bar_chart_rounded, title: 'My Analytics', route: '/analytics', color: Colors.purple),
      ];

  List<_MenuItem> get _systemManagementActions => [
        _MenuItem(icon: Icons.assignment_turned_in_rounded, title: 'Deed Management', route: '/admin/deed-management', color: Colors.teal),
        _MenuItem(icon: Icons.event_busy_rounded, title: 'Rest Days', route: '/admin/rest-days', color: Colors.amber),
        _MenuItem(icon: Icons.event_available_rounded, title: 'Excuses', route: '/admin/excuses', color: Colors.orange),
        _MenuItem(icon: Icons.payment_rounded, title: 'Payment Review', route: '/payment-review', color: Colors.green),
        _MenuItem(icon: Icons.settings_rounded, title: 'System Settings', route: '/admin/system-settings', color: Colors.blueGrey),
        _MenuItem(icon: Icons.notifications_active_rounded, title: 'Notification Templates', route: '/admin/notification-templates', color: Colors.deepOrange),
        _MenuItem(icon: Icons.history_rounded, title: 'Audit Logs', route: '/admin/audit-logs', color: Colors.grey),
      ];

  List<_MenuItem> get _contentActions => [
        _MenuItem(icon: Icons.description_rounded, title: 'Reports', route: '/admin/reports', color: Colors.teal),
        _MenuItem(icon: Icons.send_rounded, title: 'Send Notification', route: '/admin/manual-notification', color: Colors.orange),
        _MenuItem(icon: Icons.campaign_rounded, title: 'Announcements', route: '/admin/announcements', color: Colors.indigo),
        _MenuItem(icon: Icons.article_rounded, title: 'App Content', route: '/admin/app-content', color: Colors.cyan),
      ];
}

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
