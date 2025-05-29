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
        // Backend JinStore-API (theo file auth.controller.js) có thể đang mong đợi 'email' hoặc 'username' trực tiếp
        // chứ không phải 'identifier'. Điều chỉnh payload nếu cần.
        // Ví dụ, nếu backend chỉ nhận 'email' và 'password':
        // if (isEmail) 'email': identifier,
        // else 'username': identifier, // Hoặc backend có thể chỉ hỗ trợ một trong hai
        // Giả sử backend hỗ trợ cả hai và nhận đúng key 'email' hoặc 'username'
        if (isEmail) 'email': identifier,
        if (!isEmail) 'username': identifier,
      };

      final response = await apiClient.postData(ApiConstants.LOGIN, payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body?['token'];
        if (token != null && token is String) {
          await saveUserToken(token);
          // Không cần lưu user vào SharedPreferences ở đây nữa nếu AuthController sẽ fetch sau.
          // Hoặc nếu API trả về user, bạn có thể parse và trả về cùng response
          // Ví dụ, nếu user được trả về trong response.body['user']:
          // final userData = response.body?['user'];
          // if (userData != null && userData is Map<String, dynamic>) {
          //   // Không cần lưu trực tiếp User model ở đây, chỉ cần đảm bảo response.body chứa nó
          // }
        }
      }
      return response;
    } catch (e) {
      // Trả về một Response với mã lỗi và thông tin lỗi
      // để AuthController có thể xử lý và hiển thị thông báo phù hợp.
      return Response(statusCode: 500, statusText: 'Login error: ${e.toString()}');
    }
  }

  Future<Response> register(User user) async {
    try {
      // Đảm bảo user.toJson() gửi đúng các trường mà API register yêu cầu.
      // Ví dụ, API có thể không cần 'id', 'isAdmin', 'isActive', 'createdAt', 'updatedAt' khi đăng ký.
      // Bạn có thể tạo một phương thức riêng trong UserModel như toRegisterJson()
      // hoặc điều chỉnh toJson() cho phù hợp với từng ngữ cảnh.
      // Hiện tại, chúng ta giữ nguyên user.toJson()
      return await apiClient.postData(ApiConstants.REGISTER, user.toJson());
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Registration error: ${e.toString()}');
    }
  }

  Future<Response> logout() async {
    try {
      // Không cần gửi token trong body, ApiClient đã tự động thêm vào header
      final response = await apiClient.postData(ApiConstants.LOGOUT, {});
      // Xóa token sau khi API logout thành công (hoặc bất kể kết quả nếu muốn)
      if (response.statusCode == 200 || response.statusCode == 201) {
        await clearToken(); // Tích hợp clearToken vào đây
      }
      return response;
    } catch (e) {
      // Ngay cả khi API logout lỗi, vẫn có thể cân nhắc xóa token cục bộ
      // await clearToken();
      return Response(statusCode: 500, statusText: 'Logout error: ${e.toString()}');
    }
  }

  Future<Response> resetPassword(String email) async {
    try {
      return await apiClient.patchData(ApiConstants.RESET_PASSWORD, {"email": email});
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Password reset error: ${e.toString()}');
    }
  }

  Future<Response> changePassword(Map<String, dynamic> passwordData) async {
    // API đổi mật khẩu thường yêu cầu: userId (hoặc lấy từ token), oldPassword, newPassword
    // Payload của bạn có thể cần điều chỉnh.
    // Ví dụ: {'oldPassword': '...', 'newPassword': '...'}
    // User model có thể không phù hợp để gửi trực tiếp ở đây.
    try {
      return await apiClient.patchData(ApiConstants.CHANGE_PASSWORD, passwordData);
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Change password error: ${e.toString()}');
    }
  }

  Future<Response> verifyOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      return await apiClient.postData(ApiConstants.VERIFY_OTP, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: 500, statusText: 'OTP verification error: ${e.toString()}');
    }
  }

  Future<Response> sendOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      // API gửi OTP có thể chỉ cần email hoặc phone.
      // VerifyOTPModel hiện tại có vẻ phù hợp cho cả send và verify.
      return await apiClient.postData(ApiConstants.SEND_OTP, verifyOTPModel.toJson());
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Send OTP error: ${e.toString()}');
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
    apiClient.token = ''; // Đảm bảo là chuỗi rỗng thay vì null
    apiClient.updateHeader(''); // Gửi chuỗi rỗng để xóa header
  }

  // Thêm phương thức lấy thông tin người dùng sau khi đăng nhập thành công
  // hoặc khi khởi động ứng dụng nếu đã có token
  Future<Response> fetchUserInfo() async {
    try {
      final response = await apiClient.getData(ApiConstants.USER_INFO);
      return response;
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Fetch user info error: ${e.toString()}');
    }
  }
}