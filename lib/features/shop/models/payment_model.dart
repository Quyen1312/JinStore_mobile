class Payment {
  final String id;
  final String orderId;
  final String userId;
  final String method;
  final double amount;
  final String status;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  final DateTime? paidAt;
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
    return Payment(
      id: json['_id'],
      orderId: json['orderId'],
      userId: json['userId'],
      method: json['method'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      transactionId: json['transactionId'],
      paymentDetails: json['paymentDetails'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'userId': userId,
      'method': method,
      'amount': amount,
      'status': status,
      'transactionId': transactionId,
      'paymentDetails': paymentDetails,
      'paidAt': paidAt?.toIso8601String(),
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
      id: json['_id'],
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      reason: json['reason'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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