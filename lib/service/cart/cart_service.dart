import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl = 'http://localhost:1000/api/cart';
  String token;

  CartService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Get user's cart
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: _headers,
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update'),
        headers: _headers,
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  Future<void> removeCartItem(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove/$productId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clear'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Cart not found');
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