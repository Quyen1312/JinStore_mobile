class Address {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String city;
  final String province;
  final String? district;
  final String? ward;
  final String? postalCode;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.province,
    this.district,
    this.ward,
    this.postalCode,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      userId: json['userId'],
      fullName: json['fullName'],
      phone: json['phone'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      province: json['province'],
      district: json['district'],
      ward: json['ward'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'province': province,
      'district': district,
      'ward': ward,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? streetAddress,
    String? city,
    String? province,
    String? district,
    String? ward,
    String? postalCode,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedAddress {
    final parts = [streetAddress];
    
    if (ward != null) parts.add(ward!);
    if (district != null) parts.add(district!);
    parts.add(city);
    parts.add(province);
    if (postalCode != null) parts.add(postalCode!);
    
    return parts.join(', ');
  }
} 