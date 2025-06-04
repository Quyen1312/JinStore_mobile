import 'dart:convert'; // Cần thiết nếu paymentDetails là JSON string

class Payment {
  final String id; // Từ _id của Mongoose
  final String orderId; // Từ 'order' (ObjectId) của backend
  final String userId; // Từ 'user' (ObjectId) của backend
  final String method; // Từ '_orderPaymentMethod' của backend
  final double amount;
  final String status; // enum: ['pending', 'paid', 'failed']
  final String? transactionId;
  final Map<String, dynamic>?
      paymentDetails; // Từ 'vnpayResponse' (Mixed) của backend
  final DateTime? paidAt; // Từ 'paymentTime' của backend
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.method,
    required this.amount,
    required this.status,
    this.transactionId,
    this.paymentDetails,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Kiểm tra các trường bắt buộc dựa trên schema backend
    if (!json.containsKey('_id')) {
      throw ArgumentError("JSON cho Payment phải chứa '_id'");
    }
    if (!json.containsKey('order')) {
      throw ArgumentError("JSON cho Payment phải chứa 'order' (là orderId)");
    }
    if (!json.containsKey('user')) {
      throw ArgumentError("JSON cho Payment phải chứa 'user' (là userId)");
    }
    if (!json.containsKey('_orderPaymentMethod')) {
      throw ArgumentError(
          "JSON cho Payment phải chứa '_orderPaymentMethod' (là method)");
    }
    if (!json.containsKey('amount')) {
      throw ArgumentError("JSON cho Payment phải chứa 'amount'");
    }
    // status có default ở backend
    if (!json.containsKey('createdAt')) {
      throw ArgumentError("JSON cho Payment phải chứa 'createdAt'");
    }
    if (!json.containsKey('updatedAt')) {
      throw ArgumentError("JSON cho Payment phải chứa 'updatedAt'");
    }

    Map<String, dynamic>? parsedPaymentDetails;
    if (json['vnpayResponse'] != null) {
      if (json['vnpayResponse'] is String) {
        // Nếu vnpayResponse là một chuỗi JSON, parse nó
        try {
          parsedPaymentDetails =
              jsonDecode(json['vnpayResponse'] as String) as Map<String, dynamic>?;
        } catch (e) {
          print(
              "Lỗi khi parse vnpayResponse (String): $e. Để nguyên là null.");
          parsedPaymentDetails = null;
        }
      } else if (json['vnpayResponse'] is Map) {
        // Nếu đã là Map rồi
        parsedPaymentDetails =
            Map<String, dynamic>.from(json['vnpayResponse'] as Map);
      }
    }

    return Payment(
      id: json['_id'] as String,
      orderId: json['order'] as String, // Backend dùng 'order' cho orderId
      userId: json['user'] as String, // Backend dùng 'user' cho userId
      method: json['_orderPaymentMethod']
          as String, // Backend dùng '_orderPaymentMethod'
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ??
          'pending', // Sử dụng default từ schema nếu null
      transactionId: json['transactionId'] as String?,
      paymentDetails: parsedPaymentDetails, // Backend dùng 'vnpayResponse'
      paidAt: json['paymentTime'] == null
          ? null
          : DateTime.parse(json['paymentTime'] as String), // Backend dùng 'paymentTime'
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': orderId, // Gửi lại 'order' cho backend
      'user': userId, // Gửi lại 'user' cho backend
      '_orderPaymentMethod': method, // Gửi lại '_orderPaymentMethod' cho backend
      'amount': amount,
      'status': status,
      'transactionId': transactionId,
      'vnpayResponse': paymentDetails, // Gửi lại 'vnpayResponse' cho backend
      'paymentTime': paidAt?.toIso8601String(), // Gửi lại 'paymentTime' cho backend
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? method,
    double? amount,
    String? status,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Lớp Refund được giữ nguyên vì schema backend cho nó không được cung cấp trong Payment.js
class Refund {
  final String id;
  final String paymentId;
  final String orderId;
  final String userId;
  final double amount;
  final String status;
  final String? reason;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Refund({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.status,
    this.reason,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['_id'] as String,
      paymentId: json['paymentId'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      reason: json['reason'] as String?,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'paymentId': paymentId,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'status': status,
      'reason': reason,
      'processedAt': processedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Refund copyWith({
    String? id,
    String? paymentId,
    String? orderId,
    String? userId,
    double? amount,
    String? status,
    String? reason,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Refund(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
