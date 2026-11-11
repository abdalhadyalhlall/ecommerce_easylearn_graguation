class StoreCategory {
  final int id;
  final String uuid;
  final String name;
  final String slug;

  const StoreCategory({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
  });
}

class StoreProduct {
  final int id;
  final String uuid;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String? categoryName;

  const StoreProduct({
    required this.id,
    required this.uuid,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    this.categoryName,
  });
}

class CartItem {
  final String uuid;
  final int quantity;
  final StoreProduct product;
  final double subtotal;

  const CartItem({
    required this.uuid,
    required this.quantity,
    required this.product,
    required this.subtotal,
  });
}

class StoreOrderItem {
  final String uuid;
  final int quantity;
  final double price;
  final double subtotal;
  final StoreProduct product;

  const StoreOrderItem({
    required this.uuid,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.product,
  });
}

class StoreOrder {
  final String uuid;
  final String status;
  final double totalPrice;
  final List<StoreOrderItem> items;
  final String createdAt;

  const StoreOrder({
    required this.uuid,
    required this.status,
    required this.totalPrice,
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
    required this.currentPage,
    required this.lastPage,
  });
}
