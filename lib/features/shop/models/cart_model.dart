class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double? discount;
  final String image;
  final int stock;
  final String unit;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.discount,
    required this.image,
    required this.stock,
    required this.unit,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      discount: json['discount']?.toDouble(),
      image: json['image'],
      stock: json['stock'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'image': image,
      'stock': stock,
      'unit': unit,
    };
  }

  double get total {
    if (discount != null && discount! > 0) {
      return (price - (price * discount! / 100)) * quantity;
    }
    return price * quantity;
  }

  CartItem copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    double? discount,
    String? image,
    int? stock,
    String? unit,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
    );
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Cart copyWith({
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 