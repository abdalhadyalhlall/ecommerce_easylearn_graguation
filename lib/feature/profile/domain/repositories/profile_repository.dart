import 'dart:typed_data';

import 'package:clean_arch_session/feature/profile/domain/entities/client_profile.dart';

abstract interface class ProfileRepository {
  Future<ClientProfile> getProfile();

  Future<ClientProfile?> getCachedProfile();

  Future<ClientProfile> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String? address,
    required double? latitude,
    required double? longitude,
    Uint8List? pictureBytes,
    String? pictureFileName,
  });
}
