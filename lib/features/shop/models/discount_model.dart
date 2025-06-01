class Discount {
  final String id;
  final String code;
  final String type;
  final double value;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usageCount;
  final List<String>? applicableProducts;
  final List<String>? applicableCategories;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discount({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.usageCount,
    this.applicableProducts,
    this.applicableCategories,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['_id'],
      code: json['code'],
      type: json['type'],
      value: json['value'].toDouble(),
      minOrderAmount: json['minOrderAmount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      usageLimit: json['usageLimit'],
      usageCount: json['usageCount'],
      applicableProducts: json['applicableProducts'] != null
          ? List<String>.from(json['applicableProducts'])
          : null,
      applicableCategories: json['applicableCategories'] != null
          ? List<String>.from(json['applicableCategories'])
          : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'type': type,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Discount copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    double? minOrderAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usageCount,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  double calculateDiscount(double amount) {
    if (!isValid || amount < minOrderAmount) return 0;
    return type == 'percentage' ? amount * value / 100 : value;
  }
} 