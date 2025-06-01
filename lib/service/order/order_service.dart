import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl = 'http://localhost:1000/api/orders';
  String token;

  OrderService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Create new order
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: _headers,
        body: jsonEncode({
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders with status filter
  Future<List<dynamic>> getUserOrders({String? status}) async {
    try {
      String url = '$baseUrl/my-order';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/details/$orderId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update-status/$orderId'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Create payment URL for VNPay
  Future<Map<String, dynamic>> createVNPayUrl({
    required String orderId,
    required double amount,
    String? bankCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl.replaceAll('orders', 'payments')}/vnpay/create_url'),
        headers: _headers,
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          if (bankCode != null) 'bankCode': bankCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create payment URL: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Order not found');
    } else {
      return Exception('Failed with status code: ${response.statusCode}');
    }
  }
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
} 