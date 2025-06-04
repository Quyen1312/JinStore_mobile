// File: lib/features/authentication/controllers/splash/splash_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/navigation_menu.dart'; // ✅ Import NavigationMenu thay vì HomeScreen
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  static SplashController get instance => Get.find();

  @override
  void onReady() {
    super.onReady();
    // Delay để tránh race condition và cho phép splash screen hiển thị
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToAppropriateScreen();
      });
    });
  }

  Future<void> _navigateToAppropriateScreen() async {
    try {
      print('🔍 SplashController: Checking navigation...');
      
      // Đảm bảo AuthController đã được đăng ký
      if (!Get.isRegistered<AuthController>()) {
        print('❌ AuthController not registered, going to onboarding');
        Get.offAll(() => const OnBoardingScreen());
        return;
      }

      final authController = Get.find<AuthController>();
      
      // Kiểm tra trạng thái đăng nhập
      await authController.checkLoginStatus();
      
      print('📱 Login status: ${authController.isLoggedIn.value}');
      print('👤 Current user: ${authController.currentUser.value?.fullname}');

      if (authController.isLoggedIn.value && authController.currentUser.value != null) {
        // ✅ User đã đăng nhập - điều hướng đến NavigationMenu
        print('✅ User logged in, navigating to NavigationMenu');
        Get.offAll(() => const NavigationMenu());
      } else {
        // ❌ User chưa đăng nhập - kiểm tra first time
        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = prefs.getBool('isFirstTimeUser') ?? true;

        if (isFirstTime) {
          print('🆕 First time user, going to onboarding');
          Get.offAll(() => const OnBoardingScreen());
        } else {
          print('🔑 Returning user, going to login');
          Get.offAll(() => LoginScreen());
        }
      }
      
    } catch (e) {
      print('❌ Error in splash navigation: $e');
      // Fallback to onboarding on any error
      Get.offAll(() => const OnBoardingScreen());
    }
  }
}