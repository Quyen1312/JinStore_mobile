import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscountService {
  static const String baseUrl = 'http://localhost:1000/api/discounts';
  String token;

  DiscountService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Get all active discounts
  Future<List<dynamic>> getActiveDiscounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/active'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch active discounts: $e');
    }
  }

  // Get discount by code
  Future<Map<String, dynamic>> getDiscountByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/code/$code'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch discount details: $e');
    }
  }

  // Validate discount code
  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    required double orderAmount,
    List<String>? productIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate'),
        headers: _headers,
        body: jsonEncode({
          'code': code,
          'orderAmount': orderAmount,
          if (productIds != null) 'productIds': productIds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to validate discount: $e');
    }
  }

  // Create discount (Admin only)
  Future<Map<String, dynamic>> createDiscount({
    required String code,
    required String type,
    required double value,
    required double minOrderAmount,
    required DateTime startDate,
    required DateTime endDate,
    int? usageLimit,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode({
          'code': code,
          'type': type,
          'value': value,
          'minOrderAmount': minOrderAmount,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          if (usageLimit != null) 'usageLimit': usageLimit,
          if (applicableProducts != null) 'applicableProducts': applicableProducts,
          if (applicableCategories != null) 'applicableCategories': applicableCategories,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create discount: $e');
    }
  }

  // Update discount (Admin only)
  Future<Map<String, dynamic>> updateDiscount({
    required String id,
    String? code,
    String? type,
    double? value,
    double? minOrderAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        if (code != null) 'code': code,
        if (type != null) 'type': type,
        if (value != null) 'value': value,
        if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (usageLimit != null) 'usageLimit': usageLimit,
        if (applicableProducts != null) 'applicableProducts': applicableProducts,
        if (applicableCategories != null) 'applicableCategories': applicableCategories,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to update discount: $e');
    }
  }

  // Delete discount (Admin only)
  Future<void> deleteDiscount(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to delete discount: $e');
    }
  }

  // Get user's applied discounts
  Future<List<dynamic>> getUserDiscounts() async {
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
      throw Exception('Failed to fetch user discounts: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Discount not found');
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