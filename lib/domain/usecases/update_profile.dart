import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String name;
  final String phone;
  final String dob;
  final String address;
  final String photoUrl;

  const UpdateProfileParams({
    required this.name,
    this.phone = '',
    this.dob = '',
    this.address = '',
    this.photoUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'dob': dob,
        'address': address,
        'photo_url': photoUrl,
      };
}

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<UserEntity> call(UpdateProfileParams params) => repository.updateProfile(params.toJson());
}
