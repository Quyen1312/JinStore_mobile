// File: lib/features/authentication/controllers/splash/splash_controller.dart
import 'package:flutter/material.dart'; // Import Material để dùng WidgetsBinding
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/features/shop/screens/home/home.dart'; // Đảm bảo import HomeScreen
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SplashController extends GetxController {
  static SplashController get instance => Get.find();

  @override
  void onReady() {
    super.onReady();
    // Sử dụng addPostFrameCallback để đảm bảo navigation xảy ra sau khi frame đầu tiên đã build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToAppropriateScreen();
    });
  }

  Future<void> _navigateToAppropriateScreen() async {
    // Đảm bảo AuthController đã được đăng ký
    if (!Get.isRegistered<AuthController>()) {
      printError(info: "CRITICAL ERROR: AuthController is not registered in SplashController.");
      // Ngay cả khi fallback, vẫn nên có một delay nhỏ để tránh lỗi navigator locked nếu có// Delay nhỏ
      Get.offAll(() => const OnBoardingScreen());
      return;
    }

    // Sau khi cả hai tác vụ hoàn tất, tiến hành điều hướng
    if (AuthController.instance.isLoggedIn.value) {
      // Người dùng đã đăng nhập
      Get.offAll(() => const HomeScreen());
    } else {
      // Người dùng chưa đăng nhập, kiểm tra cờ isFirstTime
      final prefs = await SharedPreferences.getInstance();
      // Sử dụng key nhất quán, ví dụ 'isFirstTimeUser' hoặc 'hasCompletedOnboarding'
      final isFirstTime = prefs.getBool('isFirstTimeUser') ?? true;

      if (isFirstTime) {
        Get.offAll(() => const OnBoardingScreen());
      } else {
        Get.offAll(() => LoginScreen()); // Hoặc const LoginScreen()
      }
    }
  }
}