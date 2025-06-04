// review_model.dart

class Review {
  final String id; // Từ _id của Mongoose
  final String? userId; // Từ 'user' (ObjectId), có thể null
  final String productId; // Từ 'product' (ObjectId)
  final int rating; // number 1-5
  final String? comment; // Có thể null hoặc rỗng
  final bool isReport; // Thêm mới, default: false ở backend
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    this.userId, // Nullable
    required this.productId,
    required this.rating,
    this.comment, // Nullable
    required this.isReport,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Kiểm tra các trường bắt buộc dựa trên schema backend
    if (!json.containsKey('_id')) {
      throw ArgumentError("JSON cho Review phải chứa '_id'");
    }
    // 'user' có thể không có hoặc null nếu backend không populate hoặc review ẩn danh
    if (!json.containsKey('product')) {
      throw ArgumentError("JSON cho Review phải chứa 'product' (là productId)");
    }
    if (!json.containsKey('rating')) {
      throw ArgumentError("JSON cho Review phải chứa 'rating'");
    }
    // 'comment' là tùy chọn
    // 'isReport' có default ở backend

    if (!json.containsKey('createdAt')) {
      throw ArgumentError("JSON cho Review phải chứa 'createdAt'");
    }
    if (!json.containsKey('updatedAt')) {
      throw ArgumentError("JSON cho Review phải chứa 'updatedAt'");
    }
    
    String? parsedUserId;
    if (json['user'] != null) {
      if (json['user'] is String) {
        parsedUserId = json['user'] as String;
      } else if (json['user'] is Map<String, dynamic> && (json['user'] as Map<String, dynamic>).containsKey('_id')) {
        // Nếu backend populate 'user' thành object, lấy _id từ đó
        parsedUserId = (json['user'] as Map<String, dynamic>)['_id'] as String?;
      }
    }

    String? parsedProductId;
    if (json['product'] is String) {
        parsedProductId = json['product'] as String;
    } else if (json['product'] is Map<String, dynamic> && (json['product'] as Map<String, dynamic>).containsKey('_id')) {
        // Nếu backend populate 'product' thành object, lấy _id từ đó
        parsedProductId = (json['product'] as Map<String, dynamic>)['_id'] as String?;
    }
    if (parsedProductId == null) {
        throw ArgumentError("Không thể parse 'product' ID từ JSON cho Review");
    }


    return Review(
      id: json['_id'] as String,
      userId: parsedUserId,
      productId: parsedProductId,
      rating: (json['rating'] as num).toInt(), // Đảm bảo là int
      comment: json['comment'] as String?,
      isReport: json['isReport'] as bool? ?? false, // Sử dụng default từ schema nếu null
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId, // Gửi lại userId, backend sẽ hiểu đây là ObjectId
      'product': productId, // Gửi lại productId
      'rating': rating,
      'comment': comment,
      'isReport': isReport,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? productId,
    int? rating,
    String? comment,
    bool? isReport,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isReport: isReport ?? this.isReport,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
