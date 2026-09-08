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

import 'package:provider/provider.dart';
import 'package:smart_scheduler_mobile/core/theme/theme_provider.dart';
import 'package:smart_scheduler_mobile/features/dashboard/presentation/pages/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter UI and Framework errors to prevent immediate app process termination
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Uncaught Flutter Error: ${details.exception}');
  };

  // Catch asynchronous and platform dispatcher errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught Platform Async Error: $error\n$stack');
    return true; // Prevents process crash
  };

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDummyApiKeyForSmartSchedulerApp",
          appId: "1:1234567890:android:abcdef123456",
          messagingSenderId: "1234567890",
          projectId: "botmartz-ai-scheduler",
          storageBucket: "botmartz-ai-scheduler.appspot.com",
        ),
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization gracefully bypassed: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SmartSchedulerApp(),
    ),
  );
}

class SmartSchedulerApp extends StatelessWidget {
  const SmartSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'BOTMARTZ AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/email-verification': (context) => const EmailVerificationScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
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
      },
    );
  }
}
