import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/core/widgets/botmartz_header.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedPriority = 'medium';
  final List<String> _selectedReminderPresets = ['30_minutes_before', '1_day_before'];
  bool _isLoading = false;

  void _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryBlue,
                onPrimary: Colors.white,
                onSurface: AppTheme.navyDark,
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dueDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ).toUtc();

      final remindersPayload = _selectedReminderPresets.map((type) => {'reminder_type': type}).toList();

      final client = ApiClient();
      final response = await client.dio.post(
        '/tasks',
        data: {
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'due_at': dueDateTime.toIso8601String(),
          'priority': _selectedPriority,
          'category': _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
          'reminders': remindersPayload,
        },
      );

      if (response.data['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueFormatted = '${DateFormat('yyyy-MM-dd').format(_selectedDate)} ${_selectedTime.format(context)}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Create New Task'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BotmartzHeader(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Schedule an intelligent reminder with automatic lead times.',
                        style: TextStyle(fontSize: 13, color: AppTheme.navyMuted),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          hintText: 'e.g., Deploy AI Model Pipeline',
                          prefixIcon: Icon(Icons.task_alt, color: AppTheme.primaryBlue),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add context or details for this task...',
                          prefixIcon: Icon(Icons.notes, color: AppTheme.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDueDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.softBlueBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, color: AppTheme.primaryBlue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Due Date & Time', style: TextStyle(fontSize: 12, color: AppTheme.navyMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      dueFormatted,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.navyDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_calendar, color: AppTheme.primaryBlue, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority Level',
                          prefixIcon: Icon(Icons.flag, color: AppTheme.primaryBlue),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                          DropdownMenuItem(value: 'high', child: Text('High Priority')),
                          DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                        ],
                        onChanged: (val) => setState(() => _selectedPriority = val!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'e.g., Engineering, Work, Personal',
                          prefixIcon: Icon(Icons.folder_outlined, color: AppTheme.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Reminder Lead Times',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '7_days_before',
                          '3_days_before',
                          '1_day_before',
                          '2_hours_before',
                          '30_minutes_before',
                          'exact_time'
                        ].map((preset) {
                          final isSelected = _selectedReminderPresets.contains(preset);
                          final label = preset.replaceAll('_', ' ');
                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: AppTheme.softBlueBackground,
                            backgroundColor: Colors.white,
                            checkmarkColor: AppTheme.primaryBlue,
                            side: BorderSide(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.navyDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedReminderPresets.add(preset);
                                } else {
                                  _selectedReminderPresets.remove(preset);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitTask,
                          icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.add_task),
                          label: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

