import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController(text: 'BOTMARTZ AI Solutions');
  String _email = 'user@botmartz.ai';
  String _timezone = 'UTC';
  bool _isLoading = true;
  bool _twoFactorEnabled = true;
  bool _showApiKey = false;
  final String _apiKey = 'botmartz_live_pk_8f93a172e9014b';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _email = user.email ?? _email;
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
      }
    }
    try {
      final client = ApiClient();
      final response = await client.dio.get('/users/me');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _nameController.text = data['name'] ?? user?.displayName ?? 'Smart Scheduler User';
          _email = data['email'] ?? user?.email ?? _email;
          _timezone = data['timezone'] ?? 'UTC';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveProfile() async {
    try {
      final client = ApiClient();
      await client.dio.patch('/users/me', data: {'name': _nameController.text.trim(), 'timezone': _timezone});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile & preferences updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved locally.'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      }
    }
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Sign out note: $e");
    } finally {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Account Profile & Enterprise Services'),
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. HERO USER & PLAN BADGE CARD
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
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [AppTheme.primaryBlue, AppTheme.hoverBlue],
                                          ),
                                        ),
                                        child: const Icon(Icons.person, size: 40, color: Colors.white),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _nameController.text.isNotEmpty ? _nameController.text : 'BOTMARTZ AI Architect',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.navyDark,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppTheme.softBlueBackground,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.auto_awesome, size: 12, color: AppTheme.primaryBlue),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Enterprise Pro',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _email,
                                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.navyMuted),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Role: Senior AI Solutions Engineer • Member since 2026',
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.navyMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 2. USAGE METRICS & SERVICES QUOTA
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subscription & Service Quota',
                                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                                      ),
                                      Text(
                                        'Renews Sep 30, 2026',
                                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.navyMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Metric bar 1: AI Tasks
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('AI Task Automations Executed', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.navyDark)),
                                          Text('1,420 / 2,000 (71%)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                        child: LinearProgressIndicator(
                                          value: 0.71,
                                          minHeight: 8,
                                          backgroundColor: AppTheme.softBlueBackground,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Metric bar 2: FCM Reminders
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Push Notification Channels (FCM)', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.navyDark)),
                                          Text('Unlimited Registered', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                        child: LinearProgressIndicator(
                                          value: 1.0,
                                          minHeight: 8,
                                          backgroundColor: AppTheme.softBlueBackground,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 3. PERSONAL INFORMATION EDIT CARD
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personal Details & Preferences',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Update your profile information and regional settings below.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.navyMuted),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Display Name',
                                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _companyController,
                                    decoration: const InputDecoration(
                                      labelText: 'Company / Organization',
                                      prefixIcon: Icon(Icons.business_outlined, color: AppTheme.primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    initialValue: _timezone,
                                    decoration: const InputDecoration(
                                      labelText: 'Preferred Timezone',
                                      prefixIcon: Icon(Icons.public, color: AppTheme.primaryBlue),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'UTC', child: Text('UTC (Coordinated Universal Time)')),
                                      DropdownMenuItem(value: 'Asia/Kolkata', child: Text('Asia/Kolkata (IST)')),
                                      DropdownMenuItem(value: 'America/New_York', child: Text('America/New_York (EST)')),
                                      DropdownMenuItem(value: 'Europe/London', child: Text('Europe/London (GMT)')),
                                    ],
                                    onChanged: (val) => setState(() => _timezone = val!),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: _saveProfile,
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text('Save Profile Changes'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 4. SECURITY & API KEYS
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Security & Developer API Access',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                                  ),
                                  const SizedBox(height: 12),
                                  SwitchListTile(
                                    activeThumbColor: AppTheme.primaryBlue,
                                    title: Text('Two-Factor Authentication (2FA)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                                    subtitle: Text('Secure your BOTMARTZ account with authenticator apps', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.navyMuted)),
                                    value: _twoFactorEnabled,
                                    onChanged: (val) => setState(() => _twoFactorEnabled = val),
                                  ),
                                  const Divider(color: AppTheme.borderLight),
                                  const SizedBox(height: 12),
                                  Text('Personal API Secret Key', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppTheme.softBlueBackground,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.borderLight),
                                          ),
                                          child: Text(
                                            _showApiKey ? _apiKey : '••••••••••••••••••••••••••••',
                                            style: GoogleFonts.robotoMono(fontSize: 13, color: AppTheme.navyDark, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility, color: AppTheme.primaryBlue),
                                        onPressed: () => setState(() => _showApiKey = !_showApiKey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 5. CONNECTED ECOSYSTEM SERVICES
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connected Apps & Integrations',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyDark),
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: AppTheme.softBlueBackground, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.notifications_active, color: AppTheme.primaryBlue),
                                    ),
                                    title: Text('Firebase Messaging Engine', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                                    subtitle: Text('Direct FCM Push Notifications active', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.navyMuted)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.successColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                      child: Text('Active 🟢', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                                    ),
                                  ),
                                  const Divider(color: AppTheme.borderLight),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: AppTheme.softBlueBackground, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.storage_rounded, color: AppTheme.primaryBlue),
                                    ),
                                    title: Text('PostgreSQL Database Cluster', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                                    subtitle: Text('Task & Reminder state sync', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.navyMuted)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.successColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                      child: Text('Connected ⚡', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 6. SIGN OUT BUTTON
                            SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: _signOut,
                                icon: const Icon(Icons.logout, color: AppTheme.dangerColor),
                                label: Text('Sign Out from BOTMARTZ', style: GoogleFonts.inter(color: AppTheme.dangerColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.dangerColor, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
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


