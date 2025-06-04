// base_service.dart
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:get/get.dart';

// Standardized API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.fromResponse(Response response, {T Function(dynamic)? dataParser}) {
    final statusCode = response.statusCode ?? 0;
    
    // Handle network/connection errors
    if (response.body == null) {
      return ApiResponse<T>(
        success: false,
        error: 'Không thể kết nối đến server',
        statusCode: statusCode,
      );
    }

    // Handle non-JSON responses
    if (response.body is! Map<String, dynamic>) {
      return ApiResponse<T>(
        success: false,
        error: 'Phản hồi từ server không hợp lệ',
        statusCode: statusCode,
      );
    }

    final responseData = response.body as Map<String, dynamic>;
    
    // Check explicit success field
    final success = responseData['success'] as bool?;
    
    if (success == true) {
      // Success response
      T? parsedData;
      if (dataParser != null && responseData['data'] != null) {
        try {
          parsedData = dataParser(responseData['data']);
        } catch (e) {
          return ApiResponse<T>(
            success: false,
            error: 'Lỗi xử lý dữ liệu: $e',
            statusCode: statusCode,
          );
        }
      } else if (responseData.containsKey('paymentUrl')) {
        // Special case for payment URL
        parsedData = responseData['paymentUrl'] as T?;
      }
      
      return ApiResponse<T>(
        success: true,
        data: parsedData,
        message: responseData['message'] as String?,
        statusCode: statusCode,
      );
    } else if (success == false) {
      // Explicit failure
      return ApiResponse<T>(
        success: false,
        message: responseData['message'] as String?,
        error: responseData['error'] as String?,
        statusCode: statusCode,
      );
    } else {
      // No explicit success field - determine by status code
      if (statusCode >= 200 && statusCode < 300) {
        // Assume success for 2xx status codes
        T? parsedData;
        if (dataParser != null && responseData['data'] != null) {
          try {
            parsedData = dataParser(responseData['data']);
          } catch (e) {
            return ApiResponse<T>(
              success: false,
              error: 'Lỗi xử lý dữ liệu: $e',
              statusCode: statusCode,
            );
          }
        }
        
        return ApiResponse<T>(
          success: true,
          data: parsedData,
          statusCode: statusCode,
        );
      } else {
        // Error status codes
        return ApiResponse<T>(
          success: false,
          error: responseData['error'] as String? ?? 
                 responseData['message'] as String? ?? 
                 'Lỗi server không xác định',
          statusCode: statusCode,
        );
      }
    }
  }

  bool get isEmptyData => success && (data == null || (data is List && (data as List).isEmpty));
}

abstract class BaseService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://localhost:1000/api';

    // Request interceptor for auth
    httpClient.addRequestModifier<void>((request) async {
      try {
        final authController = Get.find<AuthController>();
        final token = await authController.getValidToken();
        
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        print("${serviceName} Request: ${request.method} ${request.url}");
        print("${serviceName} Headers: ${request.headers}");
      } catch (e) {
        print('Lỗi khi thêm token vào $serviceName request: $e');
      }
      
      return request;
    });

    // Response interceptor for auth errors
    httpClient.addResponseModifier((request, response) async {
      print('$serviceName Response Status: ${response.statusCode}');
      
      if (response.statusCode == 401) {
        try {
          final authController = Get.find<AuthController>();
          final refreshSuccess = await authController.tryRefreshToken();
          
          if (!refreshSuccess) {
            print('Token hết hạn và không thể refresh, đang logout...');
            await authController.logout();
          }
        } catch (e) {
          print('Lỗi khi xử lý 401 response trong $serviceName: $e');
        }
      }
      
      return response;
    });

    super.onInit();
  }

  // Abstract property for service name (for logging)
  String get serviceName;

  // Ensure user is authenticated
  Future<void> ensureAuthenticated() async {
    try {
      final authController = Get.find<AuthController>();
      
      if (!authController.isLoggedIn.value) {
        throw 'Bạn cần đăng nhập để thực hiện chức năng này.';
      }
      
      final token = await authController.getValidToken();
      if (token == null) {
        throw 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      }
    } catch (e) {
      print('Lỗi authentication check trong $serviceName: $e');
      throw e is String ? e : 'Lỗi xác thực: ${e.toString()}';
    }
  }

  // Ensure user has admin rights
  Future<void> ensureAdminRights() async {
    await ensureAuthenticated();
    
    final authController = Get.find<AuthController>();
    if (!authController.isAdmin) {
      throw 'Bạn không có quyền admin để thực hiện chức năng này.';
    }
  }

  // Standardized error handling
  T handleApiResponse<T>(ApiResponse<T> response, String operation) {
    if (response.success) {
      if (response.isEmptyData) {
        // Return appropriate empty value based on type
        final typeString = T.toString();
        if (typeString.contains('List')) {
          return <dynamic>[] as T;
        }
        throw '${operation}: Không tìm thấy dữ liệu.';
      }
      return response.data as T;
    } else {
      final errorMessage = response.error ?? response.message ?? 'Lỗi không xác định';
      print('$serviceName Error in $operation: $errorMessage (Status: ${response.statusCode})');
      throw errorMessage;
    }
  }

  // Handle list responses (common pattern)
  List<T> handleListResponse<T>(ApiResponse<List<T>> response, String operation) {
    if (response.success) {
      return response.data ?? <T>[];
    } else {
      final errorMessage = response.error ?? response.message ?? 'Lỗi không xác định';
      print('$serviceName Error in $operation: $errorMessage (Status: ${response.statusCode})');
      
      // For list operations, return empty list instead of throwing for certain cases
      if (response.statusCode == 404 || 
          (response.message?.contains('Không tìm thấy đơn hàng') == true)) {
        return <T>[];
      }
      throw errorMessage;
    }
  }
}