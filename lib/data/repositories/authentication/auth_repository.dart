import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository extends GetxService {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

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

      final response = await apiClient.postData(ApiConstants.LOGIN, payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body?['token'];
        if (token != null && token is String) {
          await saveUserToken(token);
        }
      }

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> register(User user) async {
    try {
      return await apiClient.postData(ApiConstants.REGISTER, user.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> logout() async {
    try {
      return await apiClient.postData(ApiConstants.LOGOUT, {});
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> resetPassword(String email) async {
    try {
      return await apiClient.patchData(ApiConstants.RESET_PASSWORD, {"email": email});
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> changePassword(User user) async {
    try {
      return await apiClient.patchData(ApiConstants.CHANGE_PASSWORD, user.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> verifyOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      return await apiClient.postData(ApiConstants.VERIFY_OTP, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> sendOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      return await apiClient.postData(ApiConstants.SEND_OTP, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<bool> saveUserToken(String token) async {
    try {
      apiClient.token = token;
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
    apiClient.token = '';
    apiClient.updateHeader('');
  }
}
