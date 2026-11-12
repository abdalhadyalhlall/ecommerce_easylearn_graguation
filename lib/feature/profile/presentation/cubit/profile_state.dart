import 'package:clean_arch_session/feature/profile/domain/entities/client_profile.dart';

class ProfileState {
  final ClientProfile? profile;
  final bool loading;
  final bool saving;
  final String? error;
  final String? message;

  const ProfileState({
    this.profile,
    this.loading = false,
    this.saving = false,
    this.error,
    this.message,
  });

  ProfileState copyWith({
    ClientProfile? profile,
    bool clearProfile = false,
    bool? loading,
    bool? saving,
    String? error,
    String? message,
    bool clearFeedback = false,
  }) {
    return ProfileState(
      profile: clearProfile ? null : profile ?? this.profile,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: clearFeedback ? null : error ?? this.error,
      message: clearFeedback ? null : message ?? this.message,
    );
  }
}
