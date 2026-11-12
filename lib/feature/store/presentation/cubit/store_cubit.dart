import 'package:clean_arch_session/core/cache/cart_cache.dart';
import 'package:clean_arch_session/core/networking/api_error_handler.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/domain/usecases/cart_usecases.dart';
import 'package:clean_arch_session/feature/store/domain/usecases/catalog_usecases.dart';
import 'package:clean_arch_session/feature/store/domain/usecases/favorite_usecases.dart';
import 'package:clean_arch_session/feature/store/domain/usecases/order_usecases.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreCubit extends Cubit<StoreState> {
  final CatalogUseCases _catalogUseCases;
  final CartUseCases _cartUseCases;
  final OrderUseCases _orderUseCases;
  final FavoriteUseCases _favoriteUseCases;
  int _catalogRequestId = 0;

  StoreCubit(
    this._catalogUseCases,
    this._cartUseCases,
    this._orderUseCases,
    this._favoriteUseCases,
  ) : super(const StoreState());

  Future<void> loadCategories() async {
    emit(state.copyWith(loadingCategories: true, clearFeedback: true));
    try {
      final categories = await _catalogUseCases.getCategories();
      emit(state.copyWith(categories: categories, loadingCategories: false));
    } catch (error) {
      emit(
        state.copyWith(
          loadingCategories: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<void> loadProducts({
    String? categorySlug,
    bool refresh = false,
  }) async {
    if (!refresh &&
        categorySlug == state.selectedCategorySlug &&
        state.products.isNotEmpty) {
      return;
    }
    final requestId = ++_catalogRequestId;
    emit(
      state.copyWith(
        loadingProducts: true,
        selectedCategorySlug: categorySlug,
        clearSelectedCategory: categorySlug == null,
        products: refresh ? state.products : const [],
        clearFeedback: true,
      ),
    );
    try {
      final products = await _catalogUseCases.getProducts(
        categorySlug: categorySlug,
      );
      if (requestId != _catalogRequestId) return;
      emit(
        state.copyWith(
          products: products,
          catalogRevision: state.catalogRevision + 1,
          loadingProducts: false,
        ),
      );
    } catch (error) {
      if (requestId != _catalogRequestId) return;
      emit(
        state.copyWith(
          loadingProducts: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<StoreProduct?> loadProductDetails(String slug) async {
    try {
      final product = await _catalogUseCases.getProductDetails(slug);
      emit(state.copyWith(selectedProduct: product));
      return product;
    } catch (error) {
      emit(state.copyWith(error: ApiErrorHandler.getMessage(error)));
      return null;
    }
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(loadingFavorites: true, clearFeedback: true));
    try {
      final favorites = await _favoriteUseCases.getItems();
      emit(state.copyWith(favorites: favorites, loadingFavorites: false));
    } catch (error) {
      emit(
        state.copyWith(
          loadingFavorites: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<void> toggleFavorite(StoreProduct product) async {
    final wasFavorite = state.isFavorite(product.id);
    await _runAction(() async {
      if (wasFavorite) {
        await _favoriteUseCases.remove(product.id);
      } else {
        await _favoriteUseCases.add(product.id);
      }
      final favorites = await _favoriteUseCases.getItems();
      emit(
        state.copyWith(
          favorites: favorites,
          message: wasFavorite
              ? 'تم حذف المنتج من المفضلة'
              : 'تمت إضافة المنتج إلى المفضلة',
        ),
      );
    });
  }

  Future<void> loadCart() async {
    emit(state.copyWith(loadingCart: true, clearFeedback: true));
    try {
      final cachedItems = await _cartUseCases.getCachedItems();
      emit(state.copyWith(cartItems: cachedItems));
      final items = await _cartUseCases.getItems();
      emit(state.copyWith(cartItems: items, loadingCart: false));
    } catch (error) {
      emit(
        state.copyWith(
          loadingCart: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<void> loadOrders() async {
    emit(state.copyWith(loadingOrders: true, clearFeedback: true));
    try {
      final orders = await _orderUseCases.getOrders();
      emit(state.copyWith(orders: orders, loadingOrders: false));
    } catch (error) {
      emit(
        state.copyWith(
          loadingOrders: false,
          error: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  Future<void> addToCart(StoreProduct product, {int quantity = 1}) async {
    if (!product.isInStock || quantity < 1 || quantity > product.quantity) {
      emit(
        state.copyWith(
          error: product.isInStock
              ? 'الكمية المطلوبة أكبر من المخزون المتاح'
              : 'هذا المنتج غير متوفر حالياً',
        ),
      );
      return;
    }
    await _runAction(() async {
      final items = await _cartUseCases.add(product.id, quantity);
      emit(
        state.copyWith(cartItems: items, message: 'تمت إضافة المنتج إلى السلة'),
      );
    });
  }

  Future<void> removeCartItem(CartItem item) async {
    await _runAction(() async {
      final items = await _cartUseCases.remove(item.product.id);
      emit(state.copyWith(cartItems: items, message: 'تم حذف المنتج من السلة'));
    });
  }

  Future<void> placeOrder({
    required String address,
    required double? latitude,
    required double? longitude,
    required String paymentMethod,
  }) async {
    if (state.cartItems.isEmpty) return;
    if (paymentMethod != 'cash' && paymentMethod != 'card') {
      emit(state.copyWith(error: 'طريقة الدفع غير مدعومة'));
      return;
    }
    await _runAction(() async {
      final order = await _orderUseCases.place(
        items: state.cartItems,
        address: address,
        latitude: latitude,
        longitude: longitude,
        paymentMethod: paymentMethod,
      );
      await CartCache.clear();
      emit(
        state.copyWith(
          cartItems: const [],
          orders: [
            order,
            ...state.orders.where((existing) => existing.code != order.code),
          ],
          message: paymentMethod == 'card'
              ? 'تم إنشاء الطلب، جارٍ فتح بوابة الدفع'
              : 'تم إنشاء الطلب ${order.code} بنجاح',
        ),
      );
      if (paymentMethod == 'card') {
        final url = await _orderUseCases.pay(order.code);
        emit(
          state.copyWith(
            paymentUrl: url,
            message: 'تم فتح بوابة الدفع للطلب ${order.code}',
          ),
        );
      }
      final orders = await _orderUseCases.getOrders();
      emit(state.copyWith(orders: orders));
    });
  }

  Future<StoreOrder?> loadOrderDetails(String code) async {
    try {
      return await _orderUseCases.getOrder(code);
    } catch (error) {
      emit(state.copyWith(error: ApiErrorHandler.getMessage(error)));
      return null;
    }
  }

  Future<void> payForOrder(StoreOrder order) async {
    await _runAction(() async {
      final url = await _orderUseCases.pay(order.code);
      emit(
        state.copyWith(
          paymentUrl: url,
          message: 'تم فتح بوابة الدفع للطلب ${order.code}',
        ),
      );
    });
  }

  Future<void> clearFeedback() async {
    emit(state.copyWith(clearFeedback: true, clearPaymentUrl: true));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    emit(state.copyWith(busy: true, clearFeedback: true));
    try {
      await action();
    } catch (error) {
      emit(state.copyWith(error: ApiErrorHandler.getMessage(error)));
    } finally {
      emit(state.copyWith(busy: false));
    }
  }
}
