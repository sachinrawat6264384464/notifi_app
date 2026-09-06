import 'package:flutter/material.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('System Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Notification Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryBlue,
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                  subtitle: const Text('Receive FCM reminders on this device', style: TextStyle(fontSize: 12, color: AppTheme.navyMuted)),
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                const Divider(height: 1, color: AppTheme.borderLight),
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryBlue,
                  title: const Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                  value: _soundEnabled,
                  onChanged: (val) => setState(() => _soundEnabled = val),
                ),
                const Divider(height: 1, color: AppTheme.borderLight),
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryBlue,
                  title: const Text('Vibration Alert', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                  value: _vibrationEnabled,
                  onChanged: (val) => setState(() => _vibrationEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Automation Rules',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: const Text('Reminder Configurations', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
              subtitle: const Text('Customize default notification lead times', style: TextStyle(fontSize: 12, color: AppTheme.navyMuted)),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              onTap: () => Navigator.pushNamed(context, '/reminder-config'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderConfigScreen extends StatelessWidget {
  const ReminderConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Reminder Rules'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderLight, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Column(
              children: [
                ListTile(title: Text('7 Days Before', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
                Divider(height: 1, color: AppTheme.borderLight),
                ListTile(title: Text('3 Days Before', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
                Divider(height: 1, color: AppTheme.borderLight),
                ListTile(title: Text('1 Day Before', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
                Divider(height: 1, color: AppTheme.borderLight),
                ListTile(title: Text('2 Hours Before', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
                Divider(height: 1, color: AppTheme.borderLight),
                ListTile(title: Text('30 Minutes Before', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
                Divider(height: 1, color: AppTheme.borderLight),
                ListTile(title: Text('Exact Time', style: TextStyle(color: AppTheme.navyDark)), trailing: Icon(Icons.check, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

