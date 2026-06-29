import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/feature_icon.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = [
      {'t': 'Cashback 30% di Kopi Kenangan', 'd': 'Maks. Rp10.000 · s.d. 30 Jun', 'tone': 'red', 'icon': Icons.local_cafe_outlined},
      {'t': 'Gratis biaya transfer antarbank', 'd': 'Setiap Jumat · semua bank', 'tone': 'green', 'icon': Icons.send_rounded},
      {'t': 'Voucher Alfamart Rp20.000', 'd': 'Tukar dengan 200 Poin', 'tone': 'amber', 'icon': Icons.shopping_bag_outlined},
      {'t': 'Bonus 5.000 poin top up pertama', 'd': 'Min. Rp50.000', 'tone': 'amber', 'icon': Icons.star_outline_rounded},
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            color: AppColors.bg,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Promo & Reward',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    )),
                Divider(height: 18, color: Colors.white24),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Hero card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.1),
                    border: Border.all(color: AppColors.neonGreen),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -40,
                        bottom: -50,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonGreen.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppBadge(label: 'SPESIAL PENGGUNA BARU', tone: 'green'),
                          SizedBox(height: 12),
                          Text('Bayar tagihan,\ndapat cashback 💸',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              )),
                          SizedBox(height: 8),
                          Text('Kumpulkan poin tiap transaksi.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13.5,
                                color: Colors.white70,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...promos.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          FeatureIcon(icon: p['icon'] as IconData, tone: p['tone'] as String, size: 50, iconSize: 24),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['t'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.3,
                                    )),
                                const SizedBox(height: 3),
                                Text(p['d'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      color: Colors.white54,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
