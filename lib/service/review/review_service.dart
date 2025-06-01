import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  static const String baseUrl = 'http://localhost:1000/api/reviews';
  String token;

  ReviewService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Create review
  Future<Map<String, dynamic>> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: _headers,
        body: jsonEncode({
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Get product reviews
  Future<List<dynamic>> getProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch product reviews: $e');
    }
  }

  // Get user reviews
  Future<List<dynamic>> getUserReviews() async {
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
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  // Update review
  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/$reviewId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$reviewId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Review not found');
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