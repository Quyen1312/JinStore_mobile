import 'package:flutter/material.dart';
// import 'package:flutter_application_jin/utils/constants/images.dart'; // Duplicate import, will be removed by ensuring the other one is present
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Correct import for Images class

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/logos/logo.svg',
          width: 100, // Corrected to use Images class
          height: 160,
        ),
        Text(
          'Welcome back,',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: AppSizes.sm,
        ),
        Text(
          'Discover Limitless Choices and Unlimited Convenience.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
