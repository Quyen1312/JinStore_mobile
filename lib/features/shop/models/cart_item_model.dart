import 'dart:convert';

class CartItemModel {
  final String productId; // Ánh xạ tới _idProduct trong Mongoose
  late final int quantity;

  CartItemModel({
    required this.productId,
    this.quantity = 1,
  });

  // Chuyển đổi CartItemModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_idProduct': productId, // Đã thay đổi 'productId' thành '_idProduct' để khớp với schema
      'quantity': quantity,
    };
  }

  // Tạo CartItemModel từ JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      // Ưu tiên '_idProduct', sau đó là 'productId' để tương thích
      productId: json['_idProduct']?.toString() ?? json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 1, // Mặc định là 1 nếu không có
    );
  }

  // Phương thức tĩnh để tạo một đối tượng trống
  static CartItemModel empty() => CartItemModel(productId: '');

  // Chuyển đổi thành chuỗi JSON
  String toJsonString() => jsonEncode(toJson());

  // Tạo từ chuỗi JSON
  static CartItemModel fromJsonString(String jsonString) {
    try {
      return CartItemModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      // Xử lý lỗi nếu chuỗi JSON không hợp lệ
      throw FormatException('Chuỗi JSON không hợp lệ: $e');
    }
  }
}
