import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

@immutable
class DeeplinkPaymentData {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String? reference;
  final String? callbackUrl;

  const DeeplinkPaymentData({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    this.reference,
    this.callbackUrl,
  });

  factory DeeplinkPaymentData.fromUri(Uri uri) {
    final q = uri.queryParameters;

    final merchantId   = q['merchant_id'];
    final merchantName = q['merchant_name'] ?? 'Merchant';
    final amountStr    = q['amount'];

    if (merchantId == null || merchantId.trim().isEmpty) {
      throw const FormatException('Link pembayaran tidak valid: merchant_id tidak ditemukan.');
    }
    if (amountStr == null || amountStr.trim().isEmpty) {
      throw const FormatException('Link pembayaran tidak valid: amount tidak ditemukan.');
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      throw const FormatException('Link pembayaran tidak valid: amount harus berupa angka > 0.');
    }

    return DeeplinkPaymentData(
      merchantId:   merchantId,
      merchantName: merchantName,
      amount:       amount,
      description:  q['description']?.trim().isNotEmpty == true
          ? q['description']!.trim()
          : 'Pembayaran ke $merchantName',
      reference:   q['reference'],
      callbackUrl: q['callback'],
    );
  }
}

class DeeplinkTopupData {
  final double amount;

  const DeeplinkTopupData({required this.amount});

  factory DeeplinkTopupData.fromUri(Uri uri) {
    final amountStr = uri.queryParameters['amount'];
    if (amountStr == null || amountStr.trim().isEmpty) {
      throw const FormatException('Link top-up tidak valid: amount tidak ditemukan.');
    }
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      throw const FormatException('Link top-up tidak valid: amount harus angka > 0.');
    }
    return DeeplinkTopupData(amount: amount);
  }
}

class DeeplinkService {
  final GoRouter _router;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  static Object? _pendingPayload;

  static Object? consumePending() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    return payload;
  }

  static bool get hasPending => _pendingPayload != null;

  DeeplinkService(this._router) : _appLinks = AppLinks();

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && _isPaymentLink(initialUri)) {
        _storePending(initialUri);
      }
    } catch (e) {
      debugPrint('[DeeplinkService] getInitialLink error: $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleInAppUri,
      onError: (e) => debugPrint('[DeeplinkService] stream error: $e'),
    );
  }

  void _storePending(Uri uri) {
    try {
      if (uri.host == 'topup' || uri.path.startsWith('/topup')) {
        _pendingPayload = DeeplinkTopupData.fromUri(uri);
      } else {
        _pendingPayload = DeeplinkPaymentData.fromUri(uri);
      }
    } on FormatException catch (e) {
      _pendingPayload = e.message;
    }
  }

  void _handleInAppUri(Uri uri) {
    if (!_isPaymentLink(uri)) return;

    try {
      if (uri.host == 'topup' || uri.path.startsWith('/topup')) {
        final data = DeeplinkTopupData.fromUri(uri);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _router.go('/topup_deeplink', extra: data);
        });
      } else {
        final data = DeeplinkPaymentData.fromUri(uri);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _router.go('/pay', extra: data);
        });
      }
    } on FormatException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (uri.host == 'topup' || uri.path.startsWith('/topup')) {
          _router.go('/topup_deeplink', extra: e.message);
        } else {
          _router.go('/pay', extra: e.message);
        }
      });
    }
  }

  bool _isPaymentLink(Uri uri) {
    if (uri.scheme == 'bankling' && (uri.host == 'pay' || uri.host == 'topup')) return true;
    if (uri.scheme == 'https' &&
        uri.host == 'bankling.app' &&
        (uri.path.startsWith('/pay') || uri.path.startsWith('/topup'))) {
      return true;
    }
    return false;
  }

  void dispose() => _subscription?.cancel();
}
