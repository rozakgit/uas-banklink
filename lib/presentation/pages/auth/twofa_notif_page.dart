import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../widgets/feature_icon.dart';

class TwoFANotifPage extends StatefulWidget {
  final String mode;
  const TwoFANotifPage({super.key, this.mode = 'login'});
  @override
  State<TwoFANotifPage> createState() => _TwoFANotifPageState();
}

class _TwoFANotifPageState extends State<TwoFANotifPage> {
  String _phase = 'waiting'; // waiting, approved

  @override
  void initState() {
    super.initState();
    context.read<OtpBloc>().add(OtpSendFirebase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          setState(() => _phase = 'approved');
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) context.go('/home');
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
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightTextPrimary),
                  onPressed: () => context.go(widget.mode == 'setup' ? '/setup-2fa' : '/login'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FeatureIcon(
                        icon: _phase == 'approved'
                            ? Icons.verified_user_outlined
                            : Icons.notifications_outlined,
                        tone: 'blue',
                        size: 82,
                        iconSize: 40,
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _phase == 'approved' ? 'Disetujui!' : 'Cek notifikasi kamu',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightTextPrimary,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _phase == 'approved'
                            ? 'Identitas terverifikasi. Mengarahkan…'
                            : 'Kami mengirim notifikasi ke perangkatmu. Ketuk "Setujui" untuk melanjutkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.5,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.lightTextSecondary,
                          height: 1.55,
                        ),
                      ),
                      if (_phase == 'waiting') ...[
                        const SizedBox(height: 34),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(AppColors.bluePrimary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Menunggu persetujuan…',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.5,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ],
                      const Spacer(),
                      Text(
                        'Tidak menerima notifikasi? Kirim ulang',
                        style: TextStyle(fontSize: 12.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.lightTextSecondary),
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
