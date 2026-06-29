import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_callback_service.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class PaymentDeeplinkPage extends StatelessWidget {
  final Object? data;
  const PaymentDeeplinkPage({super.key, this.data});

  void _cancel(BuildContext context, DeeplinkPaymentData payload) {
    final cb = payload.callbackUrl;
    if (cb != null && cb.isNotEmpty) {
      DeeplinkCallbackService.notifyCancelled(
        callbackUrl: cb,
        reference: payload.reference,
      ).then((_) => SystemNavigator.pop());
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final payload = data;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (payload is! DeeplinkPaymentData) {
      final message = payload is String ? payload : 'Invalid payment link.';
      return _ErrorView(message: message, isDark: isDark);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel(context, payload);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                      onPressed: () => _cancel(context, payload),
                    ),
                    Expanded(
                      child: Text('Konfirmasi Pembayaran', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                    ),
                    const SizedBox(width: 48), // Balance centering
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: isDark ? Colors.white12 : AppColors.lightLine, shape: BoxShape.circle, border: Border.all(color: AppColors.bluePrimary)),
                        child: const Icon(Icons.storefront, color: AppColors.bluePrimary, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(payload.merchantName, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                      const SizedBox(height: 32),
                      Text('Total Pembayaran', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(CurrencyFormatter.format(payload.amount), style: const TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.bluePrimary)),
                      ),
                      const SizedBox(height: 40),
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(label: 'Keterangan', value: payload.description, isDark: isDark),
                            Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine),
                            if (payload.reference != null && payload.reference!.isNotEmpty) ...[
                              _DetailRow(label: 'Referensi', value: payload.reference!, isDark: isDark),
                              Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine),
                            ],
                            _DetailRow(label: 'Metode Pembayaran', value: 'Saldo Bankling', isDark: isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: () => context.go('/pin', extra: {
                    'kind': 'deeplink',
                    'amount': payload.amount,
                    'description': payload.description,
                    'merchantName': payload.merchantName,
                    'merchantId': payload.merchantId,
                    'reference': payload.reference,
                    'callbackUrl': payload.callbackUrl,
                  }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.bluePrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.bluePrimary.withOpacity(0.3), blurRadius: 8)],
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Bayar ${CurrencyFormatter.format(payload.amount)}', style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : AppColors.lightTextSecondary, fontFamily: 'Inter'))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary, fontFamily: 'Inter'))),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 24),
              Text('Invalid Payment Link', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(color: AppColors.bluePrimary, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('Return to Home', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
