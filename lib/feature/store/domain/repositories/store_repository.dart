import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';

abstract interface class StoreRepository {
  Future<List<StoreCategory>> getCategories();

  Future<List<StoreProduct>> getProducts({String? categorySlug});

  Future<StoreProduct> getProductDetails(String slug);

  Future<List<FavoriteItem>> getFavorites();

  Future<void> addFavorite(int productId);

  Future<void> removeFavorite(int productId);

  Future<List<CartItem>> getCartItems();

  Future<List<CartItem>> getCachedCartItems();

  Future<List<CartItem>> addToCart(int productId, int quantity);

  Future<List<CartItem>> removeCartItem(int productId);

  Future<StoreOrder> placeOrder({
    required List<CartItem> items,
    required String address,
    required double? latitude,
    required double? longitude,
    required String paymentMethod,
  });

  Future<List<StoreOrder>> getOrders();

  Future<StoreOrder> getOrder(String code);

  Future<String> payOrder(String code);
}
