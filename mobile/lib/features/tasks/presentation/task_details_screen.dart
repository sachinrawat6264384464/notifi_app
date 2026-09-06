import 'package:flutter/material.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _task;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/tasks/${widget.taskId}');
      if (response.data['success'] == true) {
        setState(() {
          _task = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _completeTask() async {
    final client = ApiClient();
    await client.dio.post('/tasks/${widget.taskId}/complete');
    _fetchTaskDetails();
  }

  void _deleteTask() async {
    final client = ApiClient();
    await client.dio.delete('/tasks/${widget.taskId}');
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_task == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found', style: TextStyle(color: AppTheme.navyMuted))),
      );
    }

    final isCompleted = _task!['status'] == 'completed';

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
            tooltip: 'Delete Task',
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0A84FF),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.successColor.withValues(alpha: 0.12)
                              : AppTheme.warningColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _task!['status'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? AppTheme.successColor : AppTheme.warningColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Priority: ${_task!['priority'].toString().toUpperCase()}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navyMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _task!['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _task!['description'] ?? 'No description provided for this task.',
                    style: const TextStyle(fontSize: 14, color: AppTheme.navyMuted, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.event, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Due Date: ${_task!['due_at']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navyDark),
                      ),
                    ],
                  ),
                  if (_task!['category'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.folder_outlined, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Category: ${_task!['category']}',
                          style: const TextStyle(fontSize: 14, color: AppTheme.navyMuted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scheduled Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
            ),
            const SizedBox(height: 12),
            ...(_task!['reminders'] as List).map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlueBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.alarm, color: AppTheme.primaryBlue, size: 20),
                  ),
                  title: Text(
                    r['reminder_type'].toString().replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navyDark),
                  ),
                  subtitle: Text(
                    r['reminder_at'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppTheme.navyMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _completeTask,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Task as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

