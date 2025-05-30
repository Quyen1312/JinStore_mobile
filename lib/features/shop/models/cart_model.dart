// File: lib/features/shop/models/cart_model.dart
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart';

class CartModel {
  final String id; // ID của giỏ hàng (từ _id của MongoDB)
  final String userId;
  final List<CartItemModel> items;
  final double totalPrice;    // Tổng tiền của tất cả sản phẩm trong giỏ
  final int totalQuantity; // Tổng số lượng của tất cả các mặt hàng

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.totalQuantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? (json['_idUser']?.toString() ?? ''), // Backend có thể dùng _idUser
      items: (json['items'] as List<dynamic>?)
              ?.map((itemJson) => CartItemModel.fromJson(itemJson as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0, // Backend API /api/carts/ cần trả về trường này
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0, // Backend API /api/carts/ cần trả về trường này
    );
  }

  // Phương thức empty để tạo một giỏ hàng rỗng
  static CartModel empty() => CartModel(
        id: '',
        userId: '',
        items: [],
        totalPrice: 0.0,
        totalQuantity: 0,
      );
}
