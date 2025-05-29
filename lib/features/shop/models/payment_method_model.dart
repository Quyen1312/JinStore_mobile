import 'dart:convert';

class PaymentMethodModel {
  final String id; // Maps to _id
  final String code;
  final String name;
  final String type; // 'COD', 'BANKING', 'E_WALLET'
  final String? provider; // 'VNPay', 'Momo', 'ZaloPay', or null for COD
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.provider,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Convert PaymentMethodModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      if (provider != null) 'provider': provider,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create PaymentMethodModel from JSON
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      provider: json['provider'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static empty method
  static PaymentMethodModel empty() => PaymentMethodModel(
        id: '',
        code: '',
        name: '',
        type: '',
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static PaymentMethodModel fromJsonString(String jsonString) {
    try {
      return PaymentMethodModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}