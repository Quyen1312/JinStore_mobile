// order_service.dart
import 'dart:convert';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/service/base_service.dart';

class OrderService extends BaseService {
  @override
  String get serviceName => 'OrderService';

  /// Tạo đơn hàng mới
  /// Backend: POST /orders/create
  Future<OrderModel> createOrder({
    required List<OrderItemModel> orderItems,
    required String shippingAddress, // Fixed: match backend field name
    required double shippingFee,
    required String paymentMethod,
    required double totalAmount,
    String? note,
    String? source,
    String? discountCode,
  }) async {
    try {
      await ensureAuthenticated();
      
      final List<Map<String, dynamic>> itemsAsJson =
          orderItems.map((item) => item.toJson()).toList();

      final Map<String, dynamic> body = {
        'orderItems': itemsAsJson,
        'shippingAddress': shippingAddress, // Fixed: correct field name
        'shippingFee': shippingFee,
        'paymentMethod': paymentMethod.toLowerCase(),
        'totalAmount': totalAmount,
      };
      
      if (note != null) body['note'] = note;
      if (source != null) body['source'] = source;
      if (discountCode != null) body['discountCode'] = discountCode;
      
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

  /// Lấy các đơn hàng của người dùng hiện tại
  /// Backend: GET /orders/my-order?status=pending
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      await ensureAuthenticated();
      
      String endpoint = '/orders/my-order';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }
      
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

  /// Lấy các đơn hàng của một người dùng cụ thể (Admin only)
  /// Backend: GET /orders/user/:id?status=pending
  Future<List<OrderModel>> getOrdersByUserIdAdmin(String userId, {String? status}) async {
    try {
      await ensureAdminRights();
      
      String endpoint = '/orders/user/$userId';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }
      
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

  /// Lấy tất cả đơn hàng trong hệ thống (Admin only)
  /// Backend: GET /orders/list?status=pending
  Future<List<OrderModel>> getAllOrdersAdmin({String? status}) async {
    try {
      await ensureAdminRights();
      
      String endpoint = '/orders/list';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }
      
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

  /// Lấy chi tiết một đơn hàng
  /// Backend: GET /orders/details/:id
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      await ensureAuthenticated();
      
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

  /// Cập nhật trạng thái đơn hàng
  /// Backend: PATCH /orders/update-status/:id
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await ensureAuthenticated(); // Changed: verifyToken, not verifyTokenAndAdmin
      
      final body = {'status': status.toLowerCase()};
      print("$serviceName updateOrderStatus Body: $body for OrderID: $orderId");
      
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

  /// Xóa đơn hàng (Admin only)
  /// Backend: DELETE /orders/delete/:id
  Future<void> deleteOrderAdmin(String orderId) async {
    try {
      await ensureAdminRights(); // Correct: verifyTokenAndAdmin required
      
      final response = await delete('/orders/delete/$orderId');

      final apiResponse = ApiResponse<dynamic>.fromResponse(response);
      
      if (!apiResponse.success) {
        final errorMessage = apiResponse.error ?? apiResponse.message ?? 'Lỗi khi xóa đơn hàng.';
        throw errorMessage;
      }
      
      // Success - void return
    } catch (e) {
      print('Lỗi trong $serviceName.deleteOrderAdmin: $e');
      throw e is String ? e : 'Lỗi khi xóa đơn hàng: ${e.toString()}';
    }
  }
}