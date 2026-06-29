import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class ReceiptPage extends StatelessWidget {
  final TransactionEntity transaction;

  const ReceiptPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final iconColor = isCredit ? AppColors.neonGreen : AppColors.red;
    final iconData = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(title: 'Detail Transaksi', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header: Icon + Amount
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.isCredit ? 'Uang Masuk' : 'Uang Keluar',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Berhasil',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Nomor Referensi', 'DKG${transaction.id}'),
                  const Divider(color: Colors.white12, height: 24),
                  _buildDetailRow('Waktu Transaksi', _formatDateTime(transaction.createdAt)),
                  const Divider(color: Colors.white12, height: 24),
                  _buildDetailRow('Keterangan', transaction.description),
                  const Divider(color: Colors.white12, height: 24),
                  _buildDetailRow('Saldo Sebelumnya', CurrencyFormatter.format(transaction.balanceBefore)),
                  const Divider(color: Colors.white12, height: 24),
                  _buildDetailRow('Sisa Saldo', CurrencyFormatter.format(transaction.balanceAfter)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Kembali',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final t = dt.toLocal();
    final d = t.day.toString().padLeft(2, '0');
    final m = t.month.toString().padLeft(2, '0');
    final y = t.year;
    final h = t.hour.toString().padLeft(2, '0');
    final min = t.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
