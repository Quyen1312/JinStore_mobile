class RefreshToken {
  final String id;
  final String userId;
  final String token;
  final bool isRevoked;
  final DateTime expiresAt;
  final String? deviceInfo;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  RefreshToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.isRevoked,
    required this.expiresAt,
    this.deviceInfo,
    this.ipAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) {
    return RefreshToken(
      id: json['_id'],
      userId: json['userId'],
      token: json['token'],
      isRevoked: json['isRevoked'],
      expiresAt: DateTime.parse(json['expiresAt']),
      deviceInfo: json['deviceInfo'],
      ipAddress: json['ipAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'token': token,
      'isRevoked': isRevoked,
      'expiresAt': expiresAt.toIso8601String(),
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RefreshToken copyWith({
    String? id,
    String? userId,
    String? token,
    bool? isRevoked,
    DateTime? expiresAt,
    String? deviceInfo,
    String? ipAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RefreshToken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isRevoked: isRevoked ?? this.isRevoked,
      expiresAt: expiresAt ?? this.expiresAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid {
    return !isRevoked && DateTime.now().isBefore(expiresAt);
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }
} 