import 'package:flutter/material.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/task_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/notifications');
      if (response.data['success'] == true) {
        setState(() {
          _notifications = response.data['data']['items'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _markAllRead() async {
    final client = ApiClient();
    await client.dio.post('/notifications/read-all');
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Notifications Center'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primaryBlue),
            onPressed: _markAllRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.navyMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 16, color: AppTheme.navyMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['status'] == 'read';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead ? AppTheme.borderLight : AppTheme.primaryBlue.withValues(alpha: 0.4),
                          width: isRead ? 1.0 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isRead ? const Color(0x040A84FF) : const Color(0x0F0A84FF),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isRead ? AppTheme.softBlueBackground : AppTheme.primaryBlue.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: isRead ? AppTheme.navyMuted : AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notif['title'],
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: AppTheme.navyDark,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            notif['body'],
                            style: const TextStyle(fontSize: 13, color: AppTheme.navyMuted),
                          ),
                        ),
                        trailing: Text(
                          notif['created_at'].toString().split('T')[0],
                          style: const TextStyle(fontSize: 11, color: AppTheme.navyMuted),
                        ),
                        onTap: () {
                          if (notif['task_id'] != null && notif['task_id'].toString().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TaskDetailsScreen(taskId: notif['task_id'])),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

