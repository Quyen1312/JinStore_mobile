class Discount {
  final String id; // Từ _id của Mongoose
  final String code;
  final String type; // 'fixed' hoặc 'percentage'

  // Nếu type là 'fixed', giá trị này được sử dụng.
  // Nếu type là 'percentage', giá trị này có thể là null.
  final double? fixedValue;

  // Nếu type là 'percentage', giá trị này được sử dụng (0-100).
  // Nếu type là 'fixed', giá trị này có thể là null.
  final double? percentageValue;

  final DateTime activationDate; // Đổi từ startDate, khớp với 'activation'
  final DateTime expirationDate; // Đổi từ endDate, khớp với 'expiration'
  final bool isActive;
  final double minOrderAmount;
  final int quantityLimit; // Đổi từ usageLimit, khớp với 'quantityLimit'
  final int quantityUsed;  // Đổi từ usageCount, khớp với 'quantityUsed'

  // createdAt và updatedAt bị loại bỏ vì không có trong schema backend Discount.js
  // Nếu backend thực sự gửi chúng, bạn có thể thêm lại:
  // final DateTime? createdAt;
  // final DateTime? updatedAt;

  Discount({
    required this.id,
    required this.code,
    required this.type,
    this.fixedValue,
    this.percentageValue,
    required this.activationDate,
    required this.expirationDate,
    required this.isActive,
    required this.minOrderAmount,
    required this.quantityLimit,
    required this.quantityUsed,
    // this.createdAt,
    // this.updatedAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    final String discountType = json['type'] as String;
    double? parsedFixedValue;
    double? parsedPercentageValue;

    if (discountType == 'fixed') {
      parsedFixedValue = (json['value'] as num?)?.toDouble();
    } else if (discountType == 'percentage') {
      // Backend schema dùng 'maxPercent' cho giá trị phần trăm
      parsedPercentageValue = (json['maxPercent'] as num?)?.toDouble();
    }

    return Discount(
      id: json['_id'] as String,
      code: json['code'] as String,
      type: discountType,
      fixedValue: parsedFixedValue,
      percentageValue: parsedPercentageValue,
      activationDate: DateTime.parse(json['activation'] as String),
      expirationDate: DateTime.parse(json['expiration'] as String),
      isActive: json['isActive'] as bool? ?? false,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      quantityLimit: json['quantityLimit'] as int? ?? 100, // Sử dụng default từ schema nếu null
      quantityUsed: json['quantityUsed'] as int? ?? 0,   // Sử dụng default từ schema nếu null
      // createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      // updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'code': code,
      'type': type,
      'activation': activationDate.toIso8601String(),
      'expiration': expirationDate.toIso8601String(),
      'isActive': isActive,
      'minOrderAmount': minOrderAmount,
      'quantityLimit': quantityLimit,
      'quantityUsed': quantityUsed,
      // 'createdAt': createdAt?.toIso8601String(),
      // 'updatedAt': updatedAt?.toIso8601String(),
    };
    if (type == 'fixed' && fixedValue != null) {
      data['value'] = fixedValue;
    } else if (type == 'percentage' && percentageValue != null) {
      data['maxPercent'] = percentageValue;
    }
    return data;
  }

  Discount copyWith({
    String? id,
    String? code,
    String? type,
    double? fixedValue,
    double? percentageValue,
    DateTime? activationDate,
    DateTime? expirationDate,
    bool? isActive,
    double? minOrderAmount,
    int? quantityLimit,
    int? quantityUsed,
    // DateTime? createdAt,
    // DateTime? updatedAt,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      fixedValue: fixedValue ?? this.fixedValue,
      percentageValue: percentageValue ?? this.percentageValue,
      activationDate: activationDate ?? this.activationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isActive: isActive ?? this.isActive,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      quantityLimit: quantityLimit ?? this.quantityLimit,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      // createdAt: createdAt ?? this.createdAt,
      // updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Các getter helper có thể cần điều chỉnh hoặc giữ nguyên nếu logic vẫn đúng
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(activationDate) &&
        now.isBefore(expirationDate) &&
        (quantityUsed < quantityLimit); // quantityLimit luôn có giá trị (default 100)
  }

  // Giá trị giảm giá thực tế (số tiền hoặc %)
  double get discountDisplayValue {
    if (type == 'percentage') {
      return percentageValue ?? 0.0;
    }
    return fixedValue ?? 0.0;
  }

  double calculateDiscountAmount(double orderAmount) {
    if (!isValid || orderAmount < minOrderAmount) {
      return 0.0;
    }
    if (type == 'percentage') {
      return (orderAmount * (percentageValue ?? 0.0)) / 100.0;
    } else if (type == 'fixed') {
      // Đảm bảo giá trị giảm không lớn hơn số tiền đơn hàng
      return (fixedValue ?? 0.0) > orderAmount ? orderAmount : (fixedValue ?? 0.0);
    }
    return 0.0;
  }
}
