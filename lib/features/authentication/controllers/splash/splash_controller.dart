import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  static SplashController get instance => Get.find();

  @override
  void onReady() {
    super.onReady();
    _navigateToAppropriateScreen();
  }

  Future<void> _navigateToAppropriateScreen() async {
    // Bạn có thể thêm một khoảng delay nhỏ ở đây nếu muốn splash screen hiển thị lâu hơn một chút
    // await Future.delayed(const Duration(milliseconds: 1500)); // Ví dụ: 1.5 giây

    // Gọi hàm kiểm tra trạng thái đăng nhập và điều hướng từ AuthController
    // Đảm bảo AuthController.instance đã được khởi tạo (ví dụ thông qua Get.put trong dependencies.dart)
    if (Get.isRegistered<AuthController>()) {
      await AuthController.instance.checkLoginStatusAndNavigate();
    } else {
      // Xử lý trường hợp AuthController chưa được đăng ký, có thể là lỗi khởi tạo dependencies
      printError(info: "AuthController is not registered.");
      // Có thể điều hướng đến một màn hình lỗi hoặc màn hình đăng nhập mặc định
       Get.offAll(() => const OnBoardingScreen());
    }
  }
}