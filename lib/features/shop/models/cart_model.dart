import 'dart:convert';
import 'cart_item_model.dart'; // Đảm bảo import CartItemModel

class CartModel {
  final String id; // Ánh xạ tới _id của tài liệu giỏ hàng trong Mongoose
  final String userId; // Ánh xạ tới _idUser trong Mongoose
  final List<CartItemModel> items;
  final DateTime? createdAt; // Có thể null vì Mongoose tự động quản lý
  final DateTime updatedAt; // Mongoose tự động quản lý khi có timestamps: true

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [], // Mặc định là danh sách rỗng
    this.createdAt,
    required this.updatedAt,
  });

  // Chuyển đổi CartModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_idUser': userId, // Đã thay đổi 'userId' thành '_idUser' để khớp với schema Mongoose
      'items': items.map((item) => item.toJson()).toList(),
    };

    // Ghi chú về '_id': '_id' của giỏ hàng (trường 'id' trong Dart model)
    // thường được tạo bởi MongoDB. Khi cập nhật giỏ hàng, ID này thường được
    // truyền dưới dạng tham số URL thay vì trong phần thân yêu cầu.
    // Nếu API backend của bạn yêu cầu '_id' của giỏ hàng trong phần thân để cập nhật,
    // bạn có thể thêm dòng sau:
    // if (id.isNotEmpty) { data['_id'] = id; }

    // Ghi chú về timestamps: 'createdAt' và 'updatedAt' thường được quản lý bởi
    // tùy chọn 'timestamps: true' của Mongoose ở phía máy chủ. Việc gửi các trường này
    // từ máy khách thường không cần thiết và có thể bị máy chủ ghi đè.
    // Nếu API của bạn yêu cầu rõ ràng, bạn có thể thêm chúng trở lại,
    // đảm bảo các khóa khớp với schema nếu cần. Ví dụ:
    // if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    // data['updatedAt'] = updatedAt.toIso8601String(); // Đảm bảo backend xử lý điều này một cách thích hợp

    return data;
  }

  // Tạo CartModel từ JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      // Ưu tiên '_id', sau đó là 'id' để tương thích
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      // Ưu tiên '_idUser', sau đó là 'userId' để tương thích
      userId: json['_idUser']?.toString() ?? json['userId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)) // Ép kiểu item sang Map<String, dynamic>
              .toList() ??
          [], // Mặc định là danh sách rỗng nếu 'items' null
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null, // Ép kiểu sang String trước khi parse
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()), // Xử lý null và ép kiểu
    );
  }

  // Phương thức tĩnh để tạo một đối tượng trống
  static CartModel empty() => CartModel(
        id: '',
        userId: '',
        updatedAt: DateTime.now(), // Cung cấp giá trị mặc định cho updatedAt
      );

  // Chuyển đổi thành chuỗi JSON
  String toJsonString() => jsonEncode(toJson());

  // Tạo từ chuỗi JSON
  static CartModel fromJsonString(String jsonString) {
    try {
      return CartModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      // Xử lý lỗi nếu chuỗi JSON không hợp lệ
      throw FormatException('Chuỗi JSON không hợp lệ: $e');
    }
  }
}
