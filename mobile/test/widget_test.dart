import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/main.dart';

void main() {
  testWidgets('SmartSchedulerApp renders splash screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartSchedulerApp());
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Smart Enterprise Scheduler & Reminder Engine'), findsOneWidget);
    
    // Advance timer by 3 seconds to complete splash screen navigation timer cleanly
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('AppTheme darkTheme configuration test', () {
    final theme = AppTheme.darkTheme;
    expect(theme.primaryColor, AppTheme.primaryColor);
    expect(theme.scaffoldBackgroundColor, AppTheme.backgroundColor);
  });
}
