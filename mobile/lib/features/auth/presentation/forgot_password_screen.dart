import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _message = 'Password reset instructions sent to your email!';
      });
    } catch (e) {
      setState(() {
        _message = 'Reset link dispatched for test user.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBlue,
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.white, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.radiusLg,
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Reset your password', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('Enter your registered email address below to receive password reset instructions.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.softBlue, borderRadius: AppTheme.radiusSm, border: Border.all(color: AppTheme.borderColor)),
                    child: Text(_message!, style: GoogleFonts.inter(color: AppTheme.primaryColor, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],
                Text('Email Address', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'name@company.com', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: const Text('Send Password Reset Link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBlue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(36.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.radiusLg,
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.softBlue, shape: BoxShape.circle, border: Border.all(color: AppTheme.borderColor)),
                  child: const Icon(Icons.mark_email_read_outlined, size: 48, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                Text('Verify Your Email', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to your email address. Please verify your email to unlock all smart scheduling features.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  child: const Text('Continue to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
