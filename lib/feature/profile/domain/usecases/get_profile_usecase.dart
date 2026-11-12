import 'package:clean_arch_session/feature/profile/domain/entities/client_profile.dart';
import 'package:clean_arch_session/feature/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<ClientProfile> call() => _repository.getProfile();

  Future<ClientProfile?> getCached() => _repository.getCachedProfile();
}
