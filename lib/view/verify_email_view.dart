import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/style_constants.dart';
import '../main.dart';
import '../services/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;
  late final AuthService _authService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: AppTypography.body2.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify your email address',
                    style: AppTypography.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'ve sent you an email verification link. Please check your email and verify your account.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canResendEmail ? sendVerificationEmail : null,
                      style: canResendEmail
                          ? AppButtonStyle.primaryButton
                          : AppButtonStyle.primaryButton.copyWith(
                              backgroundColor: WidgetStateProperty.all(
                                AppColors.accent.withOpacity(0.5),
                              ),
                            ),
                      child: Text(
                        canResendEmail
                            ? 'Resend verification email'
                            : 'Wait 30 seconds',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                            try {
                            timer?.cancel();
                            await _authService.signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                              );
                            }
                            } catch (e) {
                            setState(() {
                              _errorMessage = 'Error during logout: $e';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                              content: Text(
                                _errorMessage ?? 'An error occurred',
                                style: AppTypography.body2.copyWith(
                                color: AppColors.textPrimary
                                ),
                              ),
                              backgroundColor: AppColors.surface,
                              ),
                            );
                            }
                        },
                        child: Text(
                          'Back to Login',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        ' or ',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                            try {
                            timer?.cancel();
                            await _authService.signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                              '/register',
                              (route) => false,
                              );
                            }
                            } catch (e) {
                            setState(() {
                              _errorMessage = 'Error during logout: $e';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                              content: Text(
                                _errorMessage ?? 'An error occurred',
                                style: AppTypography.body2.copyWith(
                                color: AppColors.textPrimary
                                ),
                              ),
                              backgroundColor: AppColors.surface,
                              ),
                            );
                            }
                        },
                        child: Text(
                          'Register New Account',
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
          ],
        ),
      ),
    );
  }
}
