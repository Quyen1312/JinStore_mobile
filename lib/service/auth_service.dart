import 'dart:convert';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Custom Exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class AuthService extends GetxService {
  // Sử dụng FlutterSecureStorage cho tất cả token để bảo mật tốt hơn
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Sử dụng localhost như yêu cầu
  static const String _baseUrl = 'http://localhost:1000/api';
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // ✅ FIX: Request queue để tránh multiple refresh calls
  bool _isRefreshing = false;
  final List<Function> _requestQueue = [];

  // Headers cơ bản
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // Headers kèm Authorization token
  Future<Map<String, String>> get _secureHeaders async {
    final token = await getValidAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============= JWT HELPER METHODS =============

  /// ✅ FIX: Decode JWT để lấy expiry time thực tế
  Map<String, dynamic>? _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (part 1)
      final payload = parts[1];
      
      // Add padding if needed
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);
      
      return jsonDecode(decodedPayload) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Lỗi decode JWT: $e');
      return null;
    }
  }

  /// ✅ FIX: Kiểm tra token expired dựa trên JWT exp claim
  bool _isTokenExpired(String token) {
    final payload = _decodeJWT(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    // Thêm buffer 30 giây để tránh edge case
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final bufferTime = DateTime.now().add(const Duration(seconds: 30));
    
    final isExpired = bufferTime.isAfter(expiryTime);
    if (isExpired) {
      print('🔴 Token expired: ${expiryTime.toIso8601String()}');
    }
    
    return isExpired;
  }

  // ============= TOKEN MANAGEMENT =============

  /// ✅ FIX: Lưu access token (không cần tính expiry local)
  Future<void> _saveAccessToken(String token) async {
    // Validate token trước khi save
    final payload = _decodeJWT(token);
    if (payload == null) {
      throw Exception('Token không hợp lệ');
    }
    
    await _storage.write(key: _accessTokenKey, value: token);
    print('✅ Đã lưu access token, expires: ${DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000)}');
  }

  /// ✅ FIX: Lấy access token và kiểm tra expiry từ JWT
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null) return null;

    // Kiểm tra expiry từ JWT payload
    if (_isTokenExpired(token)) {
      print('🔴 Access token đã hết hạn');
      await _deleteAccessToken();
      return null;
    }

    return token;
  }

  /// Kiểm tra access token có hợp lệ không
  Future<bool> isAccessTokenValid() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Xóa access token
  Future<void> _deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Lưu refresh token
  Future<void> _saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Xóa refresh token
  Future<void> _deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Lưu thông tin user
  Future<void> _saveUserData(User user) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
  }

  /// Lấy thông tin user đã lưu
  Future<User?> getSavedUserData() async {
    final userDataString = await _storage.read(key: _userDataKey);
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      } catch (e) {
        print('Lỗi parse user data: $e');
        await _storage.delete(key: _userDataKey);
      }
    }
    return null;
  }

  /// Kiểm tra người dùng đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null || refreshToken != null;
  }

  // ============= API METHODS =============

  /// Đăng ký người dùng mới
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/register'),
        headers: _headers,
        body: jsonEncode({
          'fullname': fullname,
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      }
      throw _handleError(response, "Đăng ký thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.register: $e');
      throw e is String ? e : 'Đăng ký thất bại: ${e.toString()}';
    }
  }

  /// ✅ FIX: Đăng nhập người dùng
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/login'),
        headers: _headers,
        body: jsonEncode({
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ FIX: Lưu access token (không cần expiresIn)
        if (data['accessToken'] != null) {
          await _saveAccessToken(data['accessToken'] as String);
        }

        // Lưu refresh token nếu có
        if (data['refreshToken'] != null) {
          await _saveRefreshToken(data['refreshToken'] as String);
        }

        // Lưu thông tin user nếu có
        if (data['_id'] != null) {
          final userData = Map<String, dynamic>.from(data);
          userData.remove('accessToken');
          userData.remove('refreshToken');
          
          final user = User.fromJson(userData);
          await _saveUserData(user);
        }

        print('✅ Đăng nhập thành công');
        return data;
      }
      throw _handleError(response, "Đăng nhập thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.login: $e');
      throw e is String ? e : 'Đăng nhập thất bại: ${e.toString()}';
    }
  }

  /// ✅ FIX: Làm mới Access Token với request queuing
  Future<Map<String, dynamic>> refreshToken() async {
    // Nếu đang refresh, wait cho kết quả
    if (_isRefreshing) {
      print('⏳ Đang refresh token, chờ...');
      return await _waitForRefresh();
    }

    _isRefreshing = true;
    
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedException('Không tìm thấy Refresh Token.');
      }

      print('🔄 Bắt đầu refresh token...');
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/refresh'),
        headers: _headers,
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Lưu access token mới
        if (data['accessToken'] != null) {
          await _saveAccessToken(data['accessToken'] as String);
        } else {
          throw Exception('Token mới không hợp lệ.');
        }

        // ✅ Lưu refresh token mới nếu có
        if (data['refreshToken'] != null) {
          await _saveRefreshToken(data['refreshToken'] as String);
        }

        print('✅ Refresh token thành công');
        
        // Process queued requests
        _processRequestQueue();
        
        return data;
      }

      throw _handleError(response, "Làm mới token thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.refreshToken: $e');
      await clearAuthData(); // Xóa local token
      _processRequestQueue(); // Process với null result
      throw e is String
          ? e
          : 'Làm mới token thất bại, vui lòng đăng nhập lại: ${e.toString()}';
    } finally {
      _isRefreshing = false;
    }
  }

  /// ✅ Helper method để wait for refresh completion
  Future<Map<String, dynamic>> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Check if we have valid token after refresh
    final token = await getAccessToken();
    if (token != null) {
      return {'accessToken': token};
    } else {
      throw UnauthorizedException('Refresh token thất bại');
    }
  }

  /// ✅ Process queued requests
  void _processRequestQueue() {
    for (final callback in _requestQueue) {
      callback();
    }
    _requestQueue.clear();
  }

  /// ✅ FIX: Tự động refresh token nếu cần với proper queuing
  Future<String?> getValidAccessToken() async {
    final token = await getAccessToken();
    if (token != null) return token;

    // Nếu đang refresh, wait
    if (_isRefreshing) {
      try {
        await _waitForRefresh();
        return await getAccessToken();
      } catch (e) {
        return null;
      }
    }

    // Thử refresh
    try {
      final refreshResult = await refreshToken();
      return refreshResult['accessToken'] as String?;
    } catch (e) {
      print('❌ Không thể refresh token: $e');
      return null;
    }
  }

  /// ✅ FIX: Authorized request với auto retry
  Future<http.Response> makeAuthorizedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
    int maxRetries = 1,
  }) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        final token = await getValidAccessToken();
        if (token == null) {
          throw UnauthorizedException('Không có access token hợp lệ.');
        }

        final uri = Uri.parse('$_baseUrl$endpoint');
        final combinedHeaders = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          ...?headers,
        };

        http.Response response;
        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(uri, headers: combinedHeaders, body: jsonEncode(body))
                .timeout(const Duration(seconds: 30));
            break;
          case 'PUT':
            response = await http.put(uri, headers: combinedHeaders, body: jsonEncode(body))
                .timeout(const Duration(seconds: 30));
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: combinedHeaders)
                .timeout(const Duration(seconds: 30));
            break;
          default:
            response = await http.get(uri, headers: combinedHeaders)
                .timeout(const Duration(seconds: 30));
        }

        // Nếu 401 và còn retry, thử refresh và retry
        if (response.statusCode == 401 && retryCount < maxRetries) {
          print('🔄 401 error, thử refresh token và retry...');
          await _deleteAccessToken(); // Force refresh next time
          retryCount++;
          continue;
        }

        return response;
      } catch (e) {
        if (retryCount >= maxRetries) rethrow;
        retryCount++;
        print('⚠️ Request failed, retry $retryCount/$maxRetries: $e');
      }
    }
    
    throw Exception('Request failed after $maxRetries retries');
  }

  /// ✅ FIXED: Đăng nhập với Google - Return User object
  Future<User> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/google-login'),
        headers: _headers,
        body: jsonEncode({
          'idToken': idToken,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Lưu access token
        if (data['accessToken'] != null) {
          await _saveAccessToken(data['accessToken'] as String);
        }

        // Lưu refresh token nếu có
        if (data['refreshToken'] != null) {
          await _saveRefreshToken(data['refreshToken'] as String);
        }

        // ✅ FIXED: Parse user data và return User object
        if (data['_id'] != null) {
          final userData = Map<String, dynamic>.from(data);
          userData.remove('accessToken');
          userData.remove('refreshToken');
          
          final user = User.fromJson(userData);
          await _saveUserData(user);
          
          print('✅ Google login thành công: ${user.email}');
          // ✅ Return User object thay vì Map
          return user;
        } else {
          throw Exception('Invalid user data from backend');
        }
      }
      throw _handleError(response, "Đăng nhập Google thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.loginWithGoogle: $e');
      throw e is String ? e : 'Đăng nhập Google thất bại: ${e.toString()}';
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    try {
      final userData = await getSavedUserData();
      
      // Nếu có user data, gọi API logout
      if (userData != null && userData.id != null) {
        try {
          final response = await makeAuthorizedRequest(
            '/mobile/logout',
            method: 'POST',
            body: {'userId': userData.id},
          );

          if (response.statusCode != 200) {
            print('⚠️ Logout API thất bại: ${response.statusCode}');
          }
        } catch (e) {
          print('⚠️ Logout API error: $e');
        }
      }
      
      // Luôn xóa token local
      await clearAuthData();
      print('✅ Đăng xuất thành công');
    } catch (e) {
      print('❌ Lỗi AuthService.logout: $e');
      // Ngay cả khi logout API lỗi, vẫn xóa token local
      await clearAuthData();
      throw e is String ? e : 'Đăng xuất thất bại: ${e.toString()}';
    }
  }

  /// Lấy thông tin hồ sơ người dùng hiện tại
  Future<User> getProfile() async {
    try {
      final response = await makeAuthorizedRequest('/users/info-user'); // ✅ FIX: đúng endpoint path

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ FIX: Backend có thể trả về format khác
        User user;
        if (data['success'] == true && data['data'] != null) {
          // Format: {success: true, data: {...}}
          user = User.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['_id'] != null) {
          // Format trực tiếp: {_id: ..., fullname: ...}
          user = User.fromJson(data as Map<String, dynamic>);
        } else {
          throw 'Định dạng response không đúng.';
        }
        
        // Cập nhật user data local
        await _saveUserData(user);
        return user;
      }
      throw _handleError(response, "Không thể lấy thông tin hồ sơ");
    } catch (e) {
      print('❌ Lỗi AuthService.getProfile: $e');
      throw e is String ? e : 'Không thể lấy thông tin hồ sơ: ${e.toString()}';
    }
  }

  /// Cập nhật hồ sơ người dùng
  Future<User> updateProfile({
    String? fullname,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, String>{};
      if (fullname != null) body['fullname'] = fullname;
      if (email != null) body['email'] = email;
      if (avatarUrl != null) body['avatar'] = avatarUrl;

      final response = await makeAuthorizedRequest(
        '/users/info-user/update', // ✅ FIX: đúng endpoint path
        method: 'PATCH', // ✅ FIX: đúng HTTP method
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ FIX: Handle different response formats
        User user;
        if (data['success'] == true && data['data'] != null) {
          user = User.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['_id'] != null) {
          user = User.fromJson(data as Map<String, dynamic>);
        } else {
          throw data['message'] as String? ?? 'Cập nhật hồ sơ thất bại.';
        }
        
        // Cập nhật user data local
        await _saveUserData(user);
        return user;
      }
      throw _handleError(response, "Cập nhật hồ sơ thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.updateProfile: $e');
      throw e is String ? e : 'Cập nhật hồ sơ thất bại: ${e.toString()}';
    }
  }

  /// Đổi mật khẩu (cho người dùng đã đăng nhập)
  Future<void> changePasswordAuth({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await makeAuthorizedRequest(
        '/user/change-password', // ✅ FIX: đúng endpoint path
        method: 'PATCH', // ✅ FIX: đúng HTTP method
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ FIX: Handle different response formats
        if (data['success'] == true || data['message']?.toString().toLowerCase().contains('thành công') == true) {
          return;
        }
        throw data['message'] as String? ?? 'Đổi mật khẩu thất bại.';
      }
      throw _handleError(response, "Đổi mật khẩu thất bại");
    } catch (e) {
      print('❌ Lỗi AuthService.changePasswordAuth: $e');
      throw e is String ? e : 'Đổi mật khẩu thất bại: ${e.toString()}';
    }
  }

  /// Xóa tất cả dữ liệu xác thực phía client
  Future<void> clearAuthData() async {
    await _deleteAccessToken();
    await _deleteRefreshToken();
    await _storage.delete(key: _userDataKey);
  }

  /// Kiểm tra và làm sạch dữ liệu hết hạn
  Future<void> cleanExpiredData() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      // Nếu access token hết hạn và không refresh được, xóa tất cả
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        try {
          await this.refreshToken();
        } catch (e) {
          await clearAuthData();
        }
      }
    }
  }

  // ✅ FIX: Xử lý lỗi từ HTTP response với better logging
  Exception _handleError(http.Response response, String defaultMessage) {
    try {
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'] as String? ?? 
                      responseBody['error'] as String? ?? 
                      defaultMessage;
      final code = responseBody['code'] as String?;

      print('❌ API Error: ${response.statusCode} - $message');

      switch (response.statusCode) {
        case 400:
          return Exception('$message (Code: ${code ?? 'BAD_REQUEST'})');
        case 401:
          return UnauthorizedException('$message (Code: ${code ?? 'UNAUTHORIZED'})');
        case 403:
          return ForbiddenException('$message (Code: ${code ?? 'FORBIDDEN'})');
        case 404:
          return NotFoundException('$message (Code: ${code ?? 'NOT_FOUND'})');
        default:
          return Exception(
              '$defaultMessage (Status: ${response.statusCode}, Message: $message, Code: ${code ?? 'UNKNOWN'})');
      }
    } catch (e) {
      print('❌ Parse error response failed: $e');
      return Exception(
          '$defaultMessage (Status: ${response.statusCode}, không thể parse error body)');
    }
  }
}