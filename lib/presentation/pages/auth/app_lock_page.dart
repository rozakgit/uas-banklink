import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/pin_pad.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  String _pin = '';
  bool _error = false;
  String? _savedPin;
  bool _bioEnabled = false;

  @override
  void initState() {
    super.initState();
    _initLock();
  }

  Future<void> _initLock() async {
    final storage = sl<SecureStorageDatasource>();
    _savedPin = await storage.getAppLockPin();
    _bioEnabled = await storage.getBiometricEnabled();

    if (_bioEnabled && mounted) {
      _promptBiometric();
    }
  }

  Future<void> _promptBiometric() async {
    final service = sl<BiometricService>();
    final success = await service.authenticate(reason: 'Gunakan biometrik untuk membuka Danantara');
    if (success && mounted) {
      _unlockApp();
    }
  }

  void _unlockApp() {
    context.go('/home');
  }

  void _onPinComplete(String pin) {
    if (_savedPin == null || _savedPin!.isEmpty) {
      // Jika user belum pernah set App Lock PIN, untuk keamanan fallback kita anggap "benar" sementara (atau harus diatur di setup)
      // Namun idealnya, jika PIN diset, kita cocokkan.
      _unlockApp();
      return;
    }

    if (pin == _savedPin) {
      _unlockApp();
    } else {
      setState(() {
        _error = true;
        _pin = '';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _error = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline_rounded, size: 32, color: AppColors.neonGreen),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Danantara Terkunci',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
              const SizedBox(height: 8),
              Text(
                _error ? 'PIN salah, silakan coba lagi' : 'Masukkan PIN Aplikasi Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _error ? AppColors.red : Colors.white54,
                ),
              ),
              const Spacer(),
              PinPad(
                value: _pin,
                onChanged: (v) => setState(() => _pin = v),
                onComplete: _onPinComplete,
              ),
              const SizedBox(height: 24),
              if (_bioEnabled)
                TextButton.icon(
                  onPressed: _promptBiometric,
                  icon: const Icon(Icons.fingerprint, color: AppColors.neonGreen),
                  label: const Text('Gunakan Biometrik', style: TextStyle(color: AppColors.neonGreen)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
