import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = 'http://localhost:1000/api/payments';
  String token;

  PaymentService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Create VNPay payment URL
  Future<Map<String, dynamic>> createVNPayUrl({
    required String orderId,
    required double amount,
    String? bankCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vnpay/create_url'),
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

  // Get payment by ID
  Future<Map<String, dynamic>> getPaymentById(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$paymentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch payment details: $e');
    }
  }

  // Get payments by order ID
  Future<List<dynamic>> getPaymentsByOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order/$orderId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch order payments: $e');
    }
  }

  // Get user's payment history
  Future<List<dynamic>> getUserPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch user payments: $e');
    }
  }

  // Verify VNPay payment return
  Future<Map<String, dynamic>> verifyVNPayReturn(Map<String, String> vnpParams) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vnpay/verify_return'),
        headers: _headers,
        body: jsonEncode(vnpParams),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Create refund request
  Future<Map<String, dynamic>> createRefund({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refund'),
        headers: _headers,
        body: jsonEncode({
          'paymentId': paymentId,
          'amount': amount,
          if (reason != null) 'reason': reason,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create refund request: $e');
    }
  }

  // Get refund status
  Future<Map<String, dynamic>> getRefundStatus(String refundId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/refund/$refundId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch refund status: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Payment not found');
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