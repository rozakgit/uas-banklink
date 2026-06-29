import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_avatar.dart';

import '../../../injection/injection_container.dart';
import '../../../data/datasources/remote/payment_remote_datasource.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String _tab = 'dkg';
  final TextEditingController _accountCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveAccount() async {
    final acc = _accountCtrl.text.trim().replaceAll(' ', '');
    if (acc.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final remote = sl<PaymentRemoteDatasource>();
      final data = await remote.resolveAccount(acc);
      
      if (mounted) {
        // Construct recipient object as expected by TransferAmountPage
        final recipient = {
          'id': data['account_number'],
          'name': data['name'],
          'sub': 'Rekening Bankling: ${data['account_number']}',
        };
        context.go('/transfer/amount', extra: {'recipient': recipient, 'channel': 'dkg'});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = 'Rekening tidak ditemukan atau koneksi bermasalah');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.lightTextPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Transfer', style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : AppColors.lightLine,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTab('Bankling', 'dkg', isDark),
                  _buildTab('Bank', 'bank', isDark),
                ],
              ),
            ),
          ),
          Expanded(
            child: _tab == 'dkg' ? _buildDkgTab(isDark) : _buildBanksTab(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, bool isDark) {
    final active = _tab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _tab = value; _errorMsg = null; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active ? AppColors.blueGradient : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: AppColors.bluePrimary.withOpacity(0.3), blurRadius: 8)] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildDkgTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kirim ke Sesama Bankling', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
          const SizedBox(height: 16),
          AppField(
            label: 'Nomor Rekening',
            value: _accountCtrl.text,
            onChanged: (v) {
              if (_accountCtrl.text != v) {
                _accountCtrl.text = v;
                _accountCtrl.selection = TextSelection.collapsed(offset: v.length);
              }
            },
            keyboardType: TextInputType.number,
            placeholder: 'Contoh: 2362...',
            prefixIcon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 8),
            Text(_errorMsg!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: 'Cari Rekening',
            isLoading: _isLoading,
            onPressed: _resolveAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildBanksTab(bool isDark) {
    return Center(
      child: Text('Daftar Bank belum tersedia.', style: TextStyle(color: isDark ? Colors.white54 : AppColors.lightTextSecondary)),
    );
  }
}
