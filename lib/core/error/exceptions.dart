class ServerException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ServerException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Terjadi kesalahan jaringan, periksa koneksi internet Anda.']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  final String? errorCode;

  UnauthorizedException(this.message, {this.errorCode});

  @override
  String toString() => message;
}

class InsufficientBalanceException implements Exception {
  final String message;
  final double? balance;
  final double? amount;

  InsufficientBalanceException(this.message, {this.balance, this.amount});

  @override
  String toString() => message;
}

class InvalidOtpException implements Exception {
  final String message;
  InvalidOtpException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}
