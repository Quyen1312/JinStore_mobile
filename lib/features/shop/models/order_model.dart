import 'dart:convert';
import 'order_item_model.dart'; // From previous questions

class OrderModel {
  final String id; // Maps to _id
  final String userId; // Maps to _idUser
  final List<OrderItemModel> orderItems;
  final String shippingAddress; // Maps to AddressModel ID or object
  final String paymentMethod; // Maps to PaymentMethod ID
  final String? payment; // Maps to Payment ID, optional
  final double totalPrice;
  final bool isPaid;
  final DateTime? paidAt;
  final String status; // 'Chờ xác nhận', 'Đang xử lý', 'Đã giao hàng', 'Đã hủy'
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentMethod,
    this.payment,
    required this.totalPrice,
    this.isPaid = false,
    this.paidAt,
    this.status = 'Chờ xác nhận',
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  // Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      if (payment != null) 'payment': payment,
      'totalPrice': totalPrice,
      'isPaid': isPaid,
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['_idUser']?.toString() ?? json['userId']?.toString() ?? '',
      orderItems: (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      payment: json['payment']?.toString(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      status: json['status'] ?? 'Chờ xác nhận',
      note: json['note'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static empty method
  static OrderModel empty() => OrderModel(
        id: '',
        userId: '',
        orderItems: [],
        shippingAddress: '',
        paymentMethod: '',
        totalPrice: 0.0,
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static OrderModel fromJsonString(String jsonString) {
    try {
      return OrderModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}