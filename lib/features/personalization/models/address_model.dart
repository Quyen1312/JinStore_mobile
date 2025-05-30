import 'dart:convert';

class AddressModel {
  final String id;
  final String userId; // Maps to _idUser in Mongoose schema
  final String? detailed; // Specific address details
  final String? district; // Phường/Xã
  final String? city; // Quận/Huyện
  final String? province; // Tỉnh/Thành phố
  bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    this.detailed,
    this.district,
    this.city,
    this.province,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // Method to convert AddressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      if (detailed != null) 'detailed': detailed,
      if (district != null) 'district': district,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Method to create AddressModel from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['_idUser']?.toString() ?? json['userId']?.toString() ?? '',
      detailed: json['detailed'],
      district: json['district'],
      city: json['city'],
      province: json['province'],
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static method for empty AddressModel
  static AddressModel empty() => AddressModel(
        id: '',
        userId: '',
      );

  // Helper method to convert AddressModel to a JSON string
  String toJsonString() => jsonEncode(toJson());

  // Helper method to create AddressModel from a JSON string
  static AddressModel fromJsonString(String jsonString) {
    try {
      return AddressModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }

  @override
  String toString() {
    return '${detailed ?? ''}, ${district ?? ''}, ${city ?? ''}, ${province ?? ''}';
  }
}