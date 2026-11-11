import 'dart:typed_data';

class RegisterEntity {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? address;
  final String? latitude;
  final String? longitude;
  final Uint8List? pictureBytes;
  final String? pictureFileName;

  const RegisterEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.address,
    this.latitude,
    this.longitude,
    this.pictureBytes,
    this.pictureFileName,
  });
}
