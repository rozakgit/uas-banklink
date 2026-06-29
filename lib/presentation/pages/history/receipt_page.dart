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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCredit = transaction.isCredit;
    final iconColor = isCredit ? AppColors.success : AppColors.danger;
    final iconData = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Scaffold(
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
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Berhasil',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
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
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white24 : AppColors.lightLine),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Nomor Referensi', 'DKG${transaction.id}', isDark),
                  Divider(color: isDark ? Colors.white12 : AppColors.lightLine, height: 24),
                  _buildDetailRow('Waktu Transaksi', _formatDateTime(transaction.createdAt), isDark),
                  Divider(color: isDark ? Colors.white12 : AppColors.lightLine, height: 24),
                  _buildDetailRow('Keterangan', transaction.description, isDark),
                  Divider(color: isDark ? Colors.white12 : AppColors.lightLine, height: 24),
                  _buildDetailRow('Saldo Sebelumnya', CurrencyFormatter.format(transaction.balanceBefore), isDark),
                  Divider(color: isDark ? Colors.white12 : AppColors.lightLine, height: 24),
                  _buildDetailRow('Sisa Saldo', CurrencyFormatter.format(transaction.balanceAfter), isDark),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
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
