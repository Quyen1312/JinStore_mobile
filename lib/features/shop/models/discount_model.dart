// File: lib/features/shop/models/discount_model.dart
// (Hoặc một đường dẫn phù hợp cho model của bạn)

class DiscountModel {
  final String id; // MongoDB sẽ có _id, chúng ta map nó thành id
  final String code;
  final String type; // 'fixed' hoặc 'percentage'
  final double? value; // Chỉ có giá trị nếu type là 'fixed'
  final double? maxPercent; // Chỉ có giá trị nếu type là 'percentage', Mongoose để Number nhưng % thường là int (0-100)
  final DateTime activationDate;
  final DateTime expirationDate;
  final bool isActive;
  final double minOrderAmount;
  final int quantityLimit;
  final int quantityUsed;

  DiscountModel({
    required this.id,
    required this.code,
    required this.type,
    this.value,
    this.maxPercent,
    required this.activationDate,
    required this.expirationDate,
    this.isActive = false,
    this.minOrderAmount = 0,
    this.quantityLimit = 100,
    this.quantityUsed = 0,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '', // Backend thường trả về _id
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'fixed', // Mặc định nếu null, hoặc đảm bảo backend luôn gửi
      value: (json['value'] as num?)?.toDouble(), // Nullable, chỉ tồn tại khi type là 'fixed'
      maxPercent: (json['maxPercent'] as num?)?.toDouble(), // Nullable, chỉ tồn tại khi type là 'percentage'
      activationDate: DateTime.tryParse(json['activationDate'] ?? json['activation'] ?? '') ?? DateTime.now(), // Xử lý cả 'activationDate' và 'activation'
      expirationDate: DateTime.tryParse(json['expirationDate'] ?? json['expiration'] ?? '') ?? DateTime.now().add(const Duration(days: 30)), // Xử lý cả 'expirationDate' và 'expiration'
      isActive: json['isActive'] as bool? ?? false,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      quantityLimit: (json['quantityLimit'] as num?)?.toInt() ?? 100,
      quantityUsed: (json['quantityUsed'] as num?)?.toInt() ?? 0,
    );
  }

  // toJson method nếu bạn cần gửi dữ liệu DiscountModel lên server (ví dụ: admin tạo discount)
  // Đối với app user thường chỉ nhận dữ liệu này.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'code': code,
      'type': type,
      'activationDate': activationDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'isActive': isActive,
      'minOrderAmount': minOrderAmount,
      'quantityLimit': quantityLimit,
      'quantityUsed': quantityUsed,
    };
    if (id.isNotEmpty) { // Không gửi id nếu là tạo mới và id do backend tạo
        // data['_id'] = id; // Hoặc data['id'] = id; tùy theo backend mong đợi
    }
    if (type == 'fixed' && value != null) {
      data['value'] = value;
    }
    if (type == 'percentage' && maxPercent != null) {
      data['maxPercent'] = maxPercent;
    }
    return data;
  }

  // Helper getter để kiểm tra xem discount có còn hiệu lực không (chưa hết hạn và còn số lượng)
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(activationDate) &&
        now.isBefore(expirationDate) &&
        quantityUsed < quantityLimit;
  }

  // Helper getter để hiển thị giá trị giảm giá
  String get displayValue {
    if (type == 'percentage' && maxPercent != null) {
      return '${maxPercent?.toStringAsFixed(0)}%'; // Bỏ phần thập phân nếu là số nguyên
    } else if (type == 'fixed' && value != null) {
      // Bạn có thể cần định dạng tiền tệ ở đây
      return '${value?.toStringAsFixed(0)} VND'; // Ví dụ
    }
    return '';
  }
}
