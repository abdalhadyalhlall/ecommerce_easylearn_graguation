import 'package:clean_arch_session/core/cache/cache_const.dart';
import 'package:clean_arch_session/core/cache/cache_helper.dart';

class ProfileCache {
  static Future<void> save(String encodedProfile) {
    return CacheHelper.saveSecureData(
      key: CacheConstants.clientProfile,
      value: encodedProfile,
    );
  }

  static Future<String?> read() {
    return CacheHelper.getSecureData(key: CacheConstants.clientProfile);
  }

  static Future<void> clear() {
    return CacheHelper.deleteSecureData(key: CacheConstants.clientProfile);
  }
}
