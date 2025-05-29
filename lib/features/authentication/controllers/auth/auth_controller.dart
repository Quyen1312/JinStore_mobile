import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user/user_controller.dart'; // Cần để cập nhật UserController
import 'package:flutter_application_jin/bottom_navigation_bar.dart'; // Điều hướng đến màn hình chính
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart'; // Điều hướng đến màn hình login
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find(); // Để dễ dàng truy cập instance

  final AuthRepository authRepository;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  // Không cần user ở đây nữa, sẽ dùng UserController.instance.user
  // var user = Rxn<User>(); // Xóa dòng này

  // Thêm UserController để quản lý thông tin người dùng chung
  final UserController userController = Get.put(UserController(userRepository: Get.find())); // Giả sử UserRepository đã được bind

  AuthController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    // Không gọi checkLoginStatus() tự động ở đây nữa,
    // việc này sẽ được quản lý bởi App Launch Logic (ví dụ trong main.dart hoặc splash screen)
    // để tránh việc rebuild không cần thiết hoặc điều hướng sớm.
    // Thay vào đó, bạn có thể có một hàm khởi tạo global hơn.
    // Ví dụ: gọi từ một SplashController hoặc AppController.
  }

  Future<void> checkLoginStatusAndNavigate() async {
    final token = await authRepository.getUserToken();
    if (token != null && token.isNotEmpty) {
      // Nếu có token, xác thực token và lấy thông tin user
      final userInfoResponse = await authRepository.fetchUserInfo();
      if (userInfoResponse.statusCode == 200 || userInfoResponse.statusCode == 201) {
        if (userInfoResponse.body != null && userInfoResponse.body['user'] != null) {
           userController.user.value = User.fromJson(userInfoResponse.body['user']);
           isLoggedIn.value = true;
           Get.offAll(() => const BottomNavMenu()); // Điều hướng đến màn hình chính
           return;
        }
      }
      // Nếu token không hợp lệ hoặc không lấy được user info, xóa token và coi như chưa đăng nhập
      await authRepository.clearToken();
    }
    isLoggedIn.value = false;
    Get.offAll(() => const LoginScreen()); // Điều hướng đến màn hình đăng nhập
  }


  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      final response = await authRepository.login(
        identifier: identifier,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Đăng nhập thành công, API đã lưu token.
        // Bây giờ lấy thông tin người dùng
        final userInfoResponse = await authRepository.fetchUserInfo();
        if (userInfoResponse.statusCode == 200 || userInfoResponse.statusCode == 201) {
          if (userInfoResponse.body != null && userInfoResponse.body['user'] != null) {
            // Cập nhật user trong UserController
            userController.user.value = User.fromJson(userInfoResponse.body['user']);
            isLoggedIn.value = true;
            Get.snackbar('Thành công', response.body['message'] ?? 'Đăng nhập thành công');
            Get.offAll(() => const BottomNavMenu()); // Điều hướng đến màn hình chính
          } else {
            isLoggedIn.value = false;
            Get.snackbar('Lỗi', 'Không thể lấy thông tin người dùng.');
          }
        } else {
          isLoggedIn.value = false;
          Get.snackbar('Lỗi', userInfoResponse.statusText ?? 'Lỗi lấy thông tin người dùng.');
        }
      } else {
        // Lỗi từ API đăng nhập
        isLoggedIn.value = false;
        String errorMessage = 'Đăng nhập thất bại.';
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else if (response.statusText != null && response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      isLoggedIn.value = false;
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(User userModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.register(userModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
         String successMessage = response.body?['message'] ?? 'Đăng ký thành công. Vui lòng đăng nhập.';
        Get.snackbar('Thành công', successMessage);
        Get.to(() => const LoginScreen()); // Điều hướng đến màn hình đăng nhập sau khi đăng ký
      } else {
        String errorMessage = 'Đăng ký thất bại.';
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else if (response.statusText != null && response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await authRepository.logout(); // Repository đã tự clear token nếu thành công

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoggedIn.value = false;
        userController.user.value = null; // Xóa user trong UserController
        Get.snackbar('Thành công', response.body?['message'] ?? 'Đăng xuất thành công');
        Get.offAll(() => const LoginScreen()); // Điều hướng về màn hình đăng nhập
      } else {
        // Ngay cả khi API lỗi, vẫn có thể nên clear token cục bộ và đăng xuất người dùng khỏi app
        await authRepository.clearToken();
        isLoggedIn.value = false;
        userController.user.value = null;
        Get.snackbar('Lỗi', response.statusText ?? 'Đăng xuất thất bại từ server, đã đăng xuất cục bộ.');
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      // Xử lý lỗi nghiêm trọng hơn, vẫn cố gắng đăng xuất cục bộ
      await authRepository.clearToken();
      isLoggedIn.value = false;
      userController.user.value = null;
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}. Đã đăng xuất cục bộ.');
      Get.offAll(() => const LoginScreen());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      final response = await authRepository.resetPassword(email);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Thành công', response.body?['message'] ?? 'Yêu cầu đặt lại mật khẩu đã được gửi.');
      } else {
         String errorMessage = response.body?['message'] ?? response.statusText ?? 'Yêu cầu đặt lại mật khẩu thất bại.';
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Sửa đổi để nhận Map thay vì User model
  Future<void> changePassword(Map<String, dynamic> passwordData) async {
    try {
      isLoading.value = true;
      // Ví dụ: passwordData = {'oldPassword': '...', 'newPassword': '...'}
      // Bạn sẽ cần lấy oldPassword và newPassword từ các TextFormField trong UI
      final response = await authRepository.changePassword(passwordData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Thành công', response.body?['message'] ?? 'Đổi mật khẩu thành công.');
        // Có thể điều hướng người dùng hoặc yêu cầu đăng nhập lại
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Đổi mật khẩu thất bại.';
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.verifyOTP(verifyOTPModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Thành công', response.body?['message'] ?? 'Xác thực OTP thành công.');
        // Xử lý logic tiếp theo, ví dụ: cho phép đặt lại mật khẩu hoặc hoàn tất đăng ký
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Xác thực OTP thất bại.';
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOTP(VerifyOTPModel verifyOTPModel) async {
    // verifyOTPModel có thể chỉ cần chứa email hoặc phone để gửi OTP
    try {
      isLoading.value = true;
      final response = await authRepository.sendOTP(verifyOTPModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Thành công', response.body?['message'] ?? 'OTP đã được gửi.');
        // Điều hướng đến màn hình nhập OTP
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Gửi OTP thất bại.';
        Get.snackbar('Lỗi', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}