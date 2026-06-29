import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.lightTextPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/akun'),
        ),
        title: Text('Informasi Pribadi', style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated || state is AuthProfileUpdateSuccess) {
            final user = state is AuthAuthenticated ? state.user : (state as AuthProfileUpdateSuccess).user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Nama Lengkap', user.name, isDark),
                        Divider(color: isDark ? Colors.white12 : AppColors.lightLine),
                        _buildInfoRow('Email', user.email, isDark),
                        Divider(color: isDark ? Colors.white12 : AppColors.lightLine),
                        _buildInfoRow('Alamat', user.address ?? '', isDark),
                        Divider(color: isDark ? Colors.white12 : AppColors.lightLine),
                        _buildInfoRow('Nomor Telepon', user.phone ?? '', isDark),
                        Divider(color: isDark ? Colors.white12 : AppColors.lightLine),
                        _buildInfoRow('Tanggal Lahir', user.dob ?? '', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      context.push('/edit-profile');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bluePrimary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.bluePrimary.withOpacity(0.3), blurRadius: 8)],
                      ),
                      child: const Center(
                        child: Text(
                          'Edit Profil', 
                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.bluePrimary));
        },
      ),
    );
  }
}
