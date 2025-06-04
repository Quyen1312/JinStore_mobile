import 'package:get/get.dart';

class ProductService extends GetConnect {
  String? token;

  ProductService({this.token}) {
    _configureClient();
  }

  void _configureClient() {
    // Base URL configuration
    httpClient.baseUrl = 'http://localhost:1000/api';
    
    // Default headers
    httpClient.defaultContentType = 'application/json';
    
    // Request interceptor
    httpClient.addRequestModifier<dynamic>((request) {
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      print('[ProductService] 📤 ${request.method} ${request.url}');
      if (request.headers.containsKey('Authorization')) {
        print('[ProductService] 🔐 Token: ${request.headers['Authorization']?.substring(0, 20)}...');
      }
      return request;
    });

    // Response interceptor
    httpClient.addResponseModifier((request, response) {
      print('[ProductService] 📥 ${response.statusCode} ${request.url}');
      print('[ProductService] 📥 Response body type: ${response.body.runtimeType}');
      
      // Log first 500 characters of response for debugging
      final responseStr = response.body.toString();
      if (responseStr.length > 500) {
        print('[ProductService] 📥 Response preview: ${responseStr.substring(0, 500)}...');
      } else {
        print('[ProductService] 📥 Response: $responseStr');
      }
      
      return response;
    });
  }

  void updateToken(String? newToken) {
    token = newToken;
    _configureClient(); // Reconfigure with new token
  }

  /// ✅ Get all products with better error handling
  Future<List<dynamic>> getAllProducts() async {
    try {
      print('[ProductService] 🔍 Fetching all products...');
      
      final response = await get('/products');
      print('[ProductService] 📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.body;
        
        // Handle different response formats
        if (responseData is List) {
          print('[ProductService] ✅ Direct list response: ${responseData.length} products');
          return responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Try different possible keys for the product list
          final possibleKeys = ['data', 'products', 'items', 'result', 'results'];
          
          for (String key in possibleKeys) {
            if (responseData.containsKey(key) && responseData[key] is List) {
              final products = responseData[key] as List;
              print('[ProductService] ✅ Found products at key "$key": ${products.length} items');
              return products;
            }
          }
          
          // If no list found, log the structure and return empty
          print('[ProductService] ⚠️ Response keys: ${responseData.keys.toList()}');
          print('[ProductService] ⚠️ No product list found in response');
          return [];
        }
        
        print('[ProductService] ❌ Unexpected response format: ${responseData.runtimeType}');
        return [];
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('[ProductService] ❌ Error in getAllProducts: $e');
      rethrow;
    }
  }

  /// ✅ Get product by ID with improved handling
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      print('[ProductService] 🔍 Fetching product by ID: $id');
      
      if (id.trim().isEmpty) {
        throw Exception('Product ID cannot be empty');
      }

      final response = await get('/products/$id');
      print('[ProductService] 📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.body;
        
        if (responseData is Map<String, dynamic>) {
          // Check for wrapped response
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            if (data is Map<String, dynamic>) {
              print('[ProductService] ✅ Product found (wrapped): ${data['name'] ?? 'Unknown'}');
              return data;
            }
          }
          // Check for direct product object
          else if (responseData.containsKey('_id') || responseData.containsKey('id')) {
            print('[ProductService] ✅ Product found (direct): ${responseData['name'] ?? 'Unknown'}');
            return responseData;
          }
          // Check for other possible wrappers
          else if (responseData.containsKey('product')) {
            final product = responseData['product'];
            if (product is Map<String, dynamic>) {
              print('[ProductService] ✅ Product found (product wrapper): ${product['name'] ?? 'Unknown'}');
              return product;
            }
          }
        }
        
        throw Exception('Invalid product data format received');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('[ProductService] ❌ Error in getProductById: $e');
      rethrow;
    }
  }

  /// ✅ Search products with multiple endpoint attempts
  Future<List<dynamic>> searchProducts({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('[ProductService] 🔍 Searching products...');
      print('[ProductService] 📝 Search params:');
      print('  - keyword: $keyword');
      print('  - category: $category');
      print('  - minPrice: $minPrice');
      print('  - maxPrice: $maxPrice');

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      
      if (keyword != null && keyword.trim().isNotEmpty) {
        // Try different parameter names that APIs commonly use
        queryParams['q'] = keyword.trim();
        queryParams['search'] = keyword.trim();
        queryParams['keyword'] = keyword.trim();
        queryParams['name'] = keyword.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
        queryParams['categoryId'] = category.trim();
      }
      if (minPrice != null && minPrice > 0) {
        queryParams['minPrice'] = minPrice;
      }
      if (maxPrice != null && maxPrice > 0) {
        queryParams['maxPrice'] = maxPrice;
      }
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParams['sortBy'] = sortBy.trim();
      }
      if (sortOrder != null && sortOrder.trim().isNotEmpty) {
        queryParams['sortOrder'] = sortOrder.trim();
      }

      Response? response;
      
      // Try different search endpoints
      final searchEndpoints = [
        '/products/search',
        '/products',
        '/search/products',
      ];

      for (String endpoint in searchEndpoints) {
        try {
          print('[ProductService] 🎯 Trying endpoint: $endpoint');
          
          if (queryParams.isNotEmpty) {
            response = await get(endpoint, query: queryParams);
          } else {
            response = await get(endpoint);
          }
          
          print('[ProductService] 📊 Response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            break; // Success, exit loop
          } else if (response.statusCode == 404) {
            print('[ProductService] ⚠️ Endpoint $endpoint not found, trying next...');
            continue; // Try next endpoint
          } else {
            throw _handleError(response);
          }
        } catch (e) {
          print('[ProductService] ❌ Error with endpoint $endpoint: $e');
          if (endpoint == searchEndpoints.last) {
            rethrow; // Last endpoint, rethrow error
          }
          continue; // Try next endpoint
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('All search endpoints failed');
      }

      final dynamic responseData = response.body;
      
      if (responseData is List) {
        print('[ProductService] ✅ Search results (direct): ${responseData.length} products');
        return responseData;
      } else if (responseData is Map<String, dynamic>) {
        // Try different possible keys
        final possibleKeys = ['data', 'products', 'items', 'results', 'result'];
        
        for (String key in possibleKeys) {
          if (responseData.containsKey(key) && responseData[key] is List) {
            final products = responseData[key] as List;
            print('[ProductService] ✅ Search results at "$key": ${products.length} products');
            return products;
          }
        }
        
        print('[ProductService] ⚠️ No search results found in response keys: ${responseData.keys.toList()}');
        return [];
      }
      
      print('[ProductService] ❌ Unexpected search response format: ${responseData.runtimeType}');
      return [];
      
    } catch (e) {
      print('[ProductService] ❌ Error in searchProducts: $e');
      rethrow;
    }
  }

  /// ✅ Get products by category
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    try {
      print('[ProductService] 📂 Fetching products by category: $categoryId');
      
      if (categoryId.trim().isEmpty) {
        throw Exception('Category ID cannot be empty');
      }

      // Try different category endpoints
      final categoryEndpoints = [
        '/products/category/$categoryId',
        '/products?category=$categoryId',
        '/categories/$categoryId/products',
      ];

      Response? response;
      
      for (String endpoint in categoryEndpoints) {
        try {
          print('[ProductService] 🎯 Trying category endpoint: $endpoint');
          response = await get(endpoint);
          
          if (response.statusCode == 200) {
            break;
          } else if (response.statusCode == 404) {
            continue;
          } else {
            throw _handleError(response);
          }
        } catch (e) {
          if (endpoint == categoryEndpoints.last) {
            rethrow;
          }
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('All category endpoints failed');
      }

      final dynamic responseData = response.body;
      
      if (responseData is List) {
        print('[ProductService] ✅ Category products (direct): ${responseData.length} items');
        return responseData;
      } else if (responseData is Map<String, dynamic>) {
        final possibleKeys = ['data', 'products', 'items', 'results'];
        
        for (String key in possibleKeys) {
          if (responseData.containsKey(key) && responseData[key] is List) {
            final products = responseData[key] as List;
            print('[ProductService] ✅ Category products at "$key": ${products.length} items');
            return products;
          }
        }
      }
      
      return [];
    } catch (e) {
      print('[ProductService] ❌ Error in getProductsByCategory: $e');
      rethrow;
    }
  }

  /// ✅ Error handling
  Exception _handleError(Response response) {
    print('[ProductService] ❌ Error response:');
    print('  - Status: ${response.statusCode}');
    print('  - Status Text: ${response.statusText}');
    print('  - Body: ${response.body}');
    
    String errorMessage = 'Request failed';
    
    try {
      if (response.body is Map<String, dynamic>) {
        final errorData = response.body as Map<String, dynamic>;
        errorMessage = errorData['message'] ?? 
                      errorData['error'] ?? 
                      errorData['msg'] ?? 
                      'Unknown error';
      } else if (response.body is String) {
        errorMessage = response.body as String;
      }
    } catch (e) {
      print('[ProductService] ⚠️ Could not parse error message: $e');
    }
    
    switch (response.statusCode) {
      case 401:
        return UnauthorizedException(errorMessage);
      case 403:
        return ForbiddenException(errorMessage);
      case 404:
        return NotFoundException(errorMessage);
      default:
        return Exception('$errorMessage (Status: ${response.statusCode})');
    }
  }

  /// ✅ Test connectivity
  Future<bool> testConnection() async {
    try {
      print('[ProductService] 🏥 Testing connection...');
      final response = await get('/products', 
          query: {'limit': '1'}); // Try to get just 1 product
      
      final isConnected = response.statusCode == 200;
      print('[ProductService] 🏥 Connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
      return isConnected;
    } catch (e) {
      print('[ProductService] 🏥 Connection test failed: $e');
      return false;
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