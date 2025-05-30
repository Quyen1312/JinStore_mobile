// File: lib/features/shop/models/product_model.dart
import 'package:flutter_application_jin/features/shop/models/category_nested_model.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart';

// Giả định ImageModel và ProductInformation được định nghĩa ở đây hoặc import
class ImageModel {
  final String url;
  final String? publicId;

  ImageModel({required this.url, this.publicId});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
        'url': url,
        if (publicId != null) 'publicId': publicId,
      };
}

class ProductInformation {
  final String key;
  final String value;

  ProductInformation({required this.key, required this.value});

  factory ProductInformation.fromJson(Map<String, dynamic> json) {
    return ProductInformation(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}


class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double? discount; // Backend lưu là Number, có thể là 0
  final int quantity;
  final CategoryNestedModel? category; // Sẽ là object Category được populate
  final List<ImageModel> images;
  final List<ProductInformation> information;
  final List<ReviewModel>? reviews; // Sẽ là list ReviewModel được populate (từ getProductByIdCategory)
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // averageRating không có trong schema backend, có thể tính ở client hoặc backend thêm vào
  final double averageRating; // Giả sử tính toán ở client hoặc backend gửi

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    this.discount,
    required this.quantity,
    this.category,
    this.images = const [],
    this.information = const [],
    this.reviews,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var populatedCategory = json['_idCategory'] != null && json['_idCategory'] is Map<String, dynamic>
        ? CategoryNestedModel.fromJson(json['_idCategory'] as Map<String, dynamic>)
        : null;
    
    // Nếu _idCategory chỉ là String ID (trường hợp không populate sâu), bạn có thể muốn xử lý khác
    // nhưng dựa trên backend controller, nó sẽ luôn là object khi populate được gọi.
    if (json['_idCategory'] is String && populatedCategory == null) {
        // Xử lý trường hợp _idCategory là String ID (ví dụ: tạo CategoryNestedModel chỉ với ID)
        // populatedCategory = CategoryNestedModel(id: json['_idCategory'], name: 'Unknown');
        // Hoặc bạn có thể có một trường categoryId riêng: final String categoryId;
    }

    List<ReviewModel>? populatedReviews;
    if (json['_idReview'] != null && json['_idReview'] is List) {
      populatedReviews = (json['_idReview'] as List<dynamic>)
          .map((reviewData) => ReviewModel.fromJson(reviewData as Map<String, dynamic>))
          .toList();
    }
    
    // Tính averageRating nếu có reviews và API không trả về sẵn
    double calculatedAverageRating = 0.0;
    if (populatedReviews != null && populatedReviews.isNotEmpty) {
      calculatedAverageRating = populatedReviews.map((r) => r.rating).reduce((a, b) => a + b) / populatedReviews.length;
    } else if (json['averageRating'] != null) { // Nếu API có trả về averageRating
        calculatedAverageRating = (json['averageRating'] as num?)?.toDouble() ?? 0.0;
    }


    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      discount: (json['discount'] as num?)?.toDouble(), // Có thể là 0 hoặc null
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      category: populatedCategory,
      images: (json['images'] as List<dynamic>?)
              ?.map((imgJson) => ImageModel.fromJson(imgJson as Map<String, dynamic>))
              .toList() ??
          [],
      information: (json['information'] as List<dynamic>?)
              ?.map((infoJson) => ProductInformation.fromJson(infoJson as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: populatedReviews,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      averageRating: calculatedAverageRating,
    );
  }

  // toJson không cần thiết cho app user nếu chỉ fetch sản phẩm
}
