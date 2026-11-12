import 'dart:convert';

import 'package:clean_arch_session/core/cache/cart_cache.dart';
import 'package:clean_arch_session/core/networking/api_constants.dart';
import 'package:clean_arch_session/core/networking/api_service.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/domain/repositories/store_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreRepositoryImpl implements StoreRepository {
  final ApiService _api;

  StoreRepositoryImpl(this._api);

  @override
  Future<List<StoreCategory>> getCategories() async {
    final response = await _api.get(ApiConstants.categories);
    return _asMapList(_data(response.data)).map(_categoryFromJson).toList();
  }

  @override
  Future<List<StoreProduct>> getProducts({String? categorySlug}) async {
    final response = await _api.get(ApiConstants.products);
    final products = _asMapList(
      _data(response.data),
    ).map(_productFromJson).toList();
    if (categorySlug == null) return products;
    return products
        .where((product) => product.categorySlug == categorySlug)
        .toList();
  }

  @override
  Future<StoreProduct> getProductDetails(String slug) async {
    final response = await _api.get(ApiConstants.productDetails(slug));
    return _productFromJson(_asMap(_data(response.data)));
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final response = await _api.get(ApiConstants.favorites);
    return _asMapList(_data(response.data))
        .map(
          (json) => FavoriteItem(
            id: _asInt(json['id']),
            product: _productFromJson(_asMap(json['product'])),
          ),
        )
        .toList();
  }

  @override
  Future<void> addFavorite(int productId) async {
    await _api.post(
      ApiConstants.favoriteStore,
      data: {'product_id': productId},
    );
  }

  @override
  Future<void> removeFavorite(int productId) async {
    await _api.post(
      ApiConstants.favoriteDestroy,
      data: {'product_id': productId},
    );
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    final response = await _api.get(ApiConstants.cart);
    final rawItems = _asMapList(_data(response.data));
    final items = rawItems.map(_cartItemFromJson).toList();
    await CartCache.save(jsonEncode(rawItems));
    return items;
  }

  @override
  Future<List<CartItem>> getCachedCartItems() async {
    final cached = await CartCache.read();
    if (cached == null || cached.isEmpty) return const [];
    final decoded = jsonDecode(cached);
    if (decoded is! List) {
      throw const FormatException('Cached cart data is not a list.');
    }
    return _asMapList(decoded).map(_cartItemFromJson).toList();
  }

  @override
  Future<List<CartItem>> addToCart(int productId, int quantity) async {
    await _api.post(
      ApiConstants.cartStore,
      data: {'product_id': productId, 'quantity': quantity},
    );
    return getCartItems();
  }

  @override
  Future<List<CartItem>> removeCartItem(int productId) async {
    await _api.post(ApiConstants.cartDestroy, data: {'product_id': productId});
    return getCartItems();
  }

  @override
  Future<StoreOrder> placeOrder({
    required List<CartItem> items,
    required String address,
    required double? latitude,
    required double? longitude,
    required String paymentMethod,
  }) async {
    final response = await _api.post(
      ApiConstants.orderStore,
      data: {
        'product_id': items.map((item) => item.product.id).toList(),
        'quantity': items.map((item) => item.quantity).toList(),
        'price': items.map((item) => item.product.price).toList(),
        'address': address,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'payment_method': paymentMethod,
      },
    );
    return _orderFromJson(_asMap(_data(response.data)));
  }

  @override
  Future<List<StoreOrder>> getOrders() async {
    final response = await _api.get(ApiConstants.orders);
    return _asMapList(_data(response.data)).map(_orderFromJson).toList();
  }

  @override
  Future<StoreOrder> getOrder(String code) async {
    final response = await _api.get(ApiConstants.orderDetails(code));
    return _orderFromJson(_asMap(_data(response.data)));
  }

  @override
  Future<String> payOrder(String code) async {
    final paymentResponse = await _api.post(ApiConstants.orderPayment(code));
    final paymentData = _asMap(_data(paymentResponse.data));
    if (paymentData.isEmpty) {
      throw const FormatException(
        'Payment setup response did not contain data.',
      );
    }

    final processResponse = await _api.post(
      ApiConstants.paymentsProcess,
      data: paymentData,
    );
    final url = _asMap(_data(processResponse.data))['url'];
    if (url is! String || url.isEmpty) {
      throw const FormatException('Payment response did not contain a URL.');
    }
    final paymentUri = Uri.tryParse(url);
    if (paymentUri == null ||
        !paymentUri.hasScheme ||
        paymentUri.host.isEmpty) {
      throw const FormatException('Payment response contained an invalid URL.');
    }
    if (!await launchUrl(paymentUri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open the payment gateway.');
    }
    return url;
  }

  StoreCategory _categoryFromJson(Map<String, dynamic> json) => StoreCategory(
    id: _asInt(json['id']),
    name: json['name']?.toString() ?? '',
    slug: json['slug']?.toString() ?? '',
    description: json['description']?.toString(),
  );

  StoreProduct _productFromJson(Map<String, dynamic> json) {
    final category = _asOptionalMap(json['category']);
    final admin = _asOptionalMap(json['admin']);
    final publisher = admin.isEmpty
        ? null
        : StorePublisher(
            name: admin['name']?.toString() ?? '',
            businessName: admin['business_name']?.toString(),
            pictureUrl: admin['picture_url']?.toString(),
          );
    return StoreProduct(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _asDouble(json['price']),
      quantity: _asInt(json['quantity']),
      image: (json['image_url'] ?? json['image'])?.toString(),
      categoryId: _asNullableInt(json['category_id'] ?? category['id']),
      categoryName: category['name']?.toString(),
      categorySlug: category['slug']?.toString(),
      publisher: publisher,
    );
  }

  CartItem _cartItemFromJson(Map<String, dynamic> json) => CartItem(
    quantity: _asInt(json['quantity']),
    product: _productFromJson(_asMap(json['product'])),
  );

  StoreOrder _orderFromJson(Map<String, dynamic> json) => StoreOrder(
    id: _asInt(json['id']),
    code: json['code']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    totalPrice: _asDouble(json['total_price']),
    address: json['address']?.toString() ?? '',
    paymentMethod: json['payment_method']?.toString() ?? '',
    items: _asMapList(json['order_items'])
        .map(
          (item) => StoreOrderItem(
            quantity: _asInt(item['quantity']),
            price: _asDouble(item['price']),
            totalPrice: _asDouble(item['total_price']),
            product: _productFromJson(_asMap(item['product'])),
          ),
        )
        .toList(),
    createdAt: json['created_at']?.toString() ?? '',
  );
}

dynamic _data(dynamic response) {
  if (response is! Map || !response.containsKey('data')) {
    throw const FormatException('API response is missing its data field.');
  }
  return response['data'];
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(dynamic value) =>
    value == null ? null : int.tryParse(value.toString());

double _asDouble(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) {
    throw const FormatException('API response data is not a list.');
  }
  return value.map((item) {
    if (item is! Map) {
      throw const FormatException('API response list contains invalid data.');
    }
    return Map<String, dynamic>.from(item);
  }).toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) {
    throw const FormatException('API response data is not an object.');
  }
  return Map<String, dynamic>.from(value);
}

Map<String, dynamic> _asOptionalMap(dynamic value) {
  if (value == null) return const {};
  return _asMap(value);
}
