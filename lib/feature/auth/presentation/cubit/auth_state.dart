part of 'auth_cubit.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpRequired extends AuthState {
  final String email;
  final String message;

  AuthOtpRequired({required this.email, required this.message});
}

class AuthOtpResent extends AuthState {
  final String message;

  AuthOtpResent(this.message);
}

class AuthAuthenticated extends AuthState {
  final String message;

  AuthAuthenticated(this.message);
}

class AuthLoggedOut extends AuthState {
  final String message;

  AuthLoggedOut({required this.message});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
