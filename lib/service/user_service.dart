import 'dart:io';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:get/get.dart';

class UserService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://localhost:1000/api'; // Base URL

    // Interceptor để tự động thêm token vào headers
    httpClient.addRequestModifier<void>((request) async {
      try {
        final authController = Get.find<AuthController>();
        
        // Lấy token hợp lệ (tự động refresh nếu cần)
        final token = await authController.getValidToken();
        
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        print("UserService Request: ${request.method} ${request.url}");
        print("UserService Headers: ${request.headers}");
        
        if (request.method != 'GET') {
          print("UserService Request Body: (FormData or JSON)");
        }
      } catch (e) {
        print('Lỗi khi thêm token vào request: $e');
        // Không throw error ở đây để request vẫn tiếp tục
      }
      
      return request;
    });

    // Interceptor để xử lý response và lỗi token
    httpClient.addResponseModifier((request, response) async {
      print('UserService Response Status: ${response.statusCode}');
      
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
          print('Lỗi khi xử lý 401 response: $e');
        }
      }
      
      return response;
    });

    super.onInit();
  }

  // Helper để xử lý lỗi chung từ API
  void _handleResponseError(Response response, String defaultMessage) {
    print('Error Response Status: ${response.statusCode}');
    print('Error Response Body: ${response.bodyString}');
    
    if (response.body != null && response.body is Map<String, dynamic>) {
      final errorData = response.body as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? 
                      errorData['error'] as String? ?? 
                      defaultMessage;
      throw message;
    }
    throw defaultMessage;
  }

  // Helper để kiểm tra token trước khi gọi API
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
      print('Lỗi authentication check: $e');
      throw e is String ? e : 'Lỗi xác thực: ${e.toString()}';
    }
  }

  /// Lấy tất cả người dùng (Admin only)
  /// Backend: GET /users
  Future<List<User>> getAllUsers() async {
    try {
      await _ensureAuthenticated();
      
      final response = await get('/users');

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['users'] is List) {
          final List<dynamic> usersJson = data['users'] as List<dynamic>;
          return usersJson
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server.');
      }
      _handleResponseError(response, 'Lỗi khi lấy danh sách người dùng.');
      return []; // Không bao giờ đạt được vì throw ở trên
    } catch (e) {
      print('Lỗi trong UserService.getAllUsers: $e');
      throw e is String ? e : 'Không thể lấy danh sách người dùng: ${e.toString()}';
    }
  }

  /// Lấy thông tin người dùng
  /// Backend: GET /users/info-user (cho user hiện tại)
  /// Backend: GET /users/info-user/:id (cho user cụ thể bởi admin)
  Future<User> getUserInfo([String? userId]) async {
    try {
      await _ensureAuthenticated();
      
      final endpoint = userId == null ? '/users/info-user' : '/users/info-user/$userId';
      final response = await get(endpoint);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['user'] != null) {
          return User.fromJson(data['user'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Định dạng dữ liệu người dùng không đúng từ server.');
      }
      _handleResponseError(response, 'Không thể lấy thông tin người dùng.');
      throw 'Lỗi không xác định khi lấy thông tin người dùng';
    } catch (e) {
      print('Lỗi trong UserService.getUserInfo: $e');
      throw e is String ? e : 'Lỗi khi lấy thông tin người dùng: ${e.toString()}';
    }
  }

  /// Cập nhật thông tin người dùng
  /// Backend: PATCH /users/info-user/update (cho user hiện tại)
  /// Backend: PATCH /users/info-user/update/:id (cho user cụ thể bởi admin)
  Future<User> updateUserProfile({
    String? userIdToUpdate,
    String? fullname,
    String? phone,
    String? gender,
    String? dateBirth, // Format: "YYYY-MM-DD"
    File? avatar,
    bool? isAdmin, // Chỉ admin mới được set
    bool? isActive, // Chỉ admin mới được set
  }) async {
    try {
      await _ensureAuthenticated();
      
      final formData = FormData({});

      // Thêm các trường thông tin cơ bản
      if (fullname != null) formData.fields.add(MapEntry('fullname', fullname));
      if (phone != null) formData.fields.add(MapEntry('phone', phone));
      if (gender != null) formData.fields.add(MapEntry('gender', gender));
      if (dateBirth != null) formData.fields.add(MapEntry('dateBirth', dateBirth));

      // Kiểm tra quyền admin trước khi gửi các trường đặc biệt
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      
      if (currentUser?.isAdmin == true) {
        if (isAdmin != null) formData.fields.add(MapEntry('isAdmin', isAdmin.toString()));
        if (isActive != null) formData.fields.add(MapEntry('isActive', isActive.toString()));
      }

      // Thêm avatar nếu có
      if (avatar != null) {
        formData.files.add(MapEntry(
          'avatar',
          MultipartFile(avatar.path, filename: avatar.path.split('/').last),
        ));
      }

      print('UserService updating profile for user: ${userIdToUpdate ?? 'current'}');
      print('FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');

      final endpoint = userIdToUpdate == null
          ? '/users/info-user/update'
          : '/users/info-user/update/$userIdToUpdate';
          
      final response = await patch(endpoint, formData);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['user'] != null) {
          final updatedUser = User.fromJson(data['user'] as Map<String, dynamic>);
          
          // Cập nhật user hiện tại trong AuthController nếu cập nhật chính mình
          if (userIdToUpdate == null || userIdToUpdate == currentUser?.id) {
            authController.currentUser.value = updatedUser;
          }
          
          return updatedUser;
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server sau khi cập nhật.');
      }
      _handleResponseError(response, 'Lỗi khi cập nhật hồ sơ.');
      throw 'Lỗi không xác định khi cập nhật hồ sơ';
    } catch (e) {
      print('Lỗi trong UserService.updateUserProfile: $e');
      throw e is String ? e : 'Lỗi khi cập nhật hồ sơ: ${e.toString()}';
    }
  }

  /// Đổi mật khẩu (cho người dùng đã đăng nhập)
  /// Backend: PATCH /users/change-password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _ensureAuthenticated();
      
      // Client-side validation
      if (newPassword != confirmPassword) {
        throw 'Mật khẩu xác nhận không khớp.';
      }
      
      if (newPassword.length < 6) {
        throw 'Mật khẩu mới phải có ít nhất 6 ký tự.';
      }

      final response = await patch(
        '/users/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
        _handleResponseError(response, 'Lỗi không xác định khi đổi mật khẩu.');
      }
      _handleResponseError(response, 'Lỗi khi đổi mật khẩu.');
    } catch (e) {
      print('Lỗi trong UserService.changePassword: $e');
      throw e is String ? e : 'Đã xảy ra lỗi khi cố gắng đổi mật khẩu: ${e.toString()}';
    }
  }

  /// Đặt lại mật khẩu (public, sau khi xác minh OTP)
  /// Backend: PATCH /users/reset-password
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Client-side validation
      if (newPassword != confirmPassword) {
        throw 'Mật khẩu xác nhận không khớp.';
      }
      
      if (newPassword.length < 6) {
        throw 'Mật khẩu mới phải có ít nhất 6 ký tự.';
      }

      final response = await patch(
        '/users/reset-password',
        {
          'email': email,
          'otp': otp,
          'password': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
        _handleResponseError(response, 'Lỗi không xác định khi đặt lại mật khẩu.');
      }
      _handleResponseError(response, 'Lỗi khi đặt lại mật khẩu.');
    } catch (e) {
      print('Lỗi trong UserService.resetPassword: $e');
      throw e is String ? e : 'Đã xảy ra lỗi khi cố gắng đặt lại mật khẩu: ${e.toString()}';
    }
  }

  /// Xóa người dùng bởi Admin
  /// Backend: DELETE /users/delete
  Future<void> deleteUserByAdmin(String userIdToDelete) async {
    try {
      await _ensureAuthenticated();
      
      // Kiểm tra quyền admin
      final authController = Get.find<AuthController>();
      if (!authController.isAdmin) {
        throw 'Bạn không có quyền thực hiện chức năng này.';
      }

      final response = await delete(
        '/users/delete',
        query: {'userId': userIdToDelete},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
        _handleResponseError(response, 'Lỗi không xác định khi xóa người dùng.');
      }
      _handleResponseError(response, 'Lỗi khi xóa người dùng.');
    } catch (e) {
      print('Lỗi trong UserService.deleteUserByAdmin: $e');
      throw e is String ? e : 'Đã xảy ra lỗi khi cố gắng xóa người dùng: ${e.toString()}';
    }
  }

  /// Upload avatar riêng biệt
  Future<String> uploadAvatar(File avatarFile) async {
    try {
      await _ensureAuthenticated();
      
      final formData = FormData({
        'avatar': MultipartFile(
          avatarFile.path, 
          filename: avatarFile.path.split('/').last
        ),
      });

      final response = await post('/users/upload-avatar', formData);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['avatarUrl'] != null) {
          return data['avatarUrl'] as String;
        }
        _handleResponseError(response, 'Định dạng response không đúng sau khi upload avatar.');
      }
      _handleResponseError(response, 'Lỗi khi upload avatar.');
      throw 'Lỗi không xác định khi upload avatar';
    } catch (e) {
      print('Lỗi trong UserService.uploadAvatar: $e');
      throw e is String ? e : 'Lỗi khi upload avatar: ${e.toString()}';
    }
  }

  /// Kiểm tra trạng thái kết nối với server
  Future<bool> checkServerConnection() async {
    try {
      final response = await get('/health', 
        decoder: null, // Không decode JSON
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi kiểm tra kết nối server: $e');
      return false;
    }
  }
}