import 'dart:io';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:get/get.dart';


class UserService extends GetConnect {
    static const String apiUrl = 'http://localhost:10001000/api/users';
    String token;

    UserService({required this.token});

    void updateToken(String newToken) {
      token = newToken;
    }

    @override
    void onInit() {
      httpClient.baseUrl = 'http://localhost:1000/api';
      super.onInit();
    }

  /// Get all users (Admin only)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await get('/users');
      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['users'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        }
        throw data['message'] ?? 'Lỗi khi lấy danh sách người dùng';
      }
      throw 'Lỗi khi lấy danh sách người dùng';
    } catch (e) {
      throw 'Lỗi khi lấy danh sách người dùng: $e';
    }
  }

  /// Get user information
  Future<User> getUserInfo([String? userId]) async {
    try {
      final String path = userId != null ? '/users/info-user/$userId' : '/users/info-user';
      final response = await get(path);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
        throw data['message'] ?? 'Lỗi khi lấy thông tin người dùng';
      }

      switch (response.statusCode) {
        case 400:
          throw 'ID người dùng không hợp lệ';
        case 401:
          throw 'Vui lòng đăng nhập lại';
        case 403:
          throw 'Bạn không có quyền truy cập';
        case 404:
          throw 'Người dùng không tồn tại';
        default:
          throw 'Lỗi khi lấy thông tin người dùng';
      }
    } catch (e) {
      throw 'Lỗi khi lấy thông tin người dùng: $e';
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? fullname,
    String? phone,
    File? avatar,
  }) async {
    try {
      if (fullname != null && (fullname.length < 2 || fullname.length > 50)) {
        throw 'Họ và tên phải có từ 2 đến 50 ký tự';
      }

      if (phone != null && !RegExp(r'^[0-9]{10,11}$').hasMatch(phone)) {
        throw 'Số điện thoại không hợp lệ';
      }

      final form = FormData({
        if (fullname != null) 'fullname': fullname,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': MultipartFile(avatar.path, filename: avatar.path.split('/').last),
      });

      final response = await post(
        '/users/info-user/update',
        form,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
        throw data['message'] ?? 'Lỗi khi cập nhật thông tin';
      }

      switch (response.statusCode) {
        case 400:
          throw 'Thông tin không hợp lệ';
        case 401:
          throw 'Vui lòng đăng nhập lại';
        case 413:
          throw 'Kích thước ảnh quá lớn. Tối đa 5MB';
        default:
          throw 'Lỗi khi cập nhật thông tin';
      }
    } catch (e) {
      throw 'Lỗi khi cập nhật thông tin: $e';
    }
  }

  /// Update user by ID (Admin only)
  Future<User> updateUserById(
    String userId, {
    String? fullname,
    String? phone,
    File? avatar,
    bool? isActive,
  }) async {
    try {
      if (fullname != null && (fullname.length < 2 || fullname.length > 50)) {
        throw 'Họ và tên phải có từ 2 đến 50 ký tự';
      }

      if (phone != null && !RegExp(r'^[0-9]{10,11}$').hasMatch(phone)) {
        throw 'Số điện thoại không hợp lệ';
      }

      final form = FormData({
        if (fullname != null) 'fullname': fullname,
        if (phone != null) 'phone': phone,
        if (isActive != null) 'isActive': isActive,
        if (avatar != null) 'avatar': MultipartFile(avatar.path, filename: avatar.path.split('/').last),
      });

      final response = await post(
        '/users/info-user/update/$userId',
        form,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
        throw data['message'] ?? 'Lỗi khi cập nhật người dùng';
      }

      switch (response.statusCode) {
        case 400:
          throw 'ID người dùng không hợp lệ';
        case 401:
          throw 'Vui lòng đăng nhập lại';
        case 403:
          throw 'Bạn không có quyền cập nhật';
        case 404:
          throw 'Người dùng không tồn tại';
        default:
          throw 'Lỗi khi cập nhật người dùng';
      }
    } catch (e) {
      throw 'Lỗi khi cập nhật người dùng: $e';
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw 'Mật khẩu xác nhận không khớp';
      }

      if (!_isStrongPassword(newPassword)) {
        throw 'Mật khẩu ít nhất 8 ký tự bao gồm chữ thường, in hoa, số';
      }

      final response = await post(
        '/users/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] != true) {
          throw data['message'] ?? 'Lỗi khi đổi mật khẩu';
        }
        return;
      }

      switch (response.statusCode) {
        case 400:
          throw 'Mật khẩu cũ không đúng';
        case 401:
          throw 'Vui lòng đăng nhập lại';
        default:
          throw 'Lỗi khi đổi mật khẩu';
      }
    } catch (e) {
      throw 'Lỗi khi đổi mật khẩu: $e';
    }
  }

  /// Reset password using OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw 'Mật khẩu xác nhận không khớp';
      }

      if (!_isStrongPassword(newPassword)) {
        throw 'Mật khẩu ít nhất 8 ký tự bao gồm chữ thường, in hoa, số';
      }

      final response = await post(
        '/users/reset-password',
        {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] != true) {
          throw data['message'] ?? 'Lỗi khi đặt lại mật khẩu';
        }
        return;
      }

      switch (response.statusCode) {
        case 400:
          throw 'Mã OTP không hợp lệ hoặc đã hết hạn';
        case 404:
          throw 'Người dùng không tồn tại';
        default:
          throw 'Lỗi khi đặt lại mật khẩu';
      }
    } catch (e) {
      throw 'Lỗi khi đặt lại mật khẩu: $e';
    }
  }

  /// Delete user (Admin only)
  Future<void> deleteUser(String userId) async {
    try {
      final response = await post(
        '/users/delete',
        {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['success'] != true) {
          throw data['message'] ?? 'Lỗi khi xóa người dùng';
        }
        return;
      }

      switch (response.statusCode) {
        case 400:
          throw 'ID người dùng không hợp lệ';
        case 401:
          throw 'Vui lòng đăng nhập lại';
        case 403:
          throw 'Bạn không có quyền xóa người dùng';
        case 404:
          throw 'Người dùng không tồn tại';
        default:
          throw 'Lỗi khi xóa người dùng';
      }
    } catch (e) {
      throw 'Lỗi khi xóa người dùng: $e';
    }
  }

  // Helper method to validate password strength
  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }
} 