import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../widgets/code_input.dart';
import '../../widgets/feature_icon.dart';

class TwoFASmtpPage extends StatefulWidget {
  final String mode; // 'login' or 'setup'
  const TwoFASmtpPage({super.key, this.mode = 'login'});
  @override
  State<TwoFASmtpPage> createState() => _TwoFASmtpPageState();
}

class _TwoFASmtpPageState extends State<TwoFASmtpPage> {
  String _code = '';
  bool _hasError = false;
  int _timer = AppConstants.otpResendSeconds;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    context.read<OtpBloc>().add(OtpSendEmail());
    _startTimer();
  }

  void _startTimer() {
    _countdown?.cancel();
    setState(() => _timer = AppConstants.otpResendSeconds);
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer <= 0) t.cancel();
      else setState(() => _timer--);
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String v) {
    setState(() { _code = v; _hasError = false; });
    if (v.length == 6) {
      context.read<OtpBloc>().add(OtpConfirm(code: v, otpType: AppConstants.otpTypeEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          if (widget.mode == 'setup') {
            context.go('/home');
          } else {
            context.read<AuthBloc>().add(AuthCheckRequested());
            context.go('/home');
          }
        } else if (state is OtpInvalid) {
          setState(() { _hasError = true; });
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) setState(() { _code = ''; _hasError = false; });
          });
        } else if (state is OtpError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(DkgIcons.arrowLeft, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightTextPrimary),
                  onPressed: () => context.go(widget.mode == 'setup' ? '/setup-2fa' : '/login'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Column(
                    children: [
                      const FeatureIcon(icon: DkgIcons.mail, tone: 'blue', size: 74, iconSize: 36),
                      const SizedBox(height: 18),
                      Text('Masukkan Email OTP',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          )),
                      const SizedBox(height: 8),
                      Text('Kode 6 digit dikirim ke email kamu via SMTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.lightTextSecondary, height: 1.55)),
                      const SizedBox(height: 28),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        transform: _hasError ? (Matrix4.identity()..translate(8.0)) : Matrix4.identity(),
                        child: CodeInput(value: _code, onChanged: _onCodeChanged, hasError: _hasError),
                      ),
                      if (_hasError) ...[
                        const SizedBox(height: 12),
                        const Text('Kode salah',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bluePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(DkgIcons.info, size: 16, color: AppColors.bluePrimary),
                            SizedBox(width: 8),
                            Text('Cek email inbox atau spam kamu',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  color: AppColors.bluePrimary,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _timer > 0
                          ? Text(
                              'Kirim ulang dalam 00:${_timer.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 13.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.lightTextSecondary),
                            )
                          : TextButton.icon(
                              onPressed: () {
                                context.read<OtpBloc>().add(OtpSendEmail());
                                _startTimer();
                              },
                              icon: const Icon(DkgIcons.refresh, size: 16, color: AppColors.bluePrimary),
                              label: const Text('Kirim ulang kode',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.bluePrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  )),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
