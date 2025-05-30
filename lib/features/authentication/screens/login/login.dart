import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/styles/spacing_styles.dart';
import 'package:flutter_application_jin/common/widgets/login_signup/form_divider.dart';
import 'package:flutter_application_jin/common/widgets/login_signup/social_buttons.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
   LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  final AuthController authController = Get.find();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: SpacingStyles.paddingWithAppBarHeight,
            child: Column(
              children: [
                // Logo, Title & Sub title
                LoginHeader(),

                // Form
                LoginForm(),

                // Divider
                FormDivider(
                  dividerText: 'Or Sign in with',
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // Footer
                SocialButtons()
              ],
            )),
      ),
    );
  }
}
