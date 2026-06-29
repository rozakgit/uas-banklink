import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Riwayat', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterTab('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterTab('in', 'Income'),
                const SizedBox(width: 8),
                _buildFilterTab('out', 'Expense'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading) return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
                if (state is AccountError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.white54)));
                
                if (state is AccountLoaded) {
                  List<TransactionEntity> txns = state.transactions;
                  if (_tab == 'in') txns = txns.where((t) => t.isCredit).toList();
                  if (_tab == 'out') txns = txns.where((t) => !t.isCredit).toList();

                  if (txns.isEmpty) {
                    return const Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.white54)));
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: txns.length,
                    itemBuilder: (context, i) => _NeoTransactionRow(txn: txns[i]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final active = _tab == value;
    return GestureDetector(
      onTap: () => setState(() => _tab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.neonGreen : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _NeoTransactionRow extends StatelessWidget {
  final TransactionEntity txn;

  const _NeoTransactionRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    return GestureDetector(
      onTap: () => context.push('/history/receipt', extra: txn),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
              child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? AppColors.neonGreen : AppColors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.description, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Trx ID: ${txn.id.toString()} • ${_formatDate(txn.createdAt)}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            Text('${isCredit ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}', 
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: isCredit ? AppColors.neonGreen : AppColors.red)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
