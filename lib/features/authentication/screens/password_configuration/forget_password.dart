import 'package:flutter/material.dart';
// Sửa đường dẫn import AuthController
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; 
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart'; // Thêm import cho AppValidator
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';


class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng AuthController.instance nếu bạn đã đăng ký nó là singleton
    final AuthController authController = AuthController.instance; 
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headings
              Text(
                AppTexts.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: AppSizes.spaceBtwItems,
              ),
              Text(
                AppTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: AppSizes.spaceBtwSections * 2,
              ),

              // Text field
              Form(
                key: formKey,
                child: TextFormField(
                  controller: emailController,
                  validator: Validator.validateEmail, // Sử dụng AppValidator
                  decoration: const InputDecoration(
                    labelText: AppTexts.email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
              ),
              const SizedBox(
                height: AppSizes.spaceBtwSections,
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => authController.isLoading.value 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        authController.resetPassword(emailController.text.trim());
                      }
                    },
                    child: const Text('Submit'),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
