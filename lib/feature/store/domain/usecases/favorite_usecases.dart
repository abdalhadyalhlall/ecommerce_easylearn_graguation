import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/domain/repositories/store_repository.dart';

class FavoriteUseCases {
  final StoreRepository _repository;

  FavoriteUseCases(this._repository);

  Future<List<FavoriteItem>> getItems() => _repository.getFavorites();

  Future<void> add(int productId) => _repository.addFavorite(productId);

  Future<void> remove(int productId) => _repository.removeFavorite(productId);
}
