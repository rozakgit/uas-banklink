import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/feature_icon.dart';

class TransferConfirmPage extends StatelessWidget {
  final Map<String, dynamic> recipient;
  final String channel;
  final double amount;
  final String note;
  final double fee;

  const TransferConfirmPage({
    super.key,
    required this.recipient,
    required this.channel,
    required this.amount,
    required this.note,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    final total = amount + fee;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(title: 'Konfirmasi', onBack: () => context.go('/transfer/amount')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Recipient summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        channel == 'bank'
                            ? Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : AppColors.lightLine,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(recipient['name'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.bluePrimary,
                                      )),
                                ),
                              )
                            : AppAvatar(name: recipient['name'] as String, size: 56),
                        const SizedBox(height: 12),
                        Text('Transfer ke',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
                        const SizedBox(height: 2),
                        Text(channel == 'bank' ? (recipient['sub'] as String) : (recipient['name'] as String),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            )),
                        Text(recipient['sub'] as String,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
                        const SizedBox(height: 14),
                        Text(CurrencyFormatter.format(amount),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bluePrimary,
                              letterSpacing: -0.5,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Detail rows
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        _Line(label: 'Nominal', value: CurrencyFormatter.format(amount), isDark: isDark),
                        Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine),
                        _Line(label: 'Biaya admin', value: fee > 0 ? CurrencyFormatter.format(fee) : 'Gratis', isDark: isDark),
                        if (note.isNotEmpty) ...[
                          Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine),
                          _Line(label: 'Catatan', value: note, isDark: isDark),
                        ],
                        Divider(height: 1, color: isDark ? Colors.white12 : AppColors.lightLine),
                        _Line(label: 'Total', value: CurrencyFormatter.format(total), bold: true, isDark: isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Source
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldo Bankling',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                              Text('Sumber dana',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded, size: 20, color: AppColors.bluePrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: AppButton(
              label: 'Konfirmasi & Bayar',
              icon: const Icon(Icons.lock_outline_rounded, size: 19, color: Colors.white),
              onPressed: () => context.go('/pin', extra: {
                'kind': 'transfer',
                'recipient': recipient,
                'channel': channel,
                'amount': amount,
                'note': note,
                'fee': fee,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool isDark;
  const _Line({required this.label, required this.value, this.bold = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: bold ? 15.5 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              )),
          Text(value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: bold ? 15.5 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              )),
        ],
      ),
    );
  }
}
