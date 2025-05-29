import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/device/device_utility.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OnBoardingButton extends StatelessWidget {
  const OnBoardingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = HelperFunctions.isDarkMode(context);
    return Positioned(
        bottom: DeviceUtils.getBottomNavigationBarHeight() - 25,
        right: AppSizes.defaultSpace,
        child: ElevatedButton(
            onPressed: () => OnBoardingController.instance.nextPage(),
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor:
                    isDarkMode ? AppColors.primary : AppColors.dark),
            child: Icon(
              Iconsax.arrow_right_1,
              color: isDarkMode ? AppColors.dark : AppColors.white,
            )));
  }
}
