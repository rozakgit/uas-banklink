import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/app_button.dart';

class TopupDeeplinkPage extends StatefulWidget {
  final Object? data;
  const TopupDeeplinkPage({super.key, this.data});

  @override
  State<TopupDeeplinkPage> createState() => _TopupDeeplinkPageState();
}

class _TopupDeeplinkPageState extends State<TopupDeeplinkPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data is DeeplinkTopupData) {
        _processTopup();
      }
    });
  }

  void _processTopup() {
    setState(() => _isProcessing = true);
    final payload = widget.data as DeeplinkTopupData;
    context.read<PaymentBloc>().add(PaymentTopupRequested(payload.amount));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.data is! DeeplinkTopupData) {
      final message = widget.data is String
          ? widget.data as String
          : 'Link top-up tidak ditemukan atau tidak valid.';
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 60),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary)),
              const SizedBox(height: 24),
              AppButton(label: 'Kembali', onPressed: () => context.go('/home'), fullWidth: false),
            ],
          ),
        ),
      );
    }

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentTopupSuccess) {
          context.go('/success', extra: {
            'title': 'Top-up Berhasil',
            'subtitle': 'Dana telah masuk ke akun Anda',
            'amount': state.amount,
            'lines': [
              ['Saldo Baru', CurrencyFormatter.format(state.balance)],
            ],
          });
        } else if (state is PaymentError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(color: AppColors.bluePrimary),
                const SizedBox(height: 24),
                Text('Memproses Top-up...', style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ] else ...[
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.bluePrimary, size: 60),
                const SizedBox(height: 16),
                const Text('Top-up Gagal', style: TextStyle(color: AppColors.danger, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                AppButton(label: 'Kembali', onPressed: () => context.go('/home'), fullWidth: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
