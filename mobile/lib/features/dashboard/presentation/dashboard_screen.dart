import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/task_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {
    'today_count': 0,
    'pending_count': 0,
    'completed_count': 0,
    'overdue_count': 0,
    'high_priority_count': 0,
    'today_tasks': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/dashboard');
      if (response.data['success'] == true) {
        setState(() {
          _dashboardData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                count,
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'BOTMARTZ ',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'AI',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderColor, height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
            tooltip: 'Analytics',
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : RefreshIndicator(
                    onRefresh: _fetchDashboardData,
                    color: AppTheme.primaryColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Productivity Overview',
                                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Real-time overview of tasks & scheduled notifications',
                                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/add-task'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Task'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GridView.count(
                            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.35,
                            children: [
                              _buildStatCard('Today Tasks', '${_dashboardData['today_count']}', Icons.today, AppTheme.primaryColor),
                              _buildStatCard('Pending Tasks', '${_dashboardData['pending_count']}', Icons.pending_actions, AppTheme.primaryColor),
                              _buildStatCard('Completed', '${_dashboardData['completed_count']}', Icons.check_circle_outline, AppTheme.successColor),
                              _buildStatCard('Overdue Tasks', '${_dashboardData['overdue_count']}', Icons.warning_amber_rounded, AppTheme.dangerColor),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Today's Scheduled Tasks",
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 14),
                          if ((_dashboardData['today_tasks'] as List).isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.softBlue,
                                borderRadius: AppTheme.radiusLg,
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.task_alt_rounded, size: 40, color: AppTheme.primaryColor),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tasks scheduled for today 🎉',
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create a new task to get started',
                                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_dashboardData['today_tasks'] as List).length,
                              itemBuilder: (context, index) {
                                final task = _dashboardData['today_tasks'][index];
                                final isCompleted = task['status'] == 'completed';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppTheme.radiusMd,
                                    border: Border.all(color: AppTheme.borderColor),
                                    boxShadow: [AppTheme.softShadow],
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                                    ),
                                    title: Text(
                                      task['title'],
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Text('Due: ${task['due_at']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TaskDetailsScreen(taskId: task['id'])),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-task'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 2) Navigator.pushNamed(context, '/upcoming-tasks');
          if (index == 3) Navigator.pushNamed(context, '/notifications');
          if (index == 4) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), activeIcon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
