import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = 'http://localhost:1000/api/products';
  String? token;

  ProductService({this.token});

  void updateToken(String? newToken) {
    token = newToken;
  }

  // Headers
  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all products với error handling tốt hơn
  Future<List<dynamic>> getAllProducts() async {
    try {
      print('[ProductService] Fetching all products from: $baseUrl');
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      print('[ProductService] Response status: ${response.statusCode}');
      print('[ProductService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Kiểm tra cấu trúc response
        if (decodedData is Map<String, dynamic>) {
          // Nếu API trả về object với key 'data'
          if (decodedData.containsKey('data')) {
            final data = decodedData['data'];
            if (data is List) {
              print('[ProductService] Found ${data.length} products');
              return data;
            } else {
              print('[ProductService] Warning: data is not a List, it is: ${data.runtimeType}');
              return [];
            }
          } 
          // Nếu API trả về object với key 'products'
          else if (decodedData.containsKey('products')) {
            final products = decodedData['products'];
            if (products is List) {
              print('[ProductService] Found ${products.length} products');
              return products;
            }
          }
          // Nếu API trả về object với key khác
          else {
            print('[ProductService] Response structure: ${decodedData.keys.toList()}');
            // Thử tìm List trong response
            for (var key in decodedData.keys) {
              if (decodedData[key] is List) {
                print('[ProductService] Found list at key: $key');
                return decodedData[key] as List;
              }
            }
          }
        } 
        // Nếu API trả về trực tiếp List
        else if (decodedData is List) {
          print('[ProductService] Direct list response with ${decodedData.length} products');
          return decodedData;
        }
        
        print('[ProductService] Unexpected response format');
        return [];
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in getAllProducts: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get product by ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      print('[ProductService] Fetching product by ID: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      print('[ProductService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Nếu API trả về object với key 'data'
        if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          return decodedData['data'] as Map<String, dynamic>;
        }
        // Nếu API trả về trực tiếp product object
        else if (decodedData is Map<String, dynamic>) {
          return decodedData;
        }
        
        throw Exception('Invalid product data format');
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in getProductById: $e');
      throw Exception('Failed to fetch product details: $e');
    }
  }

  // Get products by category
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    try {
      print('[ProductService] Fetching products by category: $categoryId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/category/$categoryId'),
        headers: _headers,
      );

      print('[ProductService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Xử lý tương tự getAllProducts
        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return decodedData['data'] as List;
          } else if (decodedData.containsKey('products') && decodedData['products'] is List) {
            return decodedData['products'] as List;
          }
        } else if (decodedData is List) {
          return decodedData;
        }
        
        return [];
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in getProductsByCategory: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Create product (Admin only)
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    required String description,
    required List<Map<String, dynamic>> images, // Thay đổi từ List<String> thành List<Map>
    required String category,
    required int quantity, // Đổi từ stock sang quantity
    double? discount,
    required String unit,
    List<Map<String, dynamic>>? information,
  }) async {
    try {
      final body = {
        'name': name,
        'price': price,
        'description': description,
        'images': images,
        '_idCategory': category, // Đổi từ category sang _idCategory
        'quantity': quantity, // Đổi từ stock sang quantity
        'unit': unit,
        if (discount != null) 'discount': discount,
        if (information != null) 'information': information,
      };
      
      print('[ProductService] Creating product with body: ${jsonEncode(body)}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      print('[ProductService] Create response status: ${response.statusCode}');
      print('[ProductService] Create response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in createProduct: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product (Admin only)
  Future<Map<String, dynamic>> updateProduct({
    required String id,
    String? name,
    double? price,
    String? description,
    List<Map<String, dynamic>>? images,
    String? category,
    int? quantity,
    double? discount,
    String? unit,
    List<Map<String, dynamic>>? information,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
        if (images != null) 'images': images,
        if (category != null) '_idCategory': category,
        if (quantity != null) 'quantity': quantity,
        if (discount != null) 'discount': discount,
        if (unit != null) 'unit': unit,
        if (information != null) 'information': information,
      };

      print('[ProductService] Updating product $id with: ${jsonEncode(updateData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      print('[ProductService] Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in updateProduct: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (Admin only)
  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      print('[ProductService] Error in deleteProduct: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  // Search products
  Future<List<dynamic>> searchProducts({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (keyword != null) queryParams['keyword'] = keyword;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      print('[ProductService] Searching products with params: $queryParams');
      
      final response = await http.get(uri, headers: _headers);

      print('[ProductService] Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          return decodedData['data'] as List? ?? [];
        } else if (decodedData is List) {
          return decodedData;
        }
        
        return [];
      }

      throw _handleError(response);
    } catch (e) {
      print('[ProductService] Error in searchProducts: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    print('[ProductService] Error response body: ${response.body}');
    
    try {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Unknown error';
      
      if (response.statusCode == 401) {
        return UnauthorizedException(errorMessage);
      } else if (response.statusCode == 403) {
        return ForbiddenException(errorMessage);
      } else if (response.statusCode == 404) {
        return NotFoundException(errorMessage);
      } else {
        return Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Nếu không parse được error message
      if (response.statusCode == 401) {
        return UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 403) {
        return ForbiddenException('Access forbidden');
      } else if (response.statusCode == 404) {
        return NotFoundException('Resource not found');
      } else {
        return Exception('Request failed with status: ${response.statusCode}');
      }
    }
  }
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  
  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}