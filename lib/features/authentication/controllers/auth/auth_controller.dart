import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user/user_controller.dart';
import 'package:flutter_application_jin/bottom_navigation_bar.dart'; 
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
// import 'package:flutter_application_jin/features/authentication/screens/verifyOTP/otp_screen.dart'; // Import nếu OTP còn dùng cho đăng ký
import 'package:flutter_application_jin/utils/constants/api_constants.dart'; 
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:flutter_application_jin/utils/popups/full_screen_loader.dart'; 
import 'package:flutter_application_jin/utils/popups/loaders.dart'; 
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final AuthRepository authRepository;
  final ApiClient apiClient; 

  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  AuthController({required this.authRepository, required this.apiClient});

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional: Nếu bạn cần lấy idToken cho backend từ Flutter Web,
    // bạn cần cung cấp Web Client ID (từ Google Cloud Console, loại Web Application) ở đây.
    // clientId: 'YOUR_WEB_OAUTH_CLIENT_ID.apps.googleusercontent.com',
    scopes: ['email', 'profile'], 
  );
  var isGoogleLoading = false.obs;

  Future<void> checkLoginStatusAndNavigate() async {
    final token = await authRepository.getUserToken();
    if (token != null && token.isNotEmpty) {
      apiClient.updateHeader(token); // QUAN TRỌNG: Cập nhật token cho ApiClient

      final userInfoResponse = await authRepository.fetchCurrentUserInfo();

      if (userInfoResponse.statusCode == ApiConstants.SUCCESS) {
        Map<String, dynamic>? userData;
        if (userInfoResponse.body != null) {
          // Điều chỉnh dựa trên cấu trúc API response thực tế cho /users/info-user
          if (userInfoResponse.body['user'] != null && userInfoResponse.body['user'] is Map<String,dynamic>) {
            userData = userInfoResponse.body['user'];
          } else if (userInfoResponse.body['data'] != null && userInfoResponse.body['data'] is Map<String,dynamic>) {
            userData = userInfoResponse.body['data'];
          } else if (userInfoResponse.body is Map<String,dynamic> && (userInfoResponse.body.containsKey('email') || userInfoResponse.body.containsKey('_id'))) { // Kiểm tra trường phổ biến
            userData = userInfoResponse.body;
          }
        }

        if (userData != null) {
           UserController.instance.setUser(User.fromJson(userData));
           isLoggedIn.value = true;
           Get.offAll(() => const BottomNavMenu()); // Đảm bảo BottomNavMenu là tên class đúng
           return;
        } else {
          Loaders.warningSnackBar(title: 'Lỗi dữ liệu', message: 'Không thể phân tích thông tin người dùng từ API.');
        }
      } else if (userInfoResponse.statusCode == ApiConstants.UNAUTHORIZED) {
        // Thử làm mới token
        final refreshResponse = await authRepository.refreshToken();
        if (refreshResponse.statusCode == ApiConstants.SUCCESS) {
          // Token đã được làm mới, AuthRepository đã lưu token mới và cập nhật header cho apiClient
          // Gọi lại checkLoginStatusAndNavigate để thử lại với token mới
          // Để tránh vòng lặp vô hạn nếu refresh cũng lỗi, cần cơ chế kiểm soát kỹ hơn ở đây
          // For now, simple retry:
          await checkLoginStatusAndNavigate(); 
          return;
        }
      }
      // Nếu token không hợp lệ, refresh thất bại, hoặc lỗi khác, xóa token
      await authRepository.clearToken();
    }
    isLoggedIn.value = false;
    UserController.instance.setUser(null); // Đảm bảo user state được clear
    Get.offAll(() => LoginScreen());
  }

  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      final response = await authRepository.login(
        identifier: identifier,
        password: password,
      );

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        // Token đã được lưu bởi AuthRepository, giờ lấy thông tin người dùng
        final userInfoResponse = await authRepository.fetchCurrentUserInfo();

        if (userInfoResponse.statusCode == ApiConstants.SUCCESS) {
            Map<String, dynamic>? userData;
             if (userInfoResponse.body != null) {
                if (userInfoResponse.body['user'] != null && userInfoResponse.body['user'] is Map<String,dynamic>) {
                    userData = userInfoResponse.body['user'];
                } else if (userInfoResponse.body['data'] != null && userInfoResponse.body['data'] is Map<String,dynamic>) {
                    userData = userInfoResponse.body['data'];
                } else if (userInfoResponse.body is Map<String,dynamic> && (userInfoResponse.body.containsKey('email') || userInfoResponse.body.containsKey('_id'))) {
                    userData = userInfoResponse.body;
                }
            }

            if (userData != null) {
              UserController.instance.setUser(User.fromJson(userData));
              isLoggedIn.value = true;
              Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Đăng nhập thành công!');
              Get.offAll(() => const BottomNavMenu());
            } else {
              isLoggedIn.value = false;
              await authRepository.clearToken(); 
              Loaders.errorSnackBar(title: 'Lỗi', message: 'Không thể lấy thông tin người dùng sau khi đăng nhập.');
            }
        } else {
          isLoggedIn.value = false;
          await authRepository.clearToken(); 
          Loaders.errorSnackBar(title: 'Lỗi', message: userInfoResponse.body?['message'] ?? userInfoResponse.statusText ?? 'Lỗi lấy thông tin người dùng.');
        }
      } else {
        isLoggedIn.value = false;
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Đăng nhập thất bại.';
        Loaders.errorSnackBar(title: 'Lỗi', message: errorMessage);
      }
    } catch (e) {
      isLoggedIn.value = false;
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Đã xảy ra lỗi khi đăng nhập: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      FullScreenLoader.openLoadingDialog('Đang đăng nhập với Google...', 'assets/images/animations/loader-animation.json');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        FullScreenLoader.stopLoading();
        isGoogleLoading.value = false;
        return; // Người dùng hủy
      }

      // No need to get idToken here if AuthRepository.signInWithGoogle handles it
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // final String? idToken = googleAuth.idToken;

      // if (idToken == null) {
      //   FullScreenLoader.stopLoading();
      //   Loaders.errorSnackBar(title: 'Lỗi Google Sign-In', message: 'Không thể lấy ID Token từ Google.');
      //   isGoogleLoading.value = false;
      //   await _googleSignIn.signOut(); 
      //   return;
      // }

      // Gọi thẳng phương thức của repository
      final Map<String, dynamic>? backendResponse = await authRepository.signInWithGoogle();
      
      if (backendResponse != null) {
        // Giả sử backendResponse chứa token và user info nếu thành công
        // và AuthRepository.signInWithGoogle đã lưu token nếu có
        // Cần điều chỉnh logic này dựa trên cấu trúc response thực tế của API google-token-sign-in
        // và cách AuthRepository.signInWithGoogle xử lý token.

        // Ví dụ: Kiểm tra xem có user data không
        Map<String, dynamic>? userDataFromGoogleSignIn = backendResponse['user']; 
        // Hoặc nếu API trả về token của app, AuthRepository nên lưu nó, sau đó fetch user
        // String? appToken = backendResponse['token'];
        // if (appToken != null) { await authRepository.saveUserToken(appToken); }

        // Giả sử backend trả về user trực tiếp hoặc token đã được xử lý
        // Thử lấy thông tin người dùng (nếu token đã được lưu bởi repo)
        final userInfoResponse = await authRepository.fetchCurrentUserInfo();
        FullScreenLoader.stopLoading(); // Stop sau khi fetch

        if (userInfoResponse.statusCode == ApiConstants.SUCCESS) {
            Map<String, dynamic>? userData;
            if (userInfoResponse.body != null) {
                if (userInfoResponse.body['user'] != null && userInfoResponse.body['user'] is Map<String,dynamic>) {
                    userData = userInfoResponse.body['user'];
                } else if (userInfoResponse.body['data'] != null && userInfoResponse.body['data'] is Map<String,dynamic>) {
                    userData = userInfoResponse.body['data'];
                } else if (userInfoResponse.body is Map<String,dynamic> && (userInfoResponse.body.containsKey('email') || userInfoResponse.body.containsKey('_id'))) {
                    userData = userInfoResponse.body;
                }
            }
            if (userData != null) {
                UserController.instance.setUser(User.fromJson(userData));
                isLoggedIn.value = true;
                Loaders.successSnackBar(title: 'Thành công', message: backendResponse['message'] as String? ?? 'Đăng nhập bằng Google thành công!');
                Get.offAll(() => const BottomNavMenu());
            } else {
                await authRepository.clearToken();
                Loaders.errorSnackBar(title: 'Lỗi', message: 'Không thể lấy thông tin người dùng sau khi đăng nhập Google.');
            }
        } else {
            await authRepository.clearToken();
            Loaders.errorSnackBar(title: 'Lỗi', message: userInfoResponse.body?['message'] ?? userInfoResponse.statusText ?? 'Lỗi lấy thông tin người dùng.');
        }
      } else {
        FullScreenLoader.stopLoading();
        Loaders.errorSnackBar(title: 'Lỗi Đăng nhập Google', message: 'Đăng nhập bằng Google thất bại từ server.');
        await _googleSignIn.signOut(); 
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi đăng nhập bằng Google: ${e.toString()}');
      await _googleSignIn.signOut(); 
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> register(User userModel) async {
    try {
      isLoading.value = true;
      // Giả sử userModel.toRegisterJson() đã được tạo trong UserModel cho các trường đăng ký cụ thể
      final response = await authRepository.register(userModel); 

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        String successMessage = response.body?['message'] ?? 'Đăng ký thành công. Vui lòng đăng nhập hoặc xác thực email nếu được yêu cầu.';
        Loaders.successSnackBar(title: 'Thành công', message: successMessage);
        // Xem xét điều hướng đến màn hình OTP nếu cần xác thực email, hoặc màn hình Login
        Get.to(() =>  LoginScreen());
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Đăng ký thất bại.';
        Loaders.errorSnackBar(title: 'Lỗi', message: errorMessage);
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi đăng ký: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> logout() async { // Sửa lại để là @override nếu GetxController có phương thức này, nếu không thì bỏ @override
    try {
      isLoading.value = true;
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("Đã đăng xuất khỏi Google");
      }
      // ... (phần còn lại của logout)
      final response = await authRepository.logout();
      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.NO_CONTENT) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Đăng xuất thành công!');
      } else {
        await authRepository.clearToken(); 
        Loaders.warningSnackBar(title: 'Thông báo', message: response.statusText ?? 'Đăng xuất thất bại từ server, đã đăng xuất cục bộ.');
      }
    } catch (e) {
      await authRepository.clearToken(); 
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi đăng xuất: ${e.toString()}. Đã đăng xuất cục bộ.');
    } finally {
      isLoggedIn.value = false;
      UserController.instance.setUser(null);
      //CartController.instance.clearCart();
      isLoading.value = false;
      Get.offAll(() =>  LoginScreen());
    }
  }

  // --- Chức năng Quên Mật Khẩu đã được BỎ ---
  // Future<void> forgotPasswordRequest(String email) async { ... }
  // Future<void> completePasswordReset(Map<String, dynamic> resetData) async { ... }

  Future<void> changePassword(Map<String, dynamic> passwordData) async {
    // Dành cho người dùng đã đăng nhập muốn đổi mật khẩu hiện tại của họ
    try {
      isLoading.value = true;
      final response = await authRepository.changePassword(passwordData);

      if (response.statusCode == ApiConstants.SUCCESS) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Đổi mật khẩu thành công.');
        // Có thể Get.back(); hoặc yêu cầu người dùng đăng nhập lại với mật khẩu mới
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Đổi mật khẩu thất bại.';
        Loaders.errorSnackBar(title: 'Lỗi', message: errorMessage);
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi đổi mật khẩu: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức này vẫn có thể hữu ích nếu bạn dùng OTP cho việc khác, ví dụ xác thực đăng ký
  Future<void> verifyOTP(VerifyOTPModel verifyOTPModel, {required String flow}) async {
    try {
      isLoading.value = true;
      final response = await authRepository.verifyOTP(verifyOTPModel);

      if (response.statusCode == ApiConstants.SUCCESS) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Xác thực OTP thành công.');
        
        if (flow == 'emailVerificationAfterRegister') {
          Loaders.successSnackBar(title: 'Thành công', message: 'Email đã được xác thực. Vui lòng đăng nhập.');
          Get.offAll(() =>  LoginScreen());
        }
        // Xử lý các 'flow' khác nếu có
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Xác thực OTP thất bại.';
        Loaders.errorSnackBar(title: 'Lỗi', message: errorMessage);
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi xác thực OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức này vẫn có thể hữu ích nếu bạn dùng OTP cho việc khác
  Future<void> sendOTP(VerifyOTPModel verifyOTPModel, {String? flowContext}) async {
    try {
      isLoading.value = true;
      final response = await authRepository.sendOTP(verifyOTPModel);

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'OTP đã được gửi.');
        // if (flowContext == 'emailVerificationAfterRegister' && verifyOTPModel.email != null) {
        //    Get.to(() => OTPScreen(emailOrPhone: verifyOTPModel.email!, flow: 'emailVerificationAfterRegister'));
        // }
      } else {
        String errorMessage = response.body?['message'] ?? response.statusText ?? 'Gửi OTP thất bại.';
        Loaders.errorSnackBar(title: 'Lỗi', message: errorMessage);
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi gửi OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
