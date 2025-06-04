// cart_model.dart

// Đại diện cho cấu trúc của một item trong mảng 'items' của Cart schema backend
class CartItemModel {
  final String productId; // Tương ứng với '_idProduct' từ backend
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Backend lưu productId dưới dạng '_idProduct'
    if (!json.containsKey('_idProduct')) {
      throw ArgumentError("JSON cho CartItemModel phải chứa '_idProduct'");
    }
    if (!json.containsKey('quantity')) {
      throw ArgumentError("JSON cho CartItemModel phải chứa 'quantity'");
    }
    return CartItemModel(
      productId: json['_idProduct'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_idProduct': productId,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? productId,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Đại diện cho cấu trúc của Cart schema backend
class CartModel {
  final String id; // Tương ứng với '_id' của document Cart
  final String userId; // Tương ứng với '_idUser'
  final List<CartItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('_id')) {
      throw ArgumentError("JSON cho CartModel phải chứa '_id'");
    }
    // Backend lưu userId dưới dạng '_idUser'
    if (!json.containsKey('_idUser')) {
      throw ArgumentError("JSON cho CartModel phải chứa '_idUser'");
    }
    if (!json.containsKey('items')) {
      throw ArgumentError("JSON cho CartModel phải chứa 'items'");
    }
    if (!json.containsKey('createdAt')) {
      throw ArgumentError("JSON cho CartModel phải chứa 'createdAt'");
    }
    if (!json.containsKey('updatedAt')) {
      throw ArgumentError("JSON cho CartModel phải chứa 'updatedAt'");
    }

    var itemsList = <CartItemModel>[];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((itemJson) =>
              CartItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      id: json['_id'] as String,
      userId: json['_idUser'] as String,
      items: itemsList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      '_idUser': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
