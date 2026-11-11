import 'package:clean_arch_session/core/cache/cache_const.dart';
import 'package:clean_arch_session/core/cache/cache_helper.dart';
import 'package:clean_arch_session/core/networking/api_constants.dart';
import 'package:clean_arch_session/core/networking/api_service.dart';
import 'package:clean_arch_session/feature/auth/domain/entities/register_entity.dart';
import 'package:clean_arch_session/feature/auth/domain/repositories/auth_repo.dart';
import 'package:dio/dio.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiService _apiService;

  AuthRepoImpl(this._apiService);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return _message(response.data, 'OTP sent to your email and phone');
  }

  @override
  Future<String> register(RegisterEntity entity) async {
    final fields = <String, dynamic>{
      'name': entity.name,
      'email': entity.email,
      'phone': entity.phone,
      'password': entity.password,
      'password_confirmation': entity.passwordConfirmation,
      if (_hasValue(entity.address)) 'address': entity.address,
      if (_hasValue(entity.latitude)) 'latitude': entity.latitude,
      if (_hasValue(entity.longitude)) 'longitude': entity.longitude,
    };
    if (entity.pictureBytes != null) {
      fields['picture'] = MultipartFile.fromBytes(
        entity.pictureBytes!,
        filename: entity.pictureFileName ?? 'profile-picture',
      );
    }

    final response = await _apiService.post(
      ApiConstants.register,
      data: FormData.fromMap(fields),
    );
    return _message(response.data, 'Account created successfully');
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _apiService.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp_code': otpCode},
    );
    final data = response.data;
    final token = data is Map ? data['token'] : null;
    if (token is! String || token.isEmpty) {
      throw StateError('The OTP verification response did not contain a token.');
    }
    await CacheHelper.saveSecureData(
      key: CacheConstants.userToken,
      value: token,
    );
    return _message(data, 'OTP verified successfully');
  }

  @override
  Future<String> resendOtp({required String email}) async {
    final response = await _apiService.post(
      ApiConstants.resendOtp,
      data: {'email': email},
    );
    return _message(response.data, 'OTP resent successfully');
  }

  String _message(dynamic data, String fallback) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  @override
  Future<String> logout() async {
    await CacheHelper.deleteSecureData(key: CacheConstants.userToken);
    return 'تم تسجيل الخروج بنجاح';
  }
}
