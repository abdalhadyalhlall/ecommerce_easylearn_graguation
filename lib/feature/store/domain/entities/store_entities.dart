class StoreCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;

  const StoreCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });
}

class StorePublisher {
  final String name;
  final String? businessName;
  final String? pictureUrl;

  const StorePublisher({
    required this.name,
    this.businessName,
    this.pictureUrl,
  });

  String get displayName =>
      businessName?.trim().isNotEmpty == true ? businessName! : name;
}

class StoreProduct {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int quantity;
  final String? image;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final StorePublisher? publisher;

  const StoreProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.quantity,
    this.image,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.publisher,
  });

  bool get isInStock => quantity > 0;
}

class CartItem {
  final int quantity;
  final StoreProduct product;

  const CartItem({required this.quantity, required this.product});

  double get subtotal => product.price * quantity;
}

class FavoriteItem {
  final int id;
  final StoreProduct product;

  const FavoriteItem({required this.id, required this.product});
}

class StoreOrderItem {
  final int quantity;
  final double price;
  final double totalPrice;
  final StoreProduct product;

  const StoreOrderItem({
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.product,
  });
}

class StoreOrder {
  final int id;
  final String code;
  final String status;
  final double totalPrice;
  final String address;
  final String paymentMethod;
  final List<StoreOrderItem> items;
  final String createdAt;

  const StoreOrder({
    required this.id,
    required this.code,
    required this.status,
    required this.totalPrice,
    required this.address,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
  });
}

class StoreProductPage {
  final List<StoreProduct> products;
  final int currentPage;
  final int lastPage;

  const StoreProductPage({
    required this.products,
    this.currentPage = 1,
    this.lastPage = 1,
  });
}
