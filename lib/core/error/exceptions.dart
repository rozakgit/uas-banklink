class ServerException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ServerException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'Terjadi kesalahan jaringan, periksa koneksi internet Anda.';
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
