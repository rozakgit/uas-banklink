import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../injection/injection_container.dart';
import '../../presentation/blocs/account/account_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/otp_bloc.dart';
import '../../presentation/blocs/payment/payment_bloc.dart';
import '../../presentation/blocs/notification/notification_bloc.dart';
import '../../presentation/pages/account/account_page.dart';
import '../../presentation/pages/account/edit_profile_page.dart';
import '../../presentation/pages/account/personal_info_page.dart';
import '../../presentation/pages/account/saved_cards_page.dart';
import '../../presentation/pages/auth/app_lock_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/setup_2fa_page.dart';
import '../../presentation/pages/auth/twofa_notif_page.dart';
import '../../presentation/pages/auth/twofa_smtp_page.dart';
import '../../presentation/pages/auth/twofa_totp_page.dart';
import '../../presentation/pages/auth/verify_email_page.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/history/receipt_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/notification/notification_page.dart';
import '../../presentation/pages/merchant/merchant_checkout_page.dart';
import '../../presentation/pages/payment/payment_deeplink_page.dart';
import '../../presentation/pages/payment/payment_qr_page.dart';
import '../../presentation/pages/payment/pin_page.dart';
import '../../presentation/pages/promo/promo_page.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/success/success_page.dart';
import '../../presentation/pages/topup/topup_page.dart';
import '../../presentation/pages/topup/topup_deeplink_page.dart';
import '../../presentation/pages/transfer/transfer_amount_page.dart';
import '../../presentation/pages/transfer/transfer_confirm_page.dart';
import '../../presentation/pages/transfer/transfer_page.dart';
import '../../presentation/widgets/app_tab_bar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // static final (bukan getter) agar GoRouter dibuat sekali saja —
  // instance yang sama dipakai oleh MaterialApp.router dan DeeplinkService.
  static final GoRouter router = GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => _withAuth(const SplashPage()),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => _withAuth(const LoginPage()),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterPage(),
          ),
          GoRoute(
            path: '/verify-email',
            builder: (_, __) => const VerifyEmailPage(),
          ),
          GoRoute(
            path: '/setup-2fa',
            builder: (context, state) => const Setup2FAPage(),
          ),
          GoRoute(
            path: '/app-lock',
            builder: (context, state) => const AppLockPage(),
          ),
          GoRoute(
            path: '/2fa/smtp',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return _withOtp(TwoFASmtpPage(mode: extra?['mode'] as String? ?? 'login'));
            },
          ),
          GoRoute(
            path: '/2fa/totp',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return _withOtp(TwoFATotpPage(mode: extra?['mode'] as String? ?? 'login'));
            },
          ),
          GoRoute(
            path: '/2fa/notif',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return _withOtp(TwoFANotifPage(mode: extra?['mode'] as String? ?? 'login'));
            },
          ),
          // Main app with tabs
          ShellRoute(
            builder: (context, state, child) {
              final location = state.matchedLocation;
              final tab = location.contains('history')
                  ? 'history'
                  : location.contains('promo')
                      ? 'promo'
                      : location.contains('akun')
                          ? 'akun'
                          : 'home';

              return _withAccount(Scaffold(
                extendBody: true, // Allow body to scroll under the transparent nav parts
                resizeToAvoidBottomInset: false, // Prevent bottom nav from moving up when typing
                backgroundColor: AppColors.bg, // Base dark background
                body: child,
                floatingActionButton: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    onPressed: () => context.go('/payment'),
                    backgroundColor: const Color(0xFFDFF26E), // Neon background for scan button
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent, 
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.black, size: 24),
                    ),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: AppTabBar(
                  active: tab,
                  onTab: (t) {
                    switch (t) {
                      case 'history': context.go('/history'); break;
                      case 'promo': context.go('/promo'); break;
                      case 'akun': context.go('/akun'); break;
                      default: context.go('/home');
                    }
                  },
                ),
              ));
            },
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomePage()),
              GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
              GoRoute(path: '/promo', builder: (_, __) => const PromoPage()),
              GoRoute(path: '/akun', builder: (_, __) => const AccountPage()),
              GoRoute(path: '/akun/personal-info', builder: (_, __) => const PersonalInfoPage()),
              GoRoute(path: '/akun/saved-cards', builder: (_, __) => const SavedCardsPage()),
            ],
          ),
          GoRoute(
            path: '/history/receipt',
            builder: (_, state) => ReceiptPage(transaction: state.extra as TransactionEntity),
          ),
          GoRoute(
            path: '/notification',
            builder: (_, __) => BlocProvider.value(
              value: sl<NotificationBloc>()..add(NotificationLoadRequested()),
              child: const NotificationPage(),
            ),
          ),
          GoRoute(path: '/edit-profile', builder: (_, __) => _withAuth(const EditProfilePage())),
          // Payment flows (no tab bar)
          GoRoute(path: '/topup', builder: (_, __) => _withPayment(const TopUpPage())),
          GoRoute(path: '/transfer', builder: (_, __) => const TransferPage()),
          GoRoute(
            path: '/transfer/amount',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              return _withAccount(TransferAmountPage(
                recipient: extra['recipient'] as Map<String, dynamic>,
                channel: extra['channel'] as String,
              ));
            },
          ),
          GoRoute(
            path: '/transfer/confirm',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              return TransferConfirmPage(
                recipient: extra['recipient'] as Map<String, dynamic>,
                channel: extra['channel'] as String,
                amount: (extra['amount'] as num).toDouble(),
                note: extra['note'] as String? ?? '',
                fee: (extra['fee'] as num? ?? 0).toDouble(),
              );
            },
          ),
          GoRoute(path: '/payment', builder: (_, __) => const PaymentQrPage()),
          GoRoute(
            path: '/pin',
            builder: (_, state) {
              final extra = (state.extra as Map<String, dynamic>?) ?? {};
              return _withPayment(PinPage(flowData: extra));
            },
          ),
          GoRoute(
            path: '/success',
            builder: (_, state) {
              final extra = (state.extra as Map<String, dynamic>?) ?? {};
              return _withAccount(SuccessPage(
                title: extra['title'] as String? ?? 'Berhasil',
                subtitle: extra['subtitle'] as String? ?? '',
                amount: (extra['amount'] as num? ?? 0).toDouble(),
                lines: (extra['lines'] as List<dynamic>?)
                    ?.map((l) => (l as List<dynamic>).map((e) => e.toString()).toList())
                    .toList() ?? [],
              ));
            },
          ),
          GoRoute(path: '/merchant', builder: (_, __) => _withPayment(const MerchantCheckoutPage())),
          GoRoute(
            path: '/pay',
            builder: (_, state) => _withPayment(PaymentDeeplinkPage(data: state.extra)),
          ),
          GoRoute(
            path: '/topup_deeplink',
            builder: (_, state) => _withPayment(TopupDeeplinkPage(data: state.extra)),
          ),
        ],
      );

  static Widget _withAuth(Widget child) {
    return BlocProvider.value(value: sl<AuthBloc>(), child: child);
  }

  static Widget _withOtp(Widget child) {
    return MultiBlocProvider(providers: [
      BlocProvider.value(value: sl<AuthBloc>()),
      BlocProvider(create: (_) => sl<OtpBloc>()),
    ], child: child);
  }

  static Widget _withAccount(Widget child) {
    return MultiBlocProvider(providers: [
      BlocProvider.value(value: sl<AuthBloc>()),
      BlocProvider.value(value: sl<AccountBloc>()..add(AccountLoadRequested())),
      BlocProvider.value(value: sl<NotificationBloc>()),
    ], child: child);
  }

  static Widget _withPayment(Widget child) {
    return MultiBlocProvider(providers: [
      BlocProvider.value(value: sl<AuthBloc>()),
      BlocProvider.value(value: sl<AccountBloc>()),
      BlocProvider(create: (_) => sl<PaymentBloc>()),
      BlocProvider(create: (_) => sl<OtpBloc>()),
    ], child: child);
  }
}
