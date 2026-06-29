import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/auth/register_with_otp_usecase.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/feature_icon.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _name = '';
  String _email = '';
  String _pw = '';
  bool _showPw = false;
  bool _agree = true;
  bool _loading = false;

  bool get _valid => _name.length > 1 && _email.contains('@') && _pw.length >= 6 && _agree;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      // 1. Buat akun di Firebase
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _pw,
      );
      await credential.user?.updateDisplayName(_name);

      // 2. Ambil Firebase ID Token lalu kirim ke backend
      final idToken = await credential.user?.getIdToken();
      if (idToken == null) throw Exception('Gagal mendapatkan token Firebase');

      await sl<RegisterWithOtpUsecase>()(idToken);

      // 3. Backend sudah buat user + kirim OTP ke email → ke halaman verifikasi
      if (mounted) context.go('/verify-email');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registrasi gagal.'), backgroundColor: AppColors.red),
        );
      }
    } on ServerFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.red),
        );
      }
    } on NetworkFailure catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada koneksi internet.'), backgroundColor: AppColors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Abstract Shapes
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
                color: AppColors.bluePrimary.withOpacity(0.15),
                boxShadow: [BoxShadow(color: AppColors.bluePrimary.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)],
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
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.2), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => context.go('/'),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Create Account',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                )),
                            const SizedBox(height: 8),
                            const Text('Sign up for free in 1 minute',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70)),
                            const SizedBox(height: 32),
                            AppField(
                              label: 'Full Name',
                              value: _name,
                              onChanged: (v) => setState(() => _name = v),
                              placeholder: 'Your Full Name',
                              prefixIcon: const Icon(Icons.person_rounded, size: 20),
                            ),
                            const SizedBox(height: 16),
                            AppField(
                              label: 'Email Address',
                              value: _email,
                              onChanged: (v) => setState(() => _email = v),
                              placeholder: 'nama@email.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.mail_rounded, size: 20),
                            ),
                            const SizedBox(height: 16),
                            AppField(
                              label: 'Password',
                              value: _pw,
                              onChanged: (v) => setState(() => _pw = v),
                              obscureText: !_showPw,
                              placeholder: 'Min. 6 characters',
                              prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_showPw ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 20, color: Colors.white54),
                                onPressed: () => setState(() => _showPw = !_showPw),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => setState(() => _agree = !_agree),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _agree ? AppColors.bluePrimary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: _agree ? AppColors.bluePrimary : Colors.white54,
                                        width: 1.6,
                                      ),
                                    ),
                                    child: _agree
                                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: Colors.white70,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.w700),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.w700),
                                          ),
                                          TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              label: 'Sign Up',
                              variant: AppButtonVariant.primary,
                              onPressed: _valid ? _register : null,
                              isLoading: _loading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white54)),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text('Sign In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.bluePrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ),
                    ],
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
