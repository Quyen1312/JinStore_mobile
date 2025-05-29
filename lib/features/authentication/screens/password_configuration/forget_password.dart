import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth_controller.dart';
// import 'package:flutter_application_jin/features/authentication/screens/verifyOTP/otp_screen.dart'; // Keep if needed for navigation after success
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key}); // Removed const

  final TextEditingController emailController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
          children: [
            //  Headings
            Text(
              'Forget Password',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: AppSizes.spaceBtwItems,
            ),
            Text(
              "Don't worry, sometimes people can forget. Enter your email and we will send you a password reset link.", // Slightly rephrased for clarity
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(
              height: AppSizes.spaceBtwSections * 2,
            ),

            //  Text field
            Form(
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Iconsax.direct_right)),
              ),
            ),
            const SizedBox(
              height: AppSizes.spaceBtwSections,
            ),

            //  Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        // Optional: Add email validation here
                        if (emailController.text.isNotEmpty) {
                          authController.resetPassword(emailController.text.trim());
                          // You might want to navigate to OTPScreen or show a success message
                          // based on the API response, which will be handled by Get.snackbar in AuthController
                          // Example: Get.to(() => const OTPScreen()); // If API call is successful
                        }
                      },
                      child: const Text('Submit'))),
            )
          ],
        ),
      ),
    );
  }
}