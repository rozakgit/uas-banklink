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
          'sub': 'Rekening Danantara: ${data['account_number']}',
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Kirim Uang', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTab('Danantara', 'dkg'),
                  _buildTab('Bank', 'bank'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _tab == 'dkg' ? _buildDkgTab() : _buildBanksTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final active = _tab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _tab = value; _errorMsg = null; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.neonGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 8)] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.white70,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildDkgTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kirim ke Sesama Danantara', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
            Text(_errorMsg!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
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

  Widget _buildBanksTab() {
    return const Center(
      child: Text('Daftar Bank belum tersedia.', style: TextStyle(color: Colors.white54)),
    );
  }
}
