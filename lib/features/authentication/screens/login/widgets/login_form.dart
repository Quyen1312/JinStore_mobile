import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application_jin/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  // Controllers for form fields
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  // Local state for UI elements
  final RxBool isPasswordVisible = false.obs;
  final RxBool isRememberMe = false.obs;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
        child: Column(
          children: [
            // Username or Email
            TextFormField(
              controller: identifierController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: 'Username or Email',
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwInputFields),

            // Password
            Obx(
              () => TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Iconsax.direct),
                  suffixIcon: IconButton(
                    onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                    icon: Icon(isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        Checkbox(
                          value: isRememberMe.value,
                          onChanged: (value) => isRememberMe.value = value ?? false,
                        ),
                        const Text('Remember Me'),
                      ],
                    )),
                TextButton(
                  onPressed: () => Get.to(() => ForgotPassword()),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                onPressed: () {
                  // Add form validation if needed here
                  authController.login(
                    identifierController.text.trim(), 
                    passwordController.text.trim()
                  );
                },
                child: const Text('Sign In'),
              ),)
            ),

            const SizedBox(height: AppSizes.spaceBtwItems),

            // Sign Up
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const Signup()),
                child: const Text('Create Account'),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
