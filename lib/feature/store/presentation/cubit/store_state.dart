import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';

class StoreState {
  final List<StoreCategory> categories;
  final List<StoreProduct> products;
  final int catalogRevision;
  final List<CartItem> cartItems;
  final List<FavoriteItem> favorites;
  final List<StoreOrder> orders;
  final String? selectedCategorySlug;
  final StoreProduct? selectedProduct;
  final bool loadingCategories;
  final bool loadingProducts;
  final bool loadingFavorites;
  final bool loadingCart;
  final bool loadingOrders;
  final bool busy;
  final String? paymentUrl;
  final String? error;
  final String? message;

  const StoreState({
    this.categories = const [],
    this.products = const [],
    this.catalogRevision = 0,
    this.cartItems = const [],
    this.favorites = const [],
    this.orders = const [],
    this.selectedCategorySlug,
    this.selectedProduct,
    this.loadingCategories = false,
    this.loadingProducts = false,
    this.loadingFavorites = false,
    this.loadingCart = false,
    this.loadingOrders = false,
    this.busy = false,
    this.paymentUrl,
    this.error,
    this.message,
  });

  double get cartTotal =>
      cartItems.fold(0, (total, item) => total + item.subtotal);

  bool isFavorite(int productId) =>
      favorites.any((favorite) => favorite.product.id == productId);

  StoreState copyWith({
    List<StoreCategory>? categories,
    List<StoreProduct>? products,
    int? catalogRevision,
    List<CartItem>? cartItems,
    List<FavoriteItem>? favorites,
    List<StoreOrder>? orders,
    String? selectedCategorySlug,
    bool clearSelectedCategory = false,
    StoreProduct? selectedProduct,
    bool clearSelectedProduct = false,
    bool? loadingCategories,
    bool? loadingProducts,
    bool? loadingFavorites,
    bool? loadingCart,
    bool? loadingOrders,
    bool? busy,
    String? paymentUrl,
    bool clearPaymentUrl = false,
    String? error,
    String? message,
    bool clearFeedback = false,
  }) {
    return StoreState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      catalogRevision: catalogRevision ?? this.catalogRevision,
      cartItems: cartItems ?? this.cartItems,
      favorites: favorites ?? this.favorites,
      orders: orders ?? this.orders,
      selectedCategorySlug: clearSelectedCategory
          ? null
          : selectedCategorySlug ?? this.selectedCategorySlug,
      selectedProduct: clearSelectedProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      loadingProducts: loadingProducts ?? this.loadingProducts,
      loadingFavorites: loadingFavorites ?? this.loadingFavorites,
      loadingCart: loadingCart ?? this.loadingCart,
      loadingOrders: loadingOrders ?? this.loadingOrders,
      busy: busy ?? this.busy,
      paymentUrl: clearPaymentUrl ? null : paymentUrl ?? this.paymentUrl,
      error: clearFeedback ? null : error ?? this.error,
      message: clearFeedback ? null : message ?? this.message,
    );
  }
}
