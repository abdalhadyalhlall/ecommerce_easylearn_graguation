import 'package:clean_arch_session/feature/auth/domain/repositories/auth_repo.dart';

class VerifyOtpUseCase {
  final AuthRepo _authRepo;

  VerifyOtpUseCase(this._authRepo);

  Future<String> call({required String email, required String otpCode}) {
    return _authRepo.verifyOtp(email: email, otpCode: otpCode);
  }
}
