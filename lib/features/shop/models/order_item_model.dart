import 'dart:convert';

class OrderItemModel {
  final String productId; // Maps to _idProduct
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // Convert OrderItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  // Create OrderItemModel from JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['_idProduct']?.toString() ?? json['productId']?.toString() ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  // Static empty method
  static OrderItemModel empty() => OrderItemModel(
        productId: '',
        name: '',
        quantity: 1,
        price: 0.0,
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static OrderItemModel fromJsonString(String jsonString) {
    try {
      return OrderItemModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}