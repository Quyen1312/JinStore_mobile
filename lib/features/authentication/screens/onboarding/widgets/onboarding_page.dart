import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class OnboardingPage extends StatelessWidget {
  final String title, image, subTitle;
  const OnboardingPage({
    super.key,
    required this.title,
    required this.image,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage(image),
          width: HelperFunctions.screenWidth() * 0.8,
          height: HelperFunctions.screenHeight() * 0.6,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: AppSizes.spaceBtwItems,
        ),
        Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
