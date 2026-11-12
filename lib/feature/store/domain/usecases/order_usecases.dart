import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/domain/repositories/store_repository.dart';

class OrderUseCases {
  final StoreRepository _repository;

  OrderUseCases(this._repository);

  Future<StoreOrder> place({
    required List<CartItem> items,
    required String address,
    required double? latitude,
    required double? longitude,
    required String paymentMethod,
  }) {
    return _repository.placeOrder(
      items: items,
      address: address,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: paymentMethod,
    );
  }

  Future<List<StoreOrder>> getOrders() => _repository.getOrders();

  Future<StoreOrder> getOrder(String code) => _repository.getOrder(code);

  Future<String> pay(String code) => _repository.payOrder(code);
}
