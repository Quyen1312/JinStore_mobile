// File: lib/features/shop/models/cart_item_model.dart
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Để chứa thông tin sản phẩm

class CartItemModel {
  final String cartItemId; // ID của mục trong giỏ hàng (nếu backend trả về)
  final String productId;
  final String name;
  final String? imageUrl; // Lấy từ ảnh đầu tiên của sản phẩm
  final double price; // Giá của một đơn vị sản phẩm tại thời điểm thêm vào giỏ (có thể đã áp dụng khuyến mãi)
  final int quantity;
  final String? unit; // Đơn vị tính của sản phẩm
  // Thêm các thuộc tính biến thể nếu sản phẩm có (ví dụ: color, size)
  // final String? variationId;
  // final Map<String, String>? selectedAttributes; 

  CartItemModel({
    required this.cartItemId, // Có thể là productId nếu backend không có cartItemId riêng
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.unit,
    // this.variationId,
    // this.selectedAttributes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Backend API /api/carts/ trả về danh sách các item.
    // Mỗi item có thể chứa một object 'product' đã được populate.
    final productData = json['product'] as Map<String, dynamic>?;
    String? mainImageUrl;
    if (productData != null && productData['images'] != null && (productData['images'] as List).isNotEmpty) {
      mainImageUrl = (productData['images'][0] as Map<String, dynamic>?)?['url'] as String?;
    }

    return CartItemModel(
      // Backend có thể trả về _id cho cart item, hoặc dùng productId làm key
      cartItemId: json['_id']?.toString() ?? productData?['_id']?.toString() ?? '', 
      productId: productData?['_id']?.toString() ?? json['productId']?.toString() ?? '',
      name: productData?['name'] as String? ?? json['name'] as String? ?? 'Unknown Product',
      imageUrl: mainImageUrl ?? json['imageUrl'] as String?,
      // Giá trong cart item thường là giá tại thời điểm mua (priceAtPurchase)
      // Hoặc nếu không có, thì lấy giá hiện tại của sản phẩm (cần cẩn thận nếu giá thay đổi)
      price: (json['priceAtPurchase'] as num?)?.toDouble() ?? (productData?['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: productData?['unit'] as String? ?? json['unit'] as String?,
      // Parse các thuộc tính biến thể nếu có
    );
  }

  // toJson không cần thiết nếu client không gửi trực tiếp CartItemModel khi tạo/cập nhật cart
  // mà chỉ gửi productId và quantity.
}
