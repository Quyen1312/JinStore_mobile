// refresh_token_model.dart

class RefreshToken {
  final String id; // Từ _id của Mongoose
  final String userId; // Từ 'userId' (ObjectId) của backend
  final String token; // Giá trị của refresh token
  final DateTime createdAt; // Thời điểm token được tạo

  RefreshToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) {
    // Kiểm tra các trường bắt buộc dựa trên schema backend
    if (!json.containsKey('_id')) {
      throw ArgumentError("JSON cho RefreshToken phải chứa '_id'");
    }
    if (!json.containsKey('userId')) {
      throw ArgumentError("JSON cho RefreshToken phải chứa 'userId'");
    }
    if (!json.containsKey('token')) {
      throw ArgumentError("JSON cho RefreshToken phải chứa 'token'");
    }
    if (!json.containsKey('createdAt')) {
      throw ArgumentError("JSON cho RefreshToken phải chứa 'createdAt'");
    }

    String? parsedUserId;
    if (json['userId'] is String) {
      parsedUserId = json['userId'] as String;
    } else if (json['userId'] is Map<String, dynamic> &&
        (json['userId'] as Map<String, dynamic>).containsKey('_id')) {
      // Nếu backend populate 'userId' thành object User, lấy _id từ đó
      parsedUserId =
          (json['userId'] as Map<String, dynamic>)['_id'] as String?;
    }
    if (parsedUserId == null) {
      throw ArgumentError("Không thể parse 'userId' từ JSON cho RefreshToken");
    }

    return RefreshToken(
      id: json['_id'] as String,
      userId: parsedUserId,
      token: json['token'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Model này chủ yếu dùng để đọc dữ liệu từ backend khi cần (ví dụ: admin xem token).
    // Việc tạo mới RefreshToken thường được xử lý hoàn toàn ở backend.
    return {
      '_id': id,
      'userId': userId,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RefreshToken copyWith({
    String? id,
    String? userId,
    String? token,
    DateTime? createdAt,
  }) {
    return RefreshToken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
