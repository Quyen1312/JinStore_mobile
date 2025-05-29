import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/widgets/onboarding_button.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/widgets/onboarding_navigation.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(children: [
        // Horizontal Scrollable Page
        PageView(
          controller: controller.pageController,
          onPageChanged: controller.updatePageIndicator,
          children: const [
            OnboardingPage(
              title: 'Choose your product',
              image: Images.onBoardingImage1,
              subTitle:
                  'Welcome to a World of limitless Choices - Your Perfect product Awaits!',
            ),
            OnboardingPage(
              title: 'Select payment method',
              image: Images.onBoardingImage2,
              subTitle:
                  'For Seamless Transcations, Choose Your Payment Path - Your Convenience, Our Priority!',
            ),
            OnboardingPage(
              title: 'Deliver at your door step',
              image: Images.onBoardingImage3,
              subTitle:
                  'From Our DoorStep to Yours - Swift, Secure, and Contactless Delivery!',
            ),
          ],
        ),

        // Skip Button
        const OnBoardingSkip(),

        // Smooth Page Indicator
        const OnBoardingNavigation(),

        // Circular Button
        const OnBoardingButton(),
      ]),
    );
  }
}
