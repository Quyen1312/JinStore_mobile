import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          image: AssetImage(!dark ? Images.darkAppLogo : Images.lightAppLogo),
          height: 160,
          width: 100,
          fit: BoxFit.fitHeight,
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
