import 'dart:convert';
import 'package:flutter_application_jin/service/address/address_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';

class AuthService extends GetxService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final String _tokenKey = 'auth_token';
  static const String baseUrl = 'http://localhost:1000/api/auth';
  static const String refreshTokenKey = 'refresh_token';

  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Token management methods
  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> _deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    print('[AuthService] Bắt đầu gọi API login cho: $usernameOrEmail');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'usernameOrEmail': usernameOrEmail, 'password': password}),
      );

      print('[AuthService] API login response status: ${response.statusCode}');
      print('[AuthService] API login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // SỬA Ở ĐÂY: Dùng đúng key "accessToken"
        final tokenFromApi = data['accessToken']; // <--- THAY ĐỔI TỪ 'token' SANG 'accessToken'
        if (tokenFromApi == null || !(tokenFromApi is String) || tokenFromApi.isEmpty) {
          printError(info: '[AuthService] Lỗi: AccessToken không hợp lệ hoặc bị thiếu từ API. AccessToken nhận được: $tokenFromApi');
          throw Exception('AccessToken không hợp lệ hoặc bị thiếu từ phản hồi của server.');
        }

        await _saveToken(tokenFromApi); // _saveToken vẫn nhận token đã được xác thực
        print('[AuthService] AccessToken đã được lưu thành công.');
        
        // Giả sử API trả về cả user object cùng cấp với accessToken
        // hoặc API của bạn trả về cấu trúc {"user": {...}, "accessToken": "..."}
        // Nếu API trả về user object, bạn cũng nên kiểm tra nó ở đây:
        if (data['user'] == null || !(data['user'] is Map<String, dynamic>)) {
            // Nếu user là một phần của JSON response chính, không phải lồng trong 'user' key
            // thì bạn cần điều chỉnh lại cách lấy user data.
            // Dựa trên response body bạn cung cấp, user data nằm cùng cấp với _id, username,...
            // Vậy thì `data` chính là user data, và token nằm trong đó.
            // Chúng ta cần điều chỉnh lại cách AuthController nhận user data.
            // Hiện tại, AuthService trả về toàn bộ `data`.
             print('[AuthService] Cấu trúc user data cần xem lại. Data trả về: $data');
        }
        
        // Trả về toàn bộ `data` bao gồm cả user info và accessToken
        return data; 
      } else {
        // ... (phần xử lý lỗi giữ nguyên) ...
        String errorMessage = 'Đăng nhập không thành công (mã lỗi: ${response.statusCode}).';
        try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
            if (response.body.isNotEmpty) {
              errorMessage += ' Chi tiết: ${response.body}';
            }
        }
        printError(info: '[AuthService] Lỗi API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      printError(info: '[AuthService] Lỗi trong quá trình gọi API login: ${e.toString()}');
      throw Exception('Đăng nhập thất bại. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau. (Chi tiết: ${e.toString()})');
    }
  }

  // Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw UnauthorizedException('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedException('No refresh token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return data;
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _deleteToken();

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Token management
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(refreshTokenKey);
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Resource not found');
    } else {
      return Exception('Failed with status code: ${response.statusCode}');
    }
  }

  // Email verification
  Future<void> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<void> verifyOTP(VerifyOTP verifyOTP) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: _headers,
        body: jsonEncode(verifyOTP.toJson()),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}