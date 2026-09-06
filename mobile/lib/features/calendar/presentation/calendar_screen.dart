import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/task_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _dayTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchCalendarTasks(_focusedDay);
  }

  Future<void> _fetchCalendarTasks(DateTime date) async {
    setState(() => _isLoading = true);
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().toIso8601String();
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

    try {
      final client = ApiClient();
      final response = await client.dio.get('/calendar', queryParameters: {'start_date': start, 'end_date': end});
      if (response.data['success'] == true) {
        setState(() {
          _dayTasks = response.data['data'];
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
        title: const Text('Calendar Schedule'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080A84FF),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchCalendarTasks(selectedDay);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.2), shape: BoxShape.circle),
                todayTextStyle: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                defaultTextStyle: const TextStyle(color: AppTheme.navyDark),
                weekendTextStyle: const TextStyle(color: AppTheme.navyMuted),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('Tasks for Selected Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available_outlined, size: 48, color: AppTheme.navyMuted.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            const Text(
                              'No tasks scheduled for this date.',
                              style: TextStyle(color: AppTheme.navyMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _dayTasks.length,
                        itemBuilder: (context, index) {
                          final task = _dayTasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                child: const Icon(Icons.event_note, color: AppTheme.primaryBlue, size: 20),
                              ),
                              title: Text(
                                task['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyDark),
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
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

