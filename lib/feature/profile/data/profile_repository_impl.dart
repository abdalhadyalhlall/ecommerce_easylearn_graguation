import 'dart:convert';
import 'dart:typed_data';

import 'package:clean_arch_session/core/cache/profile_cache.dart';
import 'package:clean_arch_session/core/networking/api_constants.dart';
import 'package:clean_arch_session/core/networking/api_service.dart';
import 'package:clean_arch_session/feature/profile/domain/entities/client_profile.dart';
import 'package:clean_arch_session/feature/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _api;

  ProfileRepositoryImpl(this._api);

  @override
  Future<ClientProfile> getProfile() async {
    final response = await _api.get(ApiConstants.profile);
    final profile = ClientProfile.fromJson(_responseData(response.data));
    await _cacheProfile(profile);
    return profile;
  }

  @override
  Future<ClientProfile?> getCachedProfile() async {
    final encodedProfile = await ProfileCache.read();
    if (encodedProfile == null || encodedProfile.isEmpty) return null;
    final decoded = jsonDecode(encodedProfile);
    if (decoded is! Map) {
      throw const FormatException('Cached profile is not an object.');
    }
    return ClientProfile.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<ClientProfile> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String? address,
    required double? latitude,
    required double? longitude,
    Uint8List? pictureBytes,
    String? pictureFileName,
  }) async {
    final fields = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'address': address ?? '',
      'latitude': latitude?.toString() ?? '',
      'longitude': longitude?.toString() ?? '',
    };
    if (pictureBytes != null) {
      fields['picture'] = MultipartFile.fromBytes(
        pictureBytes,
        filename: pictureFileName ?? 'profile-picture',
      );
    }

    final response = await _api.post(
      ApiConstants.profileUpdate,
      data: FormData.fromMap(fields),
    );
    final data = _optionalResponseData(response.data);
    final profile =
        data == null ||
            !data.containsKey('id') ||
            !data.containsKey('name') ||
            !data.containsKey('email') ||
            !data.containsKey('phone')
        ? await getProfile()
        : ClientProfile.fromJson(data);
    await _cacheProfile(profile);
    return profile;
  }

  Future<void> _cacheProfile(ClientProfile profile) {
    return ProfileCache.save(jsonEncode(profile.toJson()));
  }

  Map<String, dynamic> _responseData(dynamic response) {
    final data = _optionalResponseData(response);
    if (data == null) {
      throw const FormatException('Profile response is missing its data.');
    }
    return data;
  }

  Map<String, dynamic>? _optionalResponseData(dynamic response) {
    if (response is! Map || !response.containsKey('data')) return null;
    final data = response['data'];
    if (data == null) return null;
    if (data is! Map) {
      throw const FormatException('Profile response data is not an object.');
    }
    return Map<String, dynamic>.from(data);
  }
}
