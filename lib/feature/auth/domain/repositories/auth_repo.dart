import 'package:clean_arch_session/feature/auth/domain/entities/register_entity.dart';

abstract class AuthRepo {
  Future<String> login({required String email, required String password});

  Future<String> register(RegisterEntity entity);

  Future<String> verifyOtp({required String email, required String otpCode});

  Future<String> resendOtp({required String email});

  Future<String> logout();
}
