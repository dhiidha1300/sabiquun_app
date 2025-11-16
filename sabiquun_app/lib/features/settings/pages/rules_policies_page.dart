import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/di/injection.dart';
import 'package:sabiquun_app/features/settings/presentation/bloc/app_content_bloc.dart';
import 'package:sabiquun_app/features/settings/presentation/bloc/app_content_event.dart';
import 'package:sabiquun_app/features/settings/presentation/bloc/app_content_state.dart';

class RulesPoliciesPage extends StatefulWidget {
  const RulesPoliciesPage({super.key});

  @override
  State<RulesPoliciesPage> createState() => _RulesPoliciesPageState();
}

class _RulesPoliciesPageState extends State<RulesPoliciesPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    context.read<AppContentBloc>().add(const LoadAllPublishedContentRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules & Policies'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContent,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<AppContentBloc, AppContentState>(
        builder: (context, state) {
          if (state is AppContentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load content',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadContent,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AllContentLoaded) {
            final contentList = state.contentList;

            if (contentList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No content available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Content will be added soon',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            // Ensure selected tab is valid
            if (_selectedTab >= contentList.length) {
              _selectedTab = 0;
            }

            return Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        contentList.length,
                        (index) => _buildTab(contentList[index].title, index),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadContent(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildContent(contentList[_selectedTab]),
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No content available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadContent,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Content'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.article,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version ${content.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Content Body
            if (content.contentType == 'html')
              Html(
                data: content.content,
                style: {
                  "body": Style(
                    fontSize: FontSize(14),
                    lineHeight: const LineHeight(1.6),
                  ),
                  "h1": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    margin: Margins.only(top: 16, bottom: 12),
                  ),
                  "h2": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    margin: Margins.only(top: 14, bottom: 10),
                  ),
                  "h3": Style(
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.w600,
                    margin: Margins.only(top: 12, bottom: 8),
                  ),
                  "p": Style(
                    fontSize: FontSize(14),
                    margin: Margins.only(bottom: 12),
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "ol": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "li": Style(
                    fontSize: FontSize(14),
                    margin: Margins.only(bottom: 6),
                  ),
                  "strong": Style(
                    fontWeight: FontWeight.bold,
                  ),
                  "em": Style(
                    fontStyle: FontStyle.italic,
                  ),
                },
              )
            else
              // For markdown, display as plain text with basic formatting
              Text(
                content.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Footer Info
            Row(
              children: [
                Icon(Icons.update, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Last updated: ${_formatDate(content.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
