import 'dart:convert';
import 'cart_item_model.dart';

class CartModel {
  final String id; // Maps to _id of the cart document
  final String userId; // Maps to _idUser
  final List<CartItemModel> items;
  final DateTime? createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.createdAt,
    required this.updatedAt,
  });

  // Convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create CartModel from JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['_idUser']?.toString() ?? json['userId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Static empty method
  static CartModel empty() => CartModel(
        id: '',
        userId: '',
        updatedAt: DateTime.now(),
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static CartModel fromJsonString(String jsonString) {
    try {
      return CartModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}