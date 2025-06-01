import 'package:flutter/material.dart' show VoidCallback;
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/service/user/user_service.dart';
import 'package:flutter_application_jin/service/auth/auth_service.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/features/shop/screens/home/home.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString token = ''.obs;
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final storedToken = await _authService.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        token.value = storedToken;
        isLoggedIn.value = true;
        await fetchCurrentUser();
      } else {
        isLoggedIn.value = false;
        currentUser.value = {};
      }
    } catch (e) {
      error.value = e.toString();
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkLoginStatusAndNavigate() async {
    await checkLoginStatus();
    if (isLoggedIn.value) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      print('[AuthController] Bước 1: Bắt đầu quá trình đăng nhập cho: $usernameOrEmail');

      final loginResult = await _authService.login( // Đảm bảo gọi đúng (positional hoặc named)
        usernameOrEmail, // Nếu AuthService.login là positional
        password,
      );
      print('[AuthController] Bước 2: Gọi AuthService.login thành công. Kết quả: $loginResult');

      if (loginResult == null) {
        throw Exception('Kết quả đăng nhập từ service là null.');
      }

      // SỬA Ở ĐÂY: Dùng đúng key "accessToken"
      final tokenFromLoginResult = loginResult['accessToken']; // <--- THAY ĐỔI
      if (tokenFromLoginResult == null || !(tokenFromLoginResult is String) || tokenFromLoginResult.isEmpty) {
        throw Exception('AccessToken không hợp lệ hoặc bị thiếu trong kết quả đăng nhập.');
      }
      
      // Dữ liệu user trong trường hợp này là chính loginResult (trừ accessToken và các key không phải user)
      // Hoặc nếu API trả về một key 'user' riêng biệt chứa user object thì dùng loginResult['user']
      // Dựa trên response body bạn cung cấp, loginResult chính là user object, có thêm accessToken.
      final Map<String, dynamic> userData;
      if (loginResult['user'] != null && loginResult['user'] is Map<String, dynamic>) {
          userData = loginResult['user'] as Map<String, dynamic>;
      } else {
          // Nếu không có key 'user' riêng, thì toàn bộ loginResult (sau khi lấy token) có thể là user data
          // Cần làm rõ cấu trúc trả về chính xác từ API của bạn để gán currentUser.value
          // Tạm thời, nếu user data nằm cùng cấp với accessToken trong loginResult:
          userData = Map<String, dynamic>.from(loginResult);
          userData.remove('accessToken'); // Loại bỏ token khỏi user data nếu nó nằm cùng cấp
          // Hoặc nếu API luôn trả về một object user lồng bên trong:
          // printWarning(info: '[AuthController] User data không có key "user" riêng. Cần kiểm tra cấu trúc API.');
          // userData = {}; // Hoặc xử lý khác
      }


      token.value = tokenFromLoginResult;
      isLoggedIn.value = true;
      currentUser.value = userData; // Gán user data đã được xử lý
      
      print('[AuthController] Bước 3: Cập nhật trạng thái thành công: isLoggedIn=${isLoggedIn.value}, token=${token.value.isNotEmpty ? "có token" : "không có token"}, user=${currentUser.value.isNotEmpty ? currentUser.value['fullname'] ?? usernameOrEmail : "dữ liệu user rỗng"}');

      Loaders.successSnackBar(
          title: 'Đăng nhập thành công!',
          message: 'Chào mừng bạn trở lại, ${currentUser.value['fullname'] ?? usernameOrEmail}!'); // Sửa 'fullName' thành 'fullname' nếu key trong JSON là 'fullname'
      
      print('[AuthController] Bước 4: Chuẩn bị điều hướng đến HomeScreen...');
      Get.offAll(() => const HomeScreen());
      print('[AuthController] Bước 5: Lệnh điều hướng đến HomeScreen đã được gọi.');

    } catch (e, stackTrace) {
      // ... (khối catch giữ nguyên) ...
      print('[AuthController] >>> LỖI TRONG QUÁ TRÌNH ĐĂNG NHẬP <<<');
      print('[AuthController] Lỗi (Error): ${e.toString()}');
      print('[AuthController] StackTrace:');
      print(stackTrace.toString());
      print('[AuthController] >>> KẾT THÚC LỖI <<<');
      
      printError(info: '[AuthController] LỖI (GetX): ${e.toString()}');
      printError(info: '[AuthController] STACKTRACE (GetX): ${stackTrace.toString()}');

      error.value = e.toString();
      isLoggedIn.value = false;
      currentUser.value = {}; 

      Loaders.errorSnackBar(title: 'Đăng nhập thất bại', message: e.toString());
    } finally {
      isLoading.value = false;
      print('[AuthController] Bước 6: Kết thúc quá trình đăng nhập. isLoading: ${isLoading.value}');
    }
  }

  Future<void> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final registerResult = await _authService.register(
        fullname: fullname,
        email: email,
        password: password,
      );
      
      token.value = registerResult['token'];
      isLoggedIn.value = true;
      currentUser.value = registerResult['user'];
      
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      error.value = e.toString();
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _authService.logout();
      
      token.value = '';
      isLoggedIn.value = false;
      currentUser.value = {};
      
      Get.offAll(() => LoginScreen());
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshToken() async {
    try {
      final newToken = await _authService.refreshToken();
      token.value = newToken['token'];
    } catch (e) {
      error.value = e.toString();
      await logout(); // Force logout if token refresh fails
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();
      currentUser.value = userData;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _userService.resetPassword(email: email, otp: otp, newPassword: newPassword, confirmPassword: confirmPassword);
      
      Get.snackbar('Success', 'Password has been reset successfully');
      Get.offAll(() => LoginScreen());
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to check if user has admin role
  bool isAdmin() {
    return currentUser.value['role'] == 'admin';
  }

  // Helper method to get user's full name
  String getFullName() {
    return currentUser.value['fullName'] as String? ?? 'Guest';
  }

  // Helper method to get user's email
  String getEmail() {
    return currentUser.value['email'] as String? ?? '';
  }

  // Helper method to get user's phone
  String getPhone() {
    return currentUser.value['phone'] as String? ?? '';
  }

  // Email verification methods
  Future<void> sendOTP(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _authService.sendOTP(email);
      Get.snackbar(
        'Thành công',
        'Mã OTP đã được gửi đến $email',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(VerifyOTP verifyOTP, {String flow = 'emailVerification'}) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _authService.verifyOTP(verifyOTP);
      
      Get.snackbar(
        'Thành công',
        'Email đã được xác thực thành công',
        snackPosition: SnackPosition.TOP,
      );

      // Handle different flows
      if (flow == 'emailVerificationAfterRegister') {
        Get.offAll(() => HomeScreen());
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

}