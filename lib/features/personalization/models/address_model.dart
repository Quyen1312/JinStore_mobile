class Address {
  final String id; // Từ _id của Mongoose
  final String userId; // Từ _idUser của Mongoose
  final String? detailed; // Địa chỉ cụ thể (số nhà, tên đường)
  final String? district; // Phường/Xã
  final String? city; // Quận/Huyện
  final String? province; // Tỉnh/Thành phố
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Thêm các field cho populated user data
  final String? userFullname;
  final String? userPhone;

  Address({
    required this.id,
    required this.userId,
    this.detailed,
    this.district,
    this.city,
    this.province,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.userFullname,
    this.userPhone,
  });

  // Helper method để extract userId từ _idUser field
  static String _extractUserId(dynamic userIdField) {
    if (userIdField is String) {
      return userIdField;
    } else if (userIdField is Map<String, dynamic>) {
      return userIdField['_id'] as String;
    }
    throw 'Invalid userId format: $userIdField';
  }

  // Helper method để extract user info từ populated _idUser
  static Map<String, String?> _extractUserInfo(dynamic userIdField) {
    if (userIdField is Map<String, dynamic>) {
      return {
        'fullname': userIdField['fullname'] as String?,
        'phone': userIdField['phone'] as String?,
      };
    }
    return {'fullname': null, 'phone': null};
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      final userId = _extractUserId(json['_idUser']);
      final userInfo = _extractUserInfo(json['_idUser']);
      
      return Address(
        id: json['_id'] as String,
        userId: userId,
        detailed: json['detailed'] as String?,
        district: json['district'] as String?,
        city: json['city'] as String?,
        province: json['province'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        userFullname: userInfo['fullname'],
        userPhone: userInfo['phone'],
      );
    } catch (e) {
      print('Error parsing Address from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      '_idUser': userId, // Luôn gửi dưới dạng string ID
      'detailed': detailed,
      'district': district,
      'city': city,
      'province': province,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? detailed,
    String? district,
    String? city,
    String? province,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userFullname,
    String? userPhone,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      detailed: detailed ?? this.detailed,
      district: district ?? this.district,
      city: city ?? this.city,
      province: province ?? this.province,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userFullname: userFullname ?? this.userFullname,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  String get formattedAddress {
    final parts = <String>[];
    if (detailed != null && detailed!.isNotEmpty) parts.add(detailed!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    return parts.join(', ');
  }

  // Getter để lấy thông tin user nếu có
  String get userDisplayName => userFullname ?? 'Unknown User';
  String get userDisplayPhone => userPhone ?? '';
}