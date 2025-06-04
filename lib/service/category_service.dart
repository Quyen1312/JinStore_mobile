import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'http://localhost:1000/api/categories';
  String token;

  CategoryService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Get all categories
  Future<List<dynamic>> getAllCategories() async {
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
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch category details: $e');
    }
  }

  // Create category (Admin only)
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category (Admin only)
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? image,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
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
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category (Admin only)
  Future<void> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Category not found');
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