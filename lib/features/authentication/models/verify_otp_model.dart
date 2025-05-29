class VerifyOTPModel {
  final String id; // Maps to _id
  final String user; // Maps to user ID
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? otp; // Temporary OTP code
  final DateTime? otpExpires; // OTP expiration time

  VerifyOTPModel({
    required this.id,
    required this.user,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.otp,
    this.otpExpires,
  });

 
  // Create VerifyOTPModel from JSON
  factory VerifyOTPModel.fromJson(Map<String, dynamic> json) {
    return VerifyOTPModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      otp: json['otp'],
      otpExpires: json['otpExpires'] != null ? DateTime.parse(json['otpExpires']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      if (otp != null) 'otp': otp,
      if (otpExpires != null) 'otpExpires': otpExpires!.toIso8601String(),
    };
  }

}