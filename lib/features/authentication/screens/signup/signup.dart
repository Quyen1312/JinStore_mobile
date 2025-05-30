import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/login_signup/form_divider.dart';
import 'package:flutter_application_jin/common/widgets/login_signup/social_buttons.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'widgets/signup_form.dart';
import 'widgets/signup_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupState();
}

class _SignupState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const SignUpHeader(),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // Form
                SignupForm(),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // Divider
                FormDivider(dividerText: 'Or Sign up with'.tr),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Footer
              ],
            )),
      ),
    );
  }
}
