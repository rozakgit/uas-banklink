import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/app_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
    context.read<AuthBloc>().add(AuthCheckRequested());
    context.read<NotificationBloc>().add(NotificationLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final fullName = user?.name ?? 'User';

        return Scaffold(
          body: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              final balance = accountState is AccountLoaded ? accountState.account.balance : 0.0;
              final txns = accountState is AccountLoaded ? accountState.transactions : <TransactionEntity>[];
              
              return RefreshIndicator(
                onRefresh: () async => context.read<AccountBloc>().add(AccountRefreshRequested()),
                color: AppColors.bluePrimary,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      // Background Top Gradient
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [AppColors.bluePrimary.withOpacity(0.4), Colors.transparent]
                                : [AppColors.blueLight.withOpacity(0.5), Colors.transparent],
                          ),
                        ),
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Bar Area
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20),
                            child: _buildTopHeader(fullName, isDark),
                          ),
                          
                          // Balance Card (Floating)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildBalanceCard(balance, user),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Services (PPOB Grid)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildServicesGrid(isDark),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Recent Transactions (Bottom Sheet Style)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                            child: _buildTransactionList(txns, isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(String fullName, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bluePrimary.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.bluePrimary.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          child: AppAvatar(name: fullName, size: 44, bg: Colors.transparent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: subtitleColor)),
              Text(fullName, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ),
        // Theme Switcher
        GestureDetector(
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.black38 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isDark ? [] : AppColors.shadowCardLight,
              border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.bluePrimary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Notifications
        GestureDetector(
          onTap: () async {
            await context.push('/notification');
            if (mounted) context.read<NotificationBloc>().add(NotificationLoadRequested());
          },
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              bool hasUnread = false;
              if (state is NotificationLoaded) {
                hasUnread = state.notifications.any((n) => !n.isRead);
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isDark ? [] : AppColors.shadowCardLight,
                      border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
                    ),
                    child: Icon(Icons.notifications_rounded, color: isDark ? Colors.white : AppColors.lightTextPrimary, size: 22),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double balance, UserEntity? user) {
    final String rawAccountNo = user?.accountNumber ?? "2362000";
    final String accountNo = rawAccountNo.length == 7 
        ? "${rawAccountNo.substring(0, 4)} ${rawAccountNo.substring(4)}" 
        : rawAccountNo;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.bluePrimary.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70),
                    ),
                    Icon(Icons.wifi_rounded, color: Colors.white.withOpacity(0.5), size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _hideBalance ? CurrencyFormatter.maskBalance() : CurrencyFormatter.format(balance),
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _hideBalance = !_hideBalance),
                      child: Icon(_hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white70, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Number',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white54),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              accountNo,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: rawAccountNo));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nomor rekening disalin!'),
                                    backgroundColor: AppColors.bluePrimary,
                                  ),
                                );
                              },
                              child: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Glassmorphic Quick Action button inside card
                    GestureDetector(
                      onTap: () => context.go('/transfer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Send', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(bool isDark) {
    final actions = [
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Top Up', 'route': '/topup'},
      {'icon': Icons.phone_android_rounded, 'label': 'Pulsa/Data', 'route': null},
      {'icon': Icons.bolt_rounded, 'label': 'Listrik', 'route': null},
      {'icon': Icons.water_drop_rounded, 'label': 'PDAM', 'route': null},
      {'icon': Icons.wifi_rounded, 'label': 'Internet', 'route': null},
      {'icon': Icons.health_and_safety_rounded, 'label': 'BPJS', 'route': null},
      {'icon': Icons.school_rounded, 'label': 'Pendidikan', 'route': null},
      {'icon': Icons.grid_view_rounded, 'label': 'Lainnya', 'route': null},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 20,
      alignment: WrapAlignment.spaceBetween,
      children: actions.map((a) {
        final w = (MediaQuery.of(context).size.width - 48 - (16 * 3)) / 4; // 4 columns
        return GestureDetector(
          onTap: a['route'] != null ? () => context.go(a['route'] as String) : null,
          child: SizedBox(
            width: w,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? [] : AppColors.shadowCardLight,
                    border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
                  ),
                  child: Icon(a['icon'] as IconData, color: AppColors.bluePrimary, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  a['label'] as String, 
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.lightTextPrimary)
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> txns, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            GestureDetector(
              onTap: () => context.go('/history'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('See All', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bluePrimary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        txns.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black12),
                      const SizedBox(height: 16),
                      Text('No transactions yet', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              )
            : Column(
                children: txns.take(5).map((txn) {
                  final isIncome = txn.isCredit;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.white12 : AppColors.lightLine),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: isIncome 
                                ? LinearGradient(colors: [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                                : LinearGradient(colors: [AppColors.danger.withOpacity(0.2), AppColors.danger.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isIncome ? AppColors.success.withOpacity(0.3) : AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 20, color: isIncome ? AppColors.success : AppColors.danger),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(txn.description, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                              const SizedBox(height: 4),
                              Text('ID: ${txn.id}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                        Text('${isIncome ? '+' : '-'}${CurrencyFormatter.format(txn.amount.abs())}', 
                          style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: isIncome ? AppColors.success : AppColors.lightTextPrimary)),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
