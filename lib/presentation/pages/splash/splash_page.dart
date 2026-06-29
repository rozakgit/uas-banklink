import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup Entrance Animation
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _animController.forward();

    // Check Auth Status after a slight delay to let animation play
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          final storage = sl<SecureStorageDatasource>();
          final hasPin = await storage.getAppLockPin();
          final bioEnabled = await storage.getBiometricEnabled();

          if (!context.mounted) return;

          if ((hasPin != null && hasPin.isNotEmpty) || bioEnabled) {
            context.go('/app-lock');
          } else {
            final pending = DeeplinkService.consumePending();
            if (pending != null) {
              context.go('/pay', extra: pending);
            } else {
              context.go('/home');
            }
          }
        }
      },
      child: Scaffold(
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
            // Animated Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Spacer(),
                        const AppLogo(size: 92, light: true),
                        const SizedBox(height: 26),
                        const Text(
                          'Bankling',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'FINANCE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bluePrimary,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bayar, transfer, dan kelola uang kamu\ndalam satu aplikasi yang aman.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            AppButton(
                              label: 'Buat Akun Baru',
                              variant: AppButtonVariant.primary,
                              onPressed: () => context.push('/register'),
                            ),
                            const SizedBox(height: 11),
                            AppButton(
                              label: 'Masuk ke Akun',
                              variant: AppButtonVariant.outlineWhite,
                              onPressed: () => context.push('/login'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
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
