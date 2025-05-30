import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class SocialButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;

  const SocialButtons({
    super.key,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: onGooglePressed,
            icon: const Image(
              height: AppSizes.iconMd,
              width: AppSizes.iconMd,
              image: AssetImage(Images.google),
            ),
          ),
        ),
      ],
    );
  }
}
