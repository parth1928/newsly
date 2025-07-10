import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/style_constants.dart';

import '../services/auth_service.dart';
import '../main.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  late final AuthService _authService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Create Account',
                style: AppTypography.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      decoration: AppInputDecoration.defaultDecoration('Email')
                          .copyWith(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: AppTypography.body1,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      decoration:
                          AppInputDecoration.defaultDecoration('Password')
                              .copyWith(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: AppTypography.body1,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPassword,
                      decoration: AppInputDecoration.defaultDecoration(
                              'Confirm Password')
                          .copyWith(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: AppTypography.body1,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.actionPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_password.text != _confirmPassword.text) {
                            setState(() {
                              _errorMessage = 'Passwords do not match';
                            });
                            return;
                          }
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: _email.text,
                              password: _password.text,
                            );
                            await userCredential.user?.sendEmailVerification();
                            setState(() => _errorMessage = null);
                            Navigator.of(context)
                                .pushReplacementNamed('/verify-email');
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _errorMessage = switch (e.code) {
                                'email-already-in-use' =>
                                  'Email already registered',
                                'invalid-email' => 'Invalid email format',
                                'weak-password' => 'Password is too weak',
                                _ => 'An error occurred: ${e.message}',
                              };
                            });
                          }
                        },
                        child: Text(
                          'Register',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: AppTypography.body2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _errorMessage = null);
                    try {
                      final userCredential =
                          await _authService.signInWithGoogle();
                      if (mounted && userCredential.user != null) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code != 'sign_in_canceled') {
                        setState(() {
                          _errorMessage = switch (e.code) {
                            'sign_in_failed' => 'Failed to sign in with Google',
                            'network-request-failed' =>
                              'Network error. Please check your connection',
                            _ => e.message ?? 'Error signing in with Google',
                          };
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _errorMessage = 'An unexpected error occurred';
                        });
                      }
                    }
                  },
                  child: Image.asset(
                    'assets/Android/png@1x/dark/android_dark_rd_SI@1x.png',
                    height: 48, // Standard Google button height
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Login',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Need to verify email? ",
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.of(context)
                            .pushReplacementNamed('/verify-email');
                      } else {
                        setState(() {
                          _errorMessage =
                              'Please register first to verify email';
                        });
                      }
                    },
                    child: Text(
                      'Verify Email',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
