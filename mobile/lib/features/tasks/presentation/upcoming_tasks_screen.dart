import 'package:flutter/material.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/task_details_screen.dart';

class FilteredTasksScreen extends StatefulWidget {
  final String statusFilter;
  final String title;

  const FilteredTasksScreen({super.key, required this.statusFilter, required this.title});

  @override
  State<FilteredTasksScreen> createState() => _FilteredTasksScreenState();
}

class _FilteredTasksScreenState extends State<FilteredTasksScreen> {
  bool _isLoading = true;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/tasks', queryParameters: {'status': widget.statusFilter});
      if (response.data['success'] == true) {
        setState(() {
          _tasks = response.data['data']['items'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: AppTheme.navyMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'No ${widget.title.toLowerCase()} found.',
                        style: const TextStyle(fontSize: 16, color: AppTheme.navyMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x050A84FF),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.softBlueBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.task, color: AppTheme.primaryBlue, size: 20),
                        ),
                        title: Text(
                          task['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.navyDark),
                        ),
                        subtitle: Text(
                          'Due: ${task['due_at']}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.navyMuted),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TaskDetailsScreen(taskId: task['id'])),
                          ).then((_) => _fetchTasks());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task').then((_) => _fetchTasks());
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

