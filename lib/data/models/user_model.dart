import 'dart:convert';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    required super.name,
    required super.role,
    required super.emailVerified,
    required super.totpEnabled,
    super.twoFaMethod,
    super.phone,
    super.dob,
    super.address,
    super.photoUrl,
    super.accountNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      firebaseUid: json['firebase_uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      emailVerified: json['email_verified'] as bool? ?? false,
      totpEnabled: json['totp_enabled'] as bool? ?? false,
      twoFaMethod: json['two_fa_method'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      accountNumber: json['account_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'name': name,
      'role': role,
      'email_verified': emailVerified,
      'totp_enabled': totpEnabled,
      'two_fa_method': twoFaMethod,
      'phone': phone,
      'dob': dob,
      'address': address,
      'photo_url': photoUrl,
      'account_number': accountNumber,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
