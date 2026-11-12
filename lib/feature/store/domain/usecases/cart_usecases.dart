import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/domain/repositories/store_repository.dart';

class CartUseCases {
  final StoreRepository _repository;

  CartUseCases(this._repository);

  Future<List<CartItem>> getItems() => _repository.getCartItems();

  Future<List<CartItem>> getCachedItems() =>
      _repository.getCachedCartItems();

  Future<List<CartItem>> add(int productId, int quantity) {
    return _repository.addToCart(productId, quantity);
  }

  Future<List<CartItem>> remove(int productId) {
    return _repository.removeCartItem(productId);
  }
}
