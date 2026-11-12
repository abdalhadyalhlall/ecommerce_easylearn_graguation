import 'package:clean_arch_session/core/cache/profile_cache.dart';
import 'package:clean_arch_session/core/networking/api_error_handler.dart';
import 'package:clean_arch_session/feature/profile/domain/usecases/get_profile_usecase.dart';
import 'package:clean_arch_session/feature/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  ProfileCubit(this._getProfile, this._updateProfile)
    : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true, clearFeedback: true));
    try {
      final cachedProfile = await _getProfile.getCached();
      if (cachedProfile != null) {
        emit(state.copyWith(profile: cachedProfile));
      }
    } on FormatException catch (error) {
      debugPrint('Discarding invalid cached profile: $error');
      await ProfileCache.clear();
    }

    try {
      final profile = await _getProfile();
      emit(state.copyWith(profile: profile, loading: false));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String? address,
    required double? latitude,
    required double? longitude,
    Uint8List? pictureBytes,
    String? pictureFileName,
  }) async {
    emit(state.copyWith(saving: true, clearFeedback: true));
    try {
      final profile = await _updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        pictureBytes: pictureBytes,
        pictureFileName: pictureFileName,
      );
      emit(
        state.copyWith(
          profile: profile,
          saving: false,
          message: 'تم حفظ الملف الشخصي بنجاح',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  void clearFeedback() => emit(state.copyWith(clearFeedback: true));
}
