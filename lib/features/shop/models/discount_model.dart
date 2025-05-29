import 'dart:convert';

class DiscountModel {
  final String id; // Maps to _id
  final String code;
  final double discount;
  final DateTime expiration;
  final bool isActive;
  final int quantityLimit;
  final int quantityUsed;

  DiscountModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.expiration,
    this.isActive = false,
    this.quantityLimit = 100,
    this.quantityUsed = 0,
  });

  // Convert DiscountModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'expiration': expiration.toIso8601String(),
      'isActive': isActive,
      'quantityLimit': quantityLimit,
      'quantityUsed': quantityUsed,
    };
  }

  // Create DiscountModel from JSON
  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      expiration: json['expiration'] != null ? DateTime.parse(json['expiration']) : DateTime.now(),
      isActive: json['isActive'] ?? false,
      quantityLimit: json['quantityLimit'] ?? 100,
      quantityUsed: json['quantityUsed'] ?? 0,
    );
  }

  // Static empty method
  static DiscountModel empty() => DiscountModel(
        id: '',
        code: '',
        discount: 0.0,
        expiration: DateTime.now(),
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static DiscountModel fromJsonString(String jsonString) {
    try {
      return DiscountModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}