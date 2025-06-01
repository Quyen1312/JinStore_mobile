import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/screens/verifyOTP/otp_screen.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthController authController = AuthController.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool _hidePassword = true.obs;
  final RxBool _hideConfirmPassword = true.obs;
  final RxBool isEmailVerified = false.obs;

  void _handleEmailSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    final email = emailController.text.trim();
    Get.to(() => OTPScreen(
      email: email,
      onVerified: () {
        isEmailVerified.value = true;
        Get.back();
      },
      flow: 'resetPassword',
    ));
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Lỗi',
        'Mật khẩu không khớp',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    authController.resetPassword(
      email: emailController.text.trim(),
      otp: otpController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quên mật khẩu?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Text(
                  'Nhập email của bạn để đặt lại mật khẩu',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Email Field
                TextFormField(
                  controller: emailController,
                  validator: (value) => Validators.validateEmail(value),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Iconsax.direct),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                Obx(() {
                  if (!isEmailVerified.value) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleEmailSubmit,
                        child: const Text('Tiếp tục'),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // OTP Field
                      TextFormField(
                        controller: otpController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã OTP';
                          }
                          if (value.length != 6) {
                            return 'Mã OTP phải có 6 số';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Mã OTP',
                          prefixIcon: Icon(Iconsax.password_check),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwInputFields),

                      // New Password
                      Obx(
                        () => TextFormField(
                          controller: newPasswordController,
                          validator: (value) => Validators.validatePassword(value),
                          obscureText: _hidePassword.value,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu mới',
                            prefixIcon: const Icon(Iconsax.password_check),
                            suffixIcon: IconButton(
                              onPressed: () => _hidePassword.value = !_hidePassword.value,
                              icon: Icon(_hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwInputFields),

                      // Confirm Password
                      Obx(
                        () => TextFormField(
                          controller: confirmPasswordController,
                          validator: (value) => Validators.validatePassword(value),
                          obscureText: _hideConfirmPassword.value,
                          decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu mới',
                            prefixIcon: const Icon(Iconsax.password_check),
                            suffixIcon: IconButton(
                              onPressed: () => _hideConfirmPassword.value = !_hideConfirmPassword.value,
                              icon: Icon(_hideConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwSections),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: authController.isLoading.value ? null : _handleResetPassword,
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator()
                                : const Text('Đặt lại mật khẩu'),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 