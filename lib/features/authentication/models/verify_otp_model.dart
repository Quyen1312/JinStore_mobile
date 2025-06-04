// verify_otp_model.dart

class VerifyOTP {
  final String id; // Từ _id của Mongoose
  final String userId; // Từ 'user' (ObjectId) của backend
  final String? otp; // Mã OTP, có thể null
  final DateTime? otpExpires; // Thời gian hết hạn OTP, có thể null
  final bool isEmailVerified;
  final bool isPhoneVerified;

  VerifyOTP({
    required this.id,
    required this.userId,
    this.otp,
    this.otpExpires,
    required this.isEmailVerified,
    required this.isPhoneVerified,
  });

  factory VerifyOTP.fromJson(Map<String, dynamic> json) {
    // Kiểm tra các trường bắt buộc dựa trên schema backend
    if (!json.containsKey('_id')) {
      throw ArgumentError("JSON cho VerifyOTP phải chứa '_id'");
    }
    // Backend dùng 'user' cho userId
    if (!json.containsKey('user')) {
      throw ArgumentError("JSON cho VerifyOTP phải chứa 'user' (là userId)");
    }
    // isEmailVerified và isPhoneVerified có default ở backend

    String? parsedUserId;
    if (json['user'] is String) {
      parsedUserId = json['user'] as String;
    } else if (json['user'] is Map<String, dynamic> &&
        (json['user'] as Map<String, dynamic>).containsKey('_id')) {
      // Nếu backend populate 'user' thành object, lấy _id từ đó
      parsedUserId =
          (json['user'] as Map<String, dynamic>)['_id'] as String?;
    }
    if (parsedUserId == null) {
      throw ArgumentError("Không thể parse 'user' ID từ JSON cho VerifyOTP");
    }

    return VerifyOTP(
      id: json['_id'] as String,
      userId: parsedUserId,
      otp: json['otp'] as String?,
      otpExpires: json['otpExpires'] == null
          ? null
          : DateTime.tryParse(json['otpExpires'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    // Model này chủ yếu dùng để đọc dữ liệu từ backend.
    // Việc tạo mới/cập nhật VerifyOTP thường được xử lý bởi các endpoint cụ thể ở backend
    // và có thể không yêu cầu tất cả các trường này.
    // Tuy nhiên, nếu cần gửi lại đối tượng này, đây là cách serialize:
    return {
      '_id': id,
      'user': userId,
      'otp': otp,
      'otpExpires': otpExpires?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  VerifyOTP copyWith({
    String? id,
    String? userId,
    String? otp,
    DateTime? otpExpires,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return VerifyOTP(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      otp: otp ?? this.otp,
      otpExpires: otpExpires ?? this.otpExpires,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  // Getter isExpired có thể vẫn hữu ích nếu bạn giữ lại otpExpires
  bool get isOtpExpired {
    if (otpExpires == null) return false; // Hoặc true nếu OTP không có ngày hết hạn được coi là không hợp lệ
    return DateTime.now().isAfter(otpExpires!);
  }
}
