import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index when Page Scroll
  void updatePageIndicator(int index) {
    currentPageIndex.value = index; // Correctly updating the value
  }

  // Jump to the specific dot at specified page
  void dotnavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index); // Use jumpToPage instead of jumpTo
  }

  // Update Current Index & jump to next page
  void nextPage() async {
    if (currentPageIndex.value == 2) {
      // Navigate to the login screen or any other screen

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool('isFirstLaunch', false);

      Get.to( LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Update Current Index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2); // Use jumpToPage instead of jumpTo
  }
}
