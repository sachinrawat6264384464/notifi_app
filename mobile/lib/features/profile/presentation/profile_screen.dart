import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _email = '';
  String _timezone = 'UTC';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get('/users/me');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _nameController.text = data['name'] ?? 'BOTMARTZ User';
          _email = data['email'] ?? '';
          _timezone = data['timezone'] ?? 'UTC';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _saveProfile() async {
    final client = ApiClient();
    await client.dio.patch('/users/me', data: {'name': _nameController.text.trim(), 'timezone': _timezone});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.successColor),
      );
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Account Profile'),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
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
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.hoverBlue],
                            ),
                          ),
                          child: const Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _email.isNotEmpty ? _email : 'user@botmartz.ai',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navyMuted),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryBlue),
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
                          width: double.infinity,
                          height: 50,
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: AppTheme.dangerColor),
                      label: const Text('Sign Out', style: TextStyle(color: AppTheme.dangerColor, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.dangerColor),
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

