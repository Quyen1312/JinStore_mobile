    // File: lib/features/shop/models/review_model.dart
    import 'package:flutter_application_jin/features/authentication/models/user_nested_model.dart'; // Đường dẫn đúng

    class ReviewModel {
      final String id; // Backend sẽ tự tạo _id cho review, nhưng không thấy trong populate select
      final double rating;
      final String comment;
      final UserNestedModel? user; // User được populate
      final DateTime? createdAt;

      ReviewModel({
        required this.id,
        required this.rating,
        required this.comment,
        this.user,
        this.createdAt,
      });

      factory ReviewModel.fromJson(Map<String, dynamic> json) {
        return ReviewModel(
          // Backend API getProductByIdCategory -> select cho review không có '_id' của review
          // Chúng ta sẽ cần ID của review nếu muốn cập nhật/xóa. 
          // Nếu API trả về _id cho review, hãy dùng json['_id']
          id: json['_id'] as String? ?? '', // Giả sử review có _id riêng
          rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
          comment: json['comment'] as String? ?? '',
          user: json['user'] != null && json['user'] is Map<String, dynamic>
              ? UserNestedModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
          createdAt: json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
        );
      }

      Map<String, dynamic> toJson() {
        // Dùng khi tạo/cập nhật review
        return {
          // 'id': id, // Không gửi id khi tạo mới
          'rating': rating,
          'comment': comment,
          // 'userId': user?.id, // Backend sẽ lấy userId từ token khi tạo review
          // 'productId': productId, // Cần productId khi tạo review, sẽ được truyền riêng
        };
      }
    }
    