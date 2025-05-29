import 'dart:convert';

class PaymentModel {
  final String id; // Maps to _id
  final String order; // Maps to order ID
  final String user; // Maps to user ID
  final String paymentMethod; // Maps to paymentMethod ID
  final String? transactionId; // Required for non-COD paid payments
  final double amount;
  final String status; // 'pending', 'paid', 'failed'
  final DateTime? paymentTime;
  final Map<String, dynamic>? gatewayResponse;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.order,
    required this.user,
    required this.paymentMethod,
    this.transactionId,
    required this.amount,
    this.status = 'pending',
    this.paymentTime,
    this.gatewayResponse,
    this.createdAt,
    this.updatedAt,
  });

  // Convert PaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'user': user,
      'paymentMethod': paymentMethod,
      if (transactionId != null) 'transactionId': transactionId,
      'amount': amount,
      'status': status,
      if (paymentTime != null) 'paymentTime': paymentTime!.toIso8601String(),
      if (gatewayResponse != null) 'gatewayResponse': gatewayResponse,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      order: json['order']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionId: json['transactionId'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentTime: json['paymentTime'] != null ? DateTime.parse(json['paymentTime']) : null,
      gatewayResponse: json['gatewayResponse'] != null ? Map<String, dynamic>.from(json['gatewayResponse']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static empty method
  static PaymentModel empty() => PaymentModel(
        id: '',
        order: '',
        user: '',
        paymentMethod: '',
        amount: 0.0,
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static PaymentModel fromJsonString(String jsonString) {
    try {
      return PaymentModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}