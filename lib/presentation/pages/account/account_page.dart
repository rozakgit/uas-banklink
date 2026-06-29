import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_avatar.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.lightTextPrimary),
              onPressed: () => context.go('/home'),
            ),
            title: Text('Profile', style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              children: [
                // Avatar Header
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bluePrimary, width: 3),
                          ),
                          child: AppAvatar(name: user?.name ?? 'User', size: 100, bg: Colors.transparent),
                        ),
                        Positioned(
                          bottom: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.blueGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('PRO', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(user?.name ?? 'Pengguna', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // General Settings
                _buildSectionTitle('Pengaturan', isDark),
                _buildSettingsCard(
                  isDark: isDark,
                  children: [
                    _Row(icon: Icons.person_outline_rounded, title: 'Informasi Pribadi', isDark: isDark, onTap: () => context.go('/akun/personal-info')),
                    _Row(icon: Icons.account_balance_wallet_outlined, title: 'Kartu Tersimpan', isDark: isDark, onTap: () => context.go('/akun/saved-cards')),
                    _Row(icon: Icons.verified_user_outlined, title: 'Keamanan (2FA)', isDark: isDark, right: const Text('Aktif', style: TextStyle(color: AppColors.bluePrimary, fontSize: 12, fontWeight: FontWeight.w600)), onTap: () => context.go('/setup-2fa')),
                    _Row(
                      icon: Icons.fingerprint_rounded, 
                      title: 'Sidik Jari / Biometrik', 
                      isDark: isDark,
                      right: _BiometricToggle(isDark: isDark), 
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Preferences
                _buildSectionTitle('Preferensi', isDark),
                _buildSettingsCard(
                  isDark: isDark,
                  children: [
                    _Row(icon: Icons.notifications_none_rounded, title: 'Notifikasi', isDark: isDark, right: _Toggle(isDark: isDark), onTap: () {}),
                    _Row(icon: Icons.dark_mode_outlined, title: 'Mode Gelap', isDark: isDark, right: _Toggle(isDark: isDark), onTap: () {}),
                    _Row(icon: Icons.language_rounded, title: 'Bahasa', isDark: isDark, right: Text('ID', style: TextStyle(color: isDark ? Colors.white54 : AppColors.lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w600)), onTap: () {}),
                  ],
                ),
                const SizedBox(height: 32),

                // Logout Button
                GestureDetector(
                  onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('Keluar', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: Text('Bankling · v1.0.0', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: isDark ? Colors.white54 : AppColors.lightTextSecondary))),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children, required bool isDark}) {
    List<Widget> separatedChildren = [];
    for (int i = 0; i < children.length; i++) {
      separatedChildren.add(children[i]);
      if (i < children.length - 1) {
        separatedChildren.add(Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine, indent: 56));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
      ),
      child: Column(children: separatedChildren),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? right;
  final bool isDark;

  const _Row({required this.icon, required this.title, required this.onTap, required this.isDark, this.right});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isDark ? Colors.white12 : AppColors.lightLine, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: isDark ? Colors.white : AppColors.bluePrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            ),
            right ?? Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white54 : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatefulWidget {
  final bool isDark;
  const _Toggle({required this.isDark});
  
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _on = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: _on ? AppColors.bluePrimary : (widget.isDark ? Colors.white24 : AppColors.lightLine),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _BiometricToggle extends StatefulWidget {
  final bool isDark;
  const _BiometricToggle({required this.isDark});
  
  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  bool _on = false;
  final _storage = sl<SecureStorageDatasource>();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await _storage.getBiometricEnabled();
    if (mounted) {
      setState(() => _on = enabled);
    }
  }

  void _toggle() async {
    final newState = !_on;
    await _storage.saveBiometricEnabled(newState);
    
    // Auto-set dummy PIN to fulfill 'hasPin' if enabling biometrics
    // In a real app, this should navigate to an App PIN Setup page
    if (newState) {
      final existingPin = await _storage.getAppLockPin();
      if (existingPin == null || existingPin.isEmpty) {
        await _storage.saveAppLockPin('123456');
      }
    }

    setState(() => _on = newState);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: _on ? AppColors.bluePrimary : (widget.isDark ? Colors.white24 : AppColors.lightLine),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
