import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _overdueTasks = 0;
  Map<String, int> _categoryCount = {};
  int _streakDays = 5; // Default demo streak

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final client = ApiClient();
      final response = await client.dio.get('/tasks', queryParameters: {'page_size': 100});
      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>;
        int completed = 0;
        int pending = 0;
        int overdue = 0;
        Map<String, int> categories = {};

        for (var t in items) {
          final status = t['status'] ?? 'pending';
          if (status == 'completed') completed++;
          else if (status == 'overdue') overdue++;
          else pending++;

          final cat = (t['category'] ?? 'General').toString();
          categories[cat] = (categories[cat] ?? 0) + 1;
        }

        setState(() {
          _totalTasks = items.length;
          _completedTasks = completed;
          _pendingTasks = pending;
          _overdueTasks = overdue;
          _categoryCount = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Analytics load exception: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = _totalTasks > 0 ? (_completedTasks / _totalTasks * 100).round() : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Productivity Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Overview Banner
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                            : [AppTheme.primaryColor, AppTheme.deepBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppTheme.radiusLg,
                      boxShadow: [AppTheme.softShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Productivity Score',
                              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.70), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('$_streakDays Day Streak', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$completionRate%',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tasks Completed ($_completedTasks/$_totalTasks)',
                              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.87), fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _totalTasks > 0 ? _completedTasks / _totalTasks : 0,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Task Breakdown', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Stat Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Completed', '$_completedTasks', AppTheme.successColor, Icons.check_circle_outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Pending', '$_pendingTasks', AppTheme.primaryColor, Icons.hourglass_top),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Overdue', '$_overdueTasks', AppTheme.dangerColor, Icons.warning_amber_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Category Breakdown', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (_categoryCount.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: AppTheme.radiusMd,
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text('No categories found', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                    )
                  else
                    ..._categoryCount.entries.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: AppTheme.radiusMd,
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.folder_outlined, color: AppTheme.primaryColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(e.key, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('${e.value} tasks', style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
