class VerifyOTP {
  final String email;
  final String otp;
  final DateTime? expiresAt;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  VerifyOTP({
    required this.email,
    required this.otp,
    this.expiresAt,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerifyOTP.fromJson(Map<String, dynamic> json) {
    return VerifyOTP(
      email: json['email'],
      otp: json['otp'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isVerified: json['isVerified'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'expiresAt': expiresAt?.toIso8601String(),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  VerifyOTP copyWith({
    String? email,
    String? otp,
    DateTime? expiresAt,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerifyOTP(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      expiresAt: expiresAt ?? this.expiresAt,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
} 