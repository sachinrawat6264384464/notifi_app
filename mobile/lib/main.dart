import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/features/auth/presentation/splash_screen.dart';
import 'package:smart_scheduler_mobile/features/auth/presentation/login_screen.dart';
import 'package:smart_scheduler_mobile/features/auth/presentation/signup_screen.dart';
import 'package:smart_scheduler_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:smart_scheduler_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/add_task_screen.dart';
import 'package:smart_scheduler_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:smart_scheduler_mobile/features/tasks/presentation/upcoming_tasks_screen.dart';
import 'package:smart_scheduler_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:smart_scheduler_mobile/features/profile/presentation/profile_screen.dart';
import 'package:smart_scheduler_mobile/features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }
  runApp(const SmartSchedulerApp());
}

class SmartSchedulerApp extends StatelessWidget {
  const SmartSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Scheduler',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add-task': (context) => const AddTaskScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/upcoming-tasks': (context) => const FilteredTasksScreen(statusFilter: 'pending', title: 'Upcoming Tasks'),
        '/completed-tasks': (context) => const FilteredTasksScreen(statusFilter: 'completed', title: 'Completed Tasks'),
        '/overdue-tasks': (context) => const FilteredTasksScreen(statusFilter: 'overdue', title: 'Overdue Tasks'),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/reminder-config': (context) => const ReminderConfigScreen(),
      },
    );
  }
}
