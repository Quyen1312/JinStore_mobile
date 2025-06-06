// order_service.dart - 100% MATCH với backend routes
import 'dart:convert';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/service/base_service.dart';

class OrderService extends BaseService {
  @override
  String get serviceName => 'OrderService';

  /// Tạo đơn hàng mới
  /// ✅ Backend: POST /api/orders/create
  Future<OrderModel> createOrder({
    required List<OrderItemModel> orderItems,
    required String shippingAddress,
    required double shippingFee,
    required String paymentMethod,
    required double totalAmount,
    String? note,
    String? source,
    String? discount,
  }) async {
    try {
      await ensureAuthenticated();
      
      final List<Map<String, dynamic>> itemsAsJson =
          orderItems.map((item) => item.toJson()).toList();

      final Map<String, dynamic> body = {
        'orderItems': itemsAsJson,
        'shippingAddress': shippingAddress,
        'shippingFee': shippingFee,
        'paymentMethod': paymentMethod.toLowerCase(),
        'totalAmount': totalAmount,
      };
      
      if (note != null) body['note'] = note;
      if (source != null) body['source'] = source;
      if (discount != null) body['discount'] = discount;
      
      print("$serviceName createOrder Body: ${jsonEncode(body)}");
      final response = await post('/orders/create', body);

      final apiResponse = ApiResponse<OrderModel>.fromResponse(
        response,
        dataParser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      );

      return handleApiResponse(apiResponse, 'createOrder');
    } catch (e) {
      print('Lỗi trong $serviceName.createOrder: $e');
      throw e is String ? e : 'Lỗi khi tạo đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ FIXED: Lấy đơn hàng của user hiện tại
  /// Backend route: GET /api/orders/my-order?status=pending
  /// Backend controller: getOrdersStatus với req.user._id
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      await ensureAuthenticated();
      
      // ✅ CORRECT: Backend route là /my-order, không phải /status
      String endpoint = '/orders/my-order';
      if (status != null && status.isNotEmpty && status != 'all') {
        endpoint += '?status=$status';
      }
      
      print("$serviceName getMyOrders endpoint: $endpoint");
      final response = await get(endpoint);
      
      final apiResponse = ApiResponse<List<OrderModel>>.fromResponse(
        response,
        dataParser: (data) {
          if (data is! List) throw 'Expected list data';
          return (data as List)
              .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
        },
      );

      return handleListResponse(apiResponse, 'getMyOrders');
    } catch (e) {
      print('Lỗi trong $serviceName.getMyOrders: $e');
      throw e is String ? e : 'Không thể lấy danh sách đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ FIXED: Lấy orders của user cụ thể (Admin only)
  /// Backend route: GET /api/orders/user/:id?status=pending
  Future<List<OrderModel>> getOrdersByUserIdAdmin(String userId, {String? status}) async {
    try {
      await ensureAdminRights();
      
      String endpoint = '/orders/user/$userId';
      if (status != null && status.isNotEmpty && status != 'all') {
        endpoint += '?status=$status';
      }
      
      print("$serviceName getOrdersByUserIdAdmin endpoint: $endpoint");
      final response = await get(endpoint);
      
      final apiResponse = ApiResponse<List<OrderModel>>.fromResponse(
        response,
        dataParser: (data) {
          if (data is! List) throw 'Expected list data';
          return (data as List)
              .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
        },
      );

      return handleListResponse(apiResponse, 'getOrdersByUserIdAdmin');
    } catch (e) {
      print('Lỗi trong $serviceName.getOrdersByUserIdAdmin: $e');
      throw e is String ? e : 'Không thể lấy danh sách đơn hàng của người dùng: ${e.toString()}';
    }
  }

  /// ✅ FIXED: Lấy tất cả orders trong hệ thống (Admin only)
  /// Backend route: GET /api/orders/list?status=pending
  Future<List<OrderModel>> getAllOrdersAdmin({String? status}) async {
    try {
      await ensureAdminRights();
      
      String endpoint = '/orders/list';
      if (status != null && status.isNotEmpty && status != 'all') {
        endpoint += '?status=$status';
      }
      
      print("$serviceName getAllOrdersAdmin endpoint: $endpoint");
      final response = await get(endpoint);
      
      final apiResponse = ApiResponse<List<OrderModel>>.fromResponse(
        response,
        dataParser: (data) {
          if (data is! List) throw 'Expected list data';
          return (data as List)
              .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
        },
      );

      return handleListResponse(apiResponse, 'getAllOrdersAdmin');
    } catch (e) {
      print('Lỗi trong $serviceName.getAllOrdersAdmin: $e');
      throw e is String ? e : 'Không thể lấy tất cả đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ CORRECT: Lấy chi tiết một đơn hàng
  /// Backend route: GET /api/orders/details/:id
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      await ensureAuthenticated();
      
      if (orderId.trim().isEmpty) {
        throw 'Order ID không hợp lệ';
      }
      
      print("$serviceName getOrderDetails for ID: $orderId");
      final response = await get('/orders/details/$orderId');

      final apiResponse = ApiResponse<OrderModel>.fromResponse(
        response,
        dataParser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      );

      return handleApiResponse(apiResponse, 'getOrderDetails');
    } catch (e) {
      print('Lỗi trong $serviceName.getOrderDetails: $e');
      throw e is String ? e : 'Lỗi khi lấy chi tiết đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ FIXED: Cập nhật trạng thái đơn hàng
  /// Backend route: PATCH /api/orders/update-status/:id (NOT PUT!)
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await ensureAuthenticated();
      
      if (orderId.trim().isEmpty) {
        throw 'Order ID không hợp lệ';
      }
      
      if (status.trim().isEmpty) {
        throw 'Status không hợp lệ';
      }
      
      // ✅ Validate status với backend enum
      final validStatuses = ['pending', 'paid', 'processing', 'shipping', 'delivered', 'received', 'cancelled'];
      if (!validStatuses.contains(status.toLowerCase().trim())) {
        throw 'Status không hợp lệ: $status';
      }
      
      final body = {'status': status.toLowerCase().trim()};
      print("$serviceName updateOrderStatus Body: $body for OrderID: $orderId");
      
      // ✅ FIXED: Backend sử dụng PATCH method và route /update-status/:id
      final response = await patch('/orders/update-status/$orderId', body);

      final apiResponse = ApiResponse<OrderModel>.fromResponse(
        response,
        dataParser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      );

      return handleApiResponse(apiResponse, 'updateOrderStatus');
    } catch (e) {
      print('Lỗi trong $serviceName.updateOrderStatus: $e');
      throw e is String ? e : 'Lỗi khi cập nhật trạng thái đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ CORRECT: Xóa đơn hàng (Admin only)
  /// Backend route: DELETE /api/orders/delete/:id
  Future<void> deleteOrderAdmin(String orderId) async {
    try {
      await ensureAdminRights();
      
      if (orderId.trim().isEmpty) {
        throw 'Order ID không hợp lệ';
      }
      
      print("$serviceName deleteOrderAdmin for ID: $orderId");
      final response = await delete('/orders/delete/$orderId');

      final apiResponse = ApiResponse<dynamic>.fromResponse(response);
      
      if (!apiResponse.success) {
        final errorMessage = apiResponse.error ?? apiResponse.message ?? 'Lỗi khi xóa đơn hàng.';
        throw errorMessage;
      }
      
      print("$serviceName deleteOrderAdmin success for ID: $orderId");
      // Success - void return
    } catch (e) {
      print('Lỗi trong $serviceName.deleteOrderAdmin: $e');
      throw e is String ? e : 'Lỗi khi xóa đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ BONUS: Test connection với backend
  Future<bool> testConnection() async {
    try {
      await ensureAuthenticated();
      
      // Test với endpoint đơn giản nhất
      final response = await get('/orders/my-order');
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } catch (e) {
      print('$serviceName connection test failed: $e');
      return false;
    }
  }

  /// ✅ BONUS: Refresh orders cache
  Future<void> refreshOrdersCache() async {
    try {
      print('$serviceName refreshing orders cache...');
      await getMyOrders();
      print('$serviceName orders cache refreshed successfully');
    } catch (e) {
      print('$serviceName failed to refresh cache: $e');
      throw 'Không thể refresh cache đơn hàng: ${e.toString()}';
    }
  }

  /// ✅ BONUS: Validate order data trước khi gửi
  bool validateOrderData({
    required List<OrderItemModel> orderItems,
    required String shippingAddress,
    required double shippingFee,
    required String paymentMethod,
    required double totalAmount,
  }) {
    try {
      // Validate order items
      if (orderItems.isEmpty) {
        throw 'Đơn hàng phải có ít nhất một sản phẩm';
      }
      
      for (final item in orderItems) {
        if (item.quantity <= 0) {
          throw 'Số lượng sản phẩm phải lớn hơn 0';
        }
        if (item.price < 0) {
          throw 'Giá sản phẩm không hợp lệ';
        }
      }
      
      // Validate shipping address
      if (shippingAddress.trim().isEmpty) {
        throw 'Địa chỉ giao hàng không được để trống';
      }
      
      // Validate shipping fee
      if (shippingFee < 0) {
        throw 'Phí vận chuyển không hợp lệ';
      }
      
      // Validate payment method
      final validPaymentMethods = ['vnpay', 'cod'];
      if (!validPaymentMethods.contains(paymentMethod.toLowerCase())) {
        throw 'Phương thức thanh toán không hợp lệ';
      }
      
      // Validate total amount
      if (totalAmount <= 0) {
        throw 'Tổng tiền phải lớn hơn 0';
      }
      
      return true;
    } catch (e) {
      print('$serviceName validation failed: $e');
      throw e;
    }
  }
}