import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/theme/theme_provider.dart';
import 'package:smart_scheduler_mobile/core/services/export_service.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  final _telegramController = TextEditingController();

  void _exportCsvData() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/tasks', queryParameters: {'page_size': 200});
      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>;
        final csvData = ExportService.exportTasksToCsv(items);

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Export Tasks (CSV)'),
              content: SingleChildScrollView(
                child: SelectableText(csvData, style: GoogleFonts.firaCode(fontSize: 11)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance & Theme',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Slate Mode'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Notification Preferences',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryColor,
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive local and FCM reminders', style: TextStyle(fontSize: 12)),
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryColor,
                  title: const Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _soundEnabled,
                  onChanged: (val) => setState(() => _soundEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryColor,
                  title: const Text('Vibration Alert', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _vibrationEnabled,
                  onChanged: (val) => setState(() => _vibrationEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Free Telegram Bot Notifications',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your Telegram Chat ID to receive instant free alerts directly on Telegram app.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _telegramController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 123456789',
                    prefixIcon: Icon(Icons.send_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Data & Backup',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.download_outlined, color: AppTheme.primaryColor),
              title: const Text('Export Tasks to CSV', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Generate downloadable 1-click CSV backup of all tasks', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportCsvData,
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
      appBar: AppBar(
        title: const Text('Reminder Rules'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Column(
              children: [
                ListTile(title: Text('7 Days Before'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
                Divider(height: 1),
                ListTile(title: Text('3 Days Before'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
                Divider(height: 1),
                ListTile(title: Text('1 Day Before'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
                Divider(height: 1),
                ListTile(title: Text('2 Hours Before'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
                Divider(height: 1),
                ListTile(title: Text('30 Minutes Before'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
                Divider(height: 1),
                ListTile(title: Text('Exact Time'), trailing: Icon(Icons.check, color: AppTheme.primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
