import 'package:clean_arch_session/core/networking/api_error_handler.dart';
import 'package:clean_arch_session/feature/auth/domain/entities/register_entity.dart';
import 'package:clean_arch_session/feature/auth/domain/usecases/login_usecase.dart';
import 'package:clean_arch_session/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:clean_arch_session/feature/auth/domain/usecases/register_usecase.dart';
import 'package:clean_arch_session/feature/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:clean_arch_session/feature/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._verifyOtpUseCase,
    this._resendOtpUseCase,
  ) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final message = await _loginUseCase(email: email, password: password);
      emit(AuthOtpRequired(email: email, message: message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> register(RegisterEntity entity) async {
    emit(AuthLoading());
    try {
      await _registerUseCase(entity);
      final message = await _loginUseCase(
        email: entity.email,
        password: entity.password,
      );
      emit(AuthOtpRequired(email: entity.email, message: message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    emit(AuthLoading());
    try {
      final message = await _verifyOtpUseCase(
        email: email,
        otpCode: otpCode,
      );
      emit(AuthAuthenticated(message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> resendOtp({required String email}) async {
    emit(AuthLoading());
    try {
      final message = await _resendOtpUseCase(email: email);
      emit(AuthOtpResent(message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final message = await _logoutUseCase();
      emit(AuthLoggedOut(message: message));
    } catch (error) {
      emit(
        AuthLoggedOut(
          message: 'تم تسجيل الخروج محلياً. ${ApiErrorHandler.getMessage(error)}',
        ),
      );
    }
  }
}
