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

    return Scaffold(
      backgroundColor: AppColors.bg,
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
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(recipient['name'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.neonGreen,
                                      )),
                                ),
                              )
                            : AppAvatar(name: recipient['name'] as String, size: 56),
                        const SizedBox(height: 12),
                        const Text('Transfer ke',
                            style: TextStyle(fontSize: 13, color: Colors.white54)),
                        const SizedBox(height: 2),
                        Text(channel == 'bank' ? (recipient['sub'] as String) : (recipient['name'] as String),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                        Text(recipient['sub'] as String,
                            style: const TextStyle(fontSize: 13, color: Colors.white54)),
                        const SizedBox(height: 14),
                        Text(CurrencyFormatter.format(amount),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neonGreen,
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
                        _Line(label: 'Nominal', value: CurrencyFormatter.format(amount)),
                        const Divider(height: 1, color: Colors.white12),
                        _Line(label: 'Biaya admin', value: fee > 0 ? CurrencyFormatter.format(fee) : 'Gratis'),
                        if (note.isNotEmpty) ...[
                          const Divider(height: 1, color: Colors.white12),
                          _Line(label: 'Catatan', value: note),
                        ],
                        const Divider(height: 1, color: Colors.white12),
                        _Line(label: 'Total', value: CurrencyFormatter.format(total), bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Source
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 30),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldo DKG',
                                  style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text('Sumber dana',
                                  style: TextStyle(fontSize: 12, color: Colors.white54)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded, size: 20, color: AppColors.neonGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            color: AppColors.bg,
            child: AppButton(
              label: 'Konfirmasi & Bayar',
              icon: const Icon(Icons.lock_outline_rounded, size: 19, color: Colors.black),
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
  const _Line({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: bold ? 15.5 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white54,
              )),
          Text(value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: bold ? 15.5 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
