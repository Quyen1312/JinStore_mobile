import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/styles/spacing_styles.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:lottie/lottie.dart';
import '../../../utils/constants/sizes.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.onPressed});

  final String image, title, subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Image
              Lottie.asset(
                image,
                width: HelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Title and Subtitle
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.spaceBtwItems),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: AppSizes.spaceBtwSections,
              ),

              // Button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: onPressed, child: const Text('Continue'))),
            ],
          ),
        ),
      ),
    );
  }
}
