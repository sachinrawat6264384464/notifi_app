import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';
import 'package:smart_scheduler_mobile/core/network/api_client.dart';
import 'package:smart_scheduler_mobile/core/utils/auth_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please enter work email and password");
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address (e.g. name@domain.com)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ApiClient();
      final response = await client.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['access_token'];
        await saveAuthToken(token);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() => _errorMessage = response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint("Auth login exception: $e");
      String err = "Invalid email or password. Please try again.";
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          if (data['detail'] != null) {
            if (data['detail'] is String) {
              err = data['detail'];
            } else if (data['detail'] is List && data['detail'].isNotEmpty) {
              err = data['detail'][0]['msg'] ?? err;
            }
          } else if (data['message'] != null) {
            err = data['message'];
          }
        }
      }
      if (mounted) {
        setState(() {
          _errorMessage = err;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusLg,
                border: Border.all(color: AppTheme.borderColor, width: 1),
                boxShadow: [AppTheme.softShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Mark
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(Icons.psychology_alt_rounded, size: 36, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'BOTMARTZ ',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'AI',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to manage your smart schedule',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor.withValues(alpha: 0.1),
                        borderRadius: AppTheme.radiusSm,
                        border: Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(color: AppTheme.dangerColor, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email Field
                  Text(
                    'Work Email',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@company.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In to Account'),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppTheme.borderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                      const Expanded(child: Divider(color: AppTheme.borderColor)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In
                  OutlinedButton.icon(
                    onPressed: () {
                      _login(); // Fallback login for dev mode
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: AppTheme.textPrimary),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 24),

                  // Signup link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
