import 'dart:convert';

import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository extends GetxService {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<Response> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final isEmail = identifier.contains('@');
      final payload = <String, String>{
        'password': password,
        if (isEmail) 'email': identifier,
        if (!isEmail) 'username': identifier,
      };
      print('payload: $payload');
      final response = await apiClient.postData(ApiConstants.LOGIN, payload);
      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        final token = response.body?['token'];
        if (token != null && token is String) {
          await saveUserToken(token);
        }
      }
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi đăng nhập: ${e.toString()}');
    }
  }

  Future<Response> register(User user) async {
    try {
      return await apiClient.postData(ApiConstants.REGISTER, user.toRegisterJson());
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi đăng ký: ${e.toString()}');
    }
  }

  Future<Response> logout() async {
    try {
      final response = await apiClient.postData(ApiConstants.LOGOUT, {});
      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.NO_CONTENT) {
        await clearToken();
      }
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi đăng xuất: ${e.toString()}');
    }
  }

  Future<Response> changePassword(Map<String, dynamic> passwordData) async {
    try {
      return await apiClient.patchData(ApiConstants.USERS_CHANGE_PASSWORD, passwordData);
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }

  Future<Response> verifyOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      return await apiClient.postData(ApiConstants.OTP_VERIFY, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi xác thực OTP: ${e.toString()}');
    }
  }

  Future<Response> sendOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      return await apiClient.postData(ApiConstants.OTP_SEND, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi gửi OTP: ${e.toString()}');
    }
  }

  Future<bool> saveUserToken(String token) async {
    try {
      apiClient.updateHeader(token);
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(ApiConstants.TOKEN, token);
    } catch (_) {
      return false;
    }
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.TOKEN);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.TOKEN);
    apiClient.updateHeader(''); 
  }

  Future<Response> fetchCurrentUserInfo() async {
    try {
      final response = await apiClient.getData(ApiConstants.USERS_GET_CURRENT_INFO);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  Future<Response> refreshToken() async { 
    try {
      final response = await apiClient.postData(ApiConstants.REFRESH_TOKEN, {}); 
      if (response.statusCode == ApiConstants.SUCCESS) {
        final newAccessToken = response.body?['token']; 
        if (newAccessToken != null && newAccessToken is String) {
          await saveUserToken(newAccessToken);
        }
      }
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi làm mới token: ${e.toString()}');
    }
  }
}
