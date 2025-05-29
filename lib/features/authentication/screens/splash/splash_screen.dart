import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/splash/splash_controller.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart'; // Giả sử bạn có AppColors
import 'package:flutter_application_jin/utils/constants/sizes.dart'; // Giả sử bạn có AppSizes
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    // Gọi hàm điều hướng ngay khi widget được build
    splashController.onReady(); // Đảm bảo onReady được gọi để bắt đầu điều hướng

    return Scaffold(
      backgroundColor: AppColors.primary, // Hoặc màu nền bạn muốn cho splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/logos/logo.svg',
              width: 150, // Adjust size as needed
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            // Optional: Loading indicator or text
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}