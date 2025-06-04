import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/discount_model.dart';
import 'package:get/get.dart';

class DiscountService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://localhost:1000/api'; // Base URL chung

    // Interceptor để tự động thêm token vào headers
    httpClient.addRequestModifier<void>((request) async {
      try {
        final authController = Get.find<AuthController>();
        
        // Lấy token hợp lệ (tự động refresh nếu cần)
        final token = await authController.getValidToken();
        
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        print("DiscountService Request: ${request.method} ${request.url}");
        print("DiscountService Headers: ${request.headers}");
      } catch (e) {
        print('Lỗi khi thêm token vào DiscountService request: $e');
        // Không throw error ở đây để request vẫn tiếp tục
      }
      
      return request;
    });

    // Interceptor để xử lý response và lỗi token
    httpClient.addResponseModifier((request, response) async {
      print('DiscountService Response Status: ${response.statusCode}');
      
      // Xử lý lỗi 401 (Unauthorized)
      if (response.statusCode == 401) {
        try {
          final authController = Get.find<AuthController>();
          
          // Thử refresh token
          final refreshSuccess = await authController.tryRefreshToken();
          
          if (!refreshSuccess) {
            // Nếu refresh thất bại, logout user
            print('Token hết hạn và không thể refresh, đang logout...');
            await authController.logout();
          }
        } catch (e) {
          print('Lỗi khi xử lý 401 response trong DiscountService: $e');
        }
      }
      
      return response;
    });

    super.onInit();
  }

  // Helper để xử lý lỗi chung từ API
  void _handleResponseError(Response response, String defaultMessage) {
    print('Error Response Status (DiscountService): ${response.statusCode}');
    print('Error Response Body (DiscountService): ${response.bodyString}');
    if (response.body != null && response.body is Map<String, dynamic>) {
      final errorData = response.body as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? defaultMessage;
      final errField = errorData['err'] as String?; // Backend có thể trả về trường lỗi cụ thể
      if (errField != null) {
        throw '$message (Trường: $errField)';
      }
      throw message;
    }
    throw defaultMessage;
  }

  // Helper để kiểm tra authentication cho các endpoint cần token
  Future<void> _ensureAuthenticated() async {
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
      print('Lỗi authentication check trong DiscountService: $e');
      throw e is String ? e : 'Lỗi xác thực: ${e.toString()}';
    }
  }

  // Helper để kiểm tra quyền admin
  Future<void> _ensureAdminRights() async {
    await _ensureAuthenticated();
    
    final authController = Get.find<AuthController>();
    if (!authController.isAdmin) {
      throw 'Bạn không có quyền admin để thực hiện chức năng này.';
    }
  }

  /// Lấy tất cả các mã giảm giá (Public)
  /// Backend: GET /discounts/all
  Future<List<Discount>> getAllDiscounts() async {
    try {
      final response = await get('/discounts/all');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body; // Backend trả về một mảng trực tiếp
        return data
            .map((json) => Discount.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _handleResponseError(response, 'Lỗi khi lấy danh sách mã giảm giá.');
      return []; // Sẽ không bao giờ đạt đến đây nếu throw ở trên
    } catch (e) {
      print('Lỗi trong DiscountService.getAllDiscounts: $e');
      throw e is String ? e : 'Không thể lấy danh sách mã giảm giá: ${e.toString()}';
    }
  }

  /// Lấy một mã giảm giá cụ thể bằng ID (Public)
  /// Backend: GET /discounts/:id
  Future<Discount> getDiscountById(String discountId) async {
    try {
      final response = await get('/discounts/$discountId');

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic>) {
          return Discount.fromJson(data);
        }
        _handleResponseError(response, 'Định dạng dữ liệu mã giảm giá không đúng.');
      }
      _handleResponseError(response, 'Không thể lấy thông tin mã giảm giá.');
      throw 'Lỗi không xác định khi lấy thông tin mã giảm giá'; // Fallback
    } catch (e) {
      print('Lỗi trong DiscountService.getDiscountById: $e');
      throw e is String ? e : 'Lỗi khi lấy thông tin mã giảm giá: ${e.toString()}';
    }
  }

  /// Lấy tất cả các mã giảm giá khả dụng cho một người dùng cụ thể (User - verifyToken)
  /// Backend: GET /discounts/by-user/:id (đã sửa route)
  Future<List<Discount>> getAvailableDiscountsForUser(String userId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await get('/discounts/by-user/$userId');

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] is List) {
          final List<dynamic> discountsJson = data['data'] as List<dynamic>;
          return discountsJson
              .map((json) => Discount.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        _handleResponseError(response, 'Lỗi khi lấy danh sách mã giảm giá của người dùng từ server.');
      }
      _handleResponseError(response, 'Lỗi khi lấy danh sách mã giảm giá của người dùng.');
      return [];
    } catch (e) {
      print('Lỗi trong DiscountService.getAvailableDiscountsForUser: $e');
      throw e is String ? e : 'Không thể lấy danh sách mã giảm giá của người dùng: ${e.toString()}';
    }
  }

  /// Tạo mã giảm giá mới (Admin only)
  /// Backend: POST /discounts/create
  /// Body: code, type, value (nếu type 'fixed'), maxPercent (nếu type 'percentage'),
  ///       activation, expiration, minOrderAmount, isActive, quantityLimit
  Future<Discount> createDiscount({
    required String code,
    required String type, // 'fixed' hoặc 'percentage'
    double? value, // Cho type 'fixed'
    double? maxPercent, // Cho type 'percentage'
    required String activation, // ISO 8601 String
    required String expiration, // ISO 8601 String
    double? minOrderAmount,
    bool? isActive,
    int? quantityLimit,
  }) async {
    try {
      await _ensureAdminRights();
      
      final Map<String, dynamic> body = {
        'code': code,
        'type': type,
        'activation': activation,
        'expiration': expiration,
      };
      
      if (type == 'fixed' && value != null) {
        body['value'] = value;
      } else if (type == 'percentage' && maxPercent != null) {
        body['maxPercent'] = maxPercent;
      }
      
      if (minOrderAmount != null) body['minOrderAmount'] = minOrderAmount;
      if (isActive != null) body['isActive'] = isActive;
      if (quantityLimit != null) body['quantityLimit'] = quantityLimit;
      
      print("DiscountService createDiscount Body: $body");
      final response = await post('/discounts/create', body);

      if (response.statusCode == 200 || response.statusCode == 201) { // Backend trả về 200 khi thành công
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
          return Discount.fromJson(data['data'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Lỗi khi tạo mã giảm giá từ server.');
      }
      _handleResponseError(response, 'Không thể tạo mã giảm giá.');
      throw 'Lỗi không xác định khi tạo mã giảm giá'; // Fallback
    } catch (e) {
      print('Lỗi trong DiscountService.createDiscount: $e');
      throw e is String ? e : 'Lỗi khi tạo mã giảm giá: ${e.toString()}';
    }
  }

  /// Cập nhật mã giảm giá (Admin only)
  /// Backend: PUT /discounts/:id
  Future<Discount> updateDiscount({
    required String id,
    String? code,
    String? type,
    double? value,
    double? maxPercent,
    String? activation, // ISO 8601 String
    String? expiration, // ISO 8601 String
    double? minOrderAmount,
    bool? isActive,
    int? quantityLimit,
    // quantityUsed thường không được cập nhật trực tiếp qua API này
  }) async {
    try {
      await _ensureAdminRights();
      
      final Map<String, dynamic> updateData = {};
      if (code != null) updateData['code'] = code;
      if (type != null) updateData['type'] = type;
      if (value != null) updateData['value'] = value; // Backend sẽ xử lý dựa trên type
      if (maxPercent != null) updateData['maxPercent'] = maxPercent; // Backend sẽ xử lý dựa trên type
      if (activation != null) updateData['activation'] = activation;
      if (expiration != null) updateData['expiration'] = expiration;
      if (minOrderAmount != null) updateData['minOrderAmount'] = minOrderAmount;
      if (isActive != null) updateData['isActive'] = isActive;
      if (quantityLimit != null) updateData['quantityLimit'] = quantityLimit;

      if (updateData.isEmpty) {
        throw 'Không có thông tin nào để cập nhật cho mã giảm giá.';
      }
      
      print("DiscountService updateDiscount Body: $updateData for ID: $id");
      final response = await put('/discounts/$id', updateData);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic>) { // Backend updateDiscount trả về object discount trực tiếp
          return Discount.fromJson(data);
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server sau khi cập nhật mã giảm giá.');
      }
      _handleResponseError(response, 'Lỗi khi cập nhật mã giảm giá.');
      throw 'Lỗi không xác định khi cập nhật mã giảm giá'; // Fallback
    } catch (e) {
      print('Lỗi trong DiscountService.updateDiscount: $e');
      throw e is String ? e : 'Lỗi khi cập nhật mã giảm giá: ${e.toString()}';
    }
  }

  /// Xóa mã giảm giá (Admin only)
  /// Backend: DELETE /discounts/:id
  Future<void> deleteDiscount(String id) async {
    try {
      await _ensureAdminRights();
      
      final response = await delete('/discounts/$id');

      if (response.statusCode == 200) {
        final data = response.body;
        // Backend deleteDiscount trả về { message: '...' }
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return; // Thành công
        }
        _handleResponseError(response, 'Lỗi không xác định khi xóa mã giảm giá.');
      }
      _handleResponseError(response, 'Lỗi khi xóa mã giảm giá.');
    } catch (e) {
      print('Lỗi trong DiscountService.deleteDiscount: $e');
      throw e is String ? e : 'Lỗi khi xóa mã giảm giá: ${e.toString()}';
    }
  }

  /// Thay đổi trạng thái active của mã giảm giá (Admin only)
  /// Backend: PATCH /discounts/toggle/:id
  Future<Discount> toggleDiscountStatus(String id) async {
    try {
      await _ensureAdminRights();
      
      // Route này không cần body
      final response = await patch('/discounts/toggle/$id', {}); // Gửi body rỗng nếu GetConnect yêu cầu

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic>) { // Backend toggleDiscountStatus trả về object discount đã cập nhật
          return Discount.fromJson(data);
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server sau khi thay đổi trạng thái.');
      }
      _handleResponseError(response, 'Lỗi khi thay đổi trạng thái mã giảm giá.');
      throw 'Lỗi không xác định khi thay đổi trạng thái'; // Fallback
    } catch (e) {
      print('Lỗi trong DiscountService.toggleDiscountStatus: $e');
      throw e is String ? e : 'Lỗi khi thay đổi trạng thái mã giảm giá: ${e.toString()}';
    }
  }

  /// Lấy mã giảm giá khả dụng cho người dùng hiện tại
  Future<List<Discount>> getMyAvailableDiscounts() async {
    try {
      await _ensureAuthenticated();
      
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.id;
      
      if (currentUserId == null) {
        throw 'Không thể xác định người dùng hiện tại.';
      }
      
      return await getAvailableDiscountsForUser(currentUserId);
    } catch (e) {
      print('Lỗi trong DiscountService.getMyAvailableDiscounts: $e');
      throw e is String ? e : 'Lỗi khi lấy mã giảm giá khả dụng: ${e.toString()}';
    }
  }

  // REMOVED: applyDiscount() - Backend không có endpoint này
  // REMOVED: validateDiscountCode() - Backend không có endpoint này
}