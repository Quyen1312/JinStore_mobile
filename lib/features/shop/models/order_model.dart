// order_model.dart
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';

// Model cho từng sản phẩm trong đơn hàng, khớp với orderItemSchema của backend
class OrderItemModel {
  final String productId; // Tương ứng với _idProduct từ backend
  final String name;      // Tên sản phẩm tại thời điểm mua
  final double price;     // Giá tại thời điểm mua
  final int quantity;
  
  // Optional populated product data
  final ProductModel? productDetails;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.productDetails,
  });

  // Helper methods for populated data
  String get displayName => productDetails?.name ?? name;
  List<ImageModel> get images => productDetails?.images ?? [];
  String get unit => productDetails?.unit ?? '';
  double get currentPrice => productDetails?.price ?? price;
  bool get isAvailable => productDetails?.isAvailable ?? true;
  int get availableStock => productDetails?.quantity ?? 0;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Required fields validation
    if (!json.containsKey('_idProduct')) {
      throw ArgumentError("JSON cho OrderItemModel phải chứa '_idProduct'");
    }
    if (!json.containsKey('name')) {
      throw ArgumentError("JSON cho OrderItemModel phải chứa 'name'");
    }
    if (!json.containsKey('price')) {
      throw ArgumentError("JSON cho OrderItemModel phải chứa 'price'");
    }
    if (!json.containsKey('quantity')) {
      throw ArgumentError("JSON cho OrderItemModel phải chứa 'quantity'");
    }

    // Handle _idProduct field - String hoặc Object
    String productId;
    ProductModel? productDetails;
    
    final idProductField = json['_idProduct'];
    if (idProductField is String) {
      // Non-populated case
      productId = idProductField;
      productDetails = null;
    } else if (idProductField is Map<String, dynamic>) {
      // Populated case
      productId = idProductField['_id'] as String;
      try {
        productDetails = ProductModel.fromJson(idProductField);
      } catch (e) {
        print('Warning: Failed to parse populated product data: $e');
        productDetails = null;
      }
    } else {
      throw ArgumentError("Invalid _idProduct field type: ${idProductField.runtimeType}");
    }

    return OrderItemModel(
      productId: productId,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      productDetails: productDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_idProduct': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  OrderItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    ProductModel? productDetails,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productDetails: productDetails ?? this.productDetails,
    );
  }
}

// Model cho đơn hàng, khớp với orderSchema của backend
class OrderModel {
  final String id; // Tương ứng với _id của document Order
  final String userId; // Tương ứng với _idUser
  final String? discountId; // Tương ứng với discount (ObjectId ref: 'Discount'), có thể null
  final List<OrderItemModel> orderItems;
  final String shippingAddress; // Tương ứng với shippingAddress (ObjectId ref: 'Address')
  final double shippingFee;
  final String paymentMethod; // enum: ['vnpay', 'cod']
  final double totalAmount;
  final bool isPaid;
  final DateTime? paidAt; // Có thể null
  final String status; // enum: ['pending', 'paid', ..., 'cancelled']
  final String? note; // Tùy chọn
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional populated data
  final User? userDetails;
  final Address? addressDetails;

  OrderModel({
    required this.id,
    required this.userId,
    this.discountId,
    required this.orderItems,
    required this.shippingAddress,
    required this.shippingFee,
    required this.paymentMethod,
    required this.totalAmount,
    required this.isPaid,
    this.paidAt,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.userDetails,
    this.addressDetails,
  });

  // Helper methods for populated data
  String get customerName => userDetails?.fullname ?? 'Unknown Customer';
  String get customerPhone => userDetails?.phone ?? '';
  String get customerEmail => userDetails?.email ?? '';
  String get shippingAddressText => addressDetails?.formattedAddress ?? shippingAddress;
  bool get hasCompleteUserInfo => userDetails != null;
  bool get hasCompleteAddressInfo => addressDetails != null;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Required fields validation
    if (!json.containsKey('_id')) throw ArgumentError("JSON cho OrderModel phải chứa '_id'");
    if (!json.containsKey('_idUser')) throw ArgumentError("JSON cho OrderModel phải chứa '_idUser'");
    if (!json.containsKey('orderItems')) throw ArgumentError("JSON cho OrderModel phải chứa 'orderItems'");
    if (!json.containsKey('shippingAddress')) throw ArgumentError("JSON cho OrderModel phải chứa 'shippingAddress'");
    if (!json.containsKey('shippingFee')) throw ArgumentError("JSON cho OrderModel phải chứa 'shippingFee'");
    if (!json.containsKey('paymentMethod')) throw ArgumentError("JSON cho OrderModel phải chứa 'paymentMethod'");
    if (!json.containsKey('totalAmount')) throw ArgumentError("JSON cho OrderModel phải chứa 'totalAmount'");
    if (!json.containsKey('status')) throw ArgumentError("JSON cho OrderModel phải chứa 'status'");
    if (!json.containsKey('createdAt')) throw ArgumentError("JSON cho OrderModel phải chứa 'createdAt'");
    if (!json.containsKey('updatedAt')) throw ArgumentError("JSON cho OrderModel phải chứa 'updatedAt'");

    // Handle _idUser field - String hoặc User Object
    String userId;
    User? userDetails;
    
    final userField = json['_idUser'];
    if (userField is String) {
      userId = userField;
      userDetails = null;
    } else if (userField is Map<String, dynamic>) {
      userId = userField['_id'] as String;
      try {
        userDetails = User.fromJson(userField);
      } catch (e) {
        print('Warning: Failed to parse populated user data: $e');
        userDetails = null;
      }
    } else {
      throw ArgumentError("Invalid _idUser field type: ${userField.runtimeType}");
    }

    // Handle shippingAddress field - String hoặc Address Object
    String shippingAddress;
    Address? addressDetails;
    
    final addressField = json['shippingAddress'];
    if (addressField is String) {
      shippingAddress = addressField;
      addressDetails = null;
    } else if (addressField is Map<String, dynamic>) {
      shippingAddress = addressField['_id'] as String;
      try {
        addressDetails = Address.fromJson(addressField);
      } catch (e) {
        print('Warning: Failed to parse populated address data: $e');
        addressDetails = null;
      }
    } else {
      throw ArgumentError("Invalid shippingAddress field type: ${addressField.runtimeType}");
    }

    // Parse orderItems với updated logic
    var parsedOrderItems = <OrderItemModel>[];
    if (json['orderItems'] != null && json['orderItems'] is List) {
      for (var itemJson in json['orderItems'] as List) {
        try {
          if (itemJson is Map<String, dynamic>) {
            parsedOrderItems.add(OrderItemModel.fromJson(itemJson));
          }
        } catch (e) {
          print('Warning: Failed to parse order item: $e');
        }
      }
    }

    return OrderModel(
      id: json['_id'] as String,
      userId: userId,
      userDetails: userDetails,
      discountId: json['discount'] as String?,
      orderItems: parsedOrderItems,
      shippingAddress: shippingAddress,
      addressDetails: addressDetails,
      shippingFee: (json['shippingFee'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
      paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt'] as String),
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      '_idUser': userId,
      'discount': discountId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'shippingFee': shippingFee,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? discountId,
    List<OrderItemModel>? orderItems,
    String? shippingAddress,
    double? shippingFee,
    String? paymentMethod,
    double? totalAmount,
    bool? isPaid,
    DateTime? paidAt,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? userDetails,
    Address? addressDetails,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      discountId: discountId ?? this.discountId,
      orderItems: orderItems ?? this.orderItems,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingFee: shippingFee ?? this.shippingFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userDetails: userDetails ?? this.userDetails,
      addressDetails: addressDetails ?? this.addressDetails,
    );
  }
}