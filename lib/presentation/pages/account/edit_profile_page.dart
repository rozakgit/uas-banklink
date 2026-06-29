import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String _name;
  late String _phone;
  late String _dob;
  late String _address;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated || authState is AuthProfileUpdateSuccess) {
      final user = authState is AuthAuthenticated ? authState.user : (authState as AuthProfileUpdateSuccess).user;
      _name = user.name;
      _phone = user.phone ?? '';
      _dob = user.dob ?? '';
      _address = user.address ?? '';
    } else {
      _name = '';
      _phone = '';
      _dob = '';
      _address = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonGreen,
              onPrimary: Colors.black,
              surface: AppColors.bg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dob = "${picked.day.toString().padLeft(2, '0')} ${picked.month.toString().padLeft(2, '0')} ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui', style: TextStyle(fontFamily: 'Inter', color: Colors.black)),
              backgroundColor: AppColors.neonGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/akun/personal-info');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Inter', color: Colors.white)),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.canPop() ? context.pop() : context.go('/akun/personal-info'),
          ),
          title: const Text('Edit Profil', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    AppField(
                      value: _name,
                      onChanged: (v) => setState(() => _name = v),
                      label: 'Nama Lengkap',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      value: _address,
                      onChanged: (v) => setState(() => _address = v),
                      label: 'Alamat',
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      value: _phone,
                      onChanged: (v) => setState(() => _phone = v),
                      label: 'Nomor Telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      value: _dob,
                      label: 'Tanggal Lahir',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(AuthUpdateProfileRequested(
                    name: _name,
                    phone: _phone,
                    dob: _dob,
                    address: _address,
                  ));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Center(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2));
                        }
                        return const Text('Simpan Perubahan', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black));
                      },
                    ),
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
