import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/auth/send_otp_usecase.dart';
import '../../../domain/usecases/auth/verify_email_otp_usecase.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/code_input.dart';
import '../../widgets/feature_icon.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  String _code = '';
  int _timer = 60;
  bool _hasError = false;
  bool _loading = false;
  String? _errorMessage;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdown?.cancel();
    setState(() => _timer = 60);
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer <= 0) {
        t.cancel();
      } else {
        setState(() => _timer--);
      }
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      _code = value;
      _hasError = false;
      _errorMessage = null;
    });
    if (value.length == 6) {
      _verify(value);
    }
  }

  Future<void> _verify(String code) async {
    setState(() => _loading = true);
    try {
      await sl<VerifyEmailOtpUsecase>()(code);
      if (mounted) context.go('/setup-2fa');
    } on ServerFailure catch (e) {
      final isInvalidOtp = e.errorCode == 'INVALID_OTP';
      setState(() {
        _hasError = true;
        _errorMessage = isInvalidOtp ? 'Kode salah atau sudah kadaluarsa' : e.message;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() { _code = ''; _hasError = false; });
      });
    } catch (_) {
      setState(() { _hasError = true; _errorMessage = 'Terjadi kesalahan, coba lagi'; });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() { _code = ''; _hasError = false; });
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await sl<SendOtpEmailUsecase>()();
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP baru telah dikirim ke email kamu'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal kirim ulang, coba lagi'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'email kamu';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.darkSurface;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient & Abstract Shapes
          if (isDark)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkSurface, Color(0xFF0F172A)],
                ),
              ),
            ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bluePrimary.withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: AppColors.bluePrimary.withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                    onPressed: () => context.go('/register'),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    color: AppColors.bluePrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.mark_email_unread_rounded, size: 36, color: AppColors.bluePrimary),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.bluePrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 3),
                                    ),
                                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Verify email',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                text: 'We sent a 6-digit code to\n',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: subtitleColor,
                                  height: 1.55,
                                ),
                                children: [
                                  TextSpan(
                                    text: email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              transform: _hasError
                                  ? (Matrix4.identity()..translateByDouble(10.0, 0, 0, 1.0))
                                  : Matrix4.identity(),
                              child: CodeInput(
                                value: _code,
                                onChanged: _loading ? (_) {} : _onCodeChanged,
                                hasError: _hasError,
                              ),
                            ),
                            if (_loading) ...[
                              const SizedBox(height: 24),
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(AppColors.bluePrimary),
                                ),
                              ),
                            ] else if (_hasError && _errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                            _timer > 0
                                ? Text(
                                    'Resend code in 00:${_timer.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: subtitleColor,
                                    ),
                                  )
                                : TextButton.icon(
                                    onPressed: _resend,
                                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.bluePrimary),
                                    label: const Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.bluePrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
