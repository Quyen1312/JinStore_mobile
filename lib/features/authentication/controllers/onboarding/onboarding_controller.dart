import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
// Import AppRoutes nếu bạn dùng Get.offAllNamed
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index when Page Scroll
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  // Jump to the specific dot at specified page
  void dotnavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Update Current Index & jump to next page
  void nextPage() async {
    if (currentPageIndex.value == 2) { // Giả sử có 3 trang onboarding (index 0, 1, 2)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // SỬA Ở ĐÂY: Sử dụng key nhất quán với SplashController
      await prefs.setBool('isFirstTimeUser', false); // Đặt cờ đã hoàn thành onboarding

      // SỬA Ở ĐÂY: Sử dụng Get.offAll hoặc Get.offAllNamed để xóa stack onboarding
       Get.offAll(() => LoginScreen()); // Điều hướng đến LoginScreen và xóa các màn hình trước đó
      // Hoặc nếu bạn đã định nghĩa route cho login trong AppRoutes:
      //Get.offAllNamed(AppRoutes.login); // Ví dụ: AppRoutes.login = '/login'

    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Update Current Index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);

    // Cân nhắc: Nếu người dùng skip, bạn cũng nên đặt cờ 'isFirstTimeUser' = false
    // và điều hướng bằng Get.offAllNamed() tương tự như nextPage() khi ở trang cuối.
    // Điều này đảm bảo hành vi nhất quán.
    // Ví dụ:
    // _markOnboardingCompleteAndNavigate();
  }

  // (Tùy chọn) Tạo hàm riêng để đánh dấu hoàn thành và điều hướng:
  // Future<void> _markOnboardingCompleteAndNavigate() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFirstTimeUser', false);
  //   Get.offAllNamed(AppRoutes.login); // Hoặc Get.offAll(() => LoginScreen());
  // }
}