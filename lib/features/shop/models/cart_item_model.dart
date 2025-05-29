import 'dart:convert';

class CartItemModel {
  final String productId; // Maps to _idProduct
  late final int quantity;

  CartItemModel({
    required this.productId,
    this.quantity = 1,
  });

  // Convert CartItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  // Create CartItemModel from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['_idProduct']?.toString() ?? json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  // Static empty method
  static CartItemModel empty() => CartItemModel(productId: '');

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static CartItemModel fromJsonString(String jsonString) {
    try {
      return CartItemModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}