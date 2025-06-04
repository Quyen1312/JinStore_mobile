import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final _controller = Get.find<AuthController>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final RxBool showCurrentPassword = false.obs;
    final RxBool showNewPassword = false.obs;
    final RxBool showConfirmPassword = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Text(
                  'Bảo mật tài khoản',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Đảm bảo mật khẩu của bạn đủ mạnh và không chia sẻ cho người khác',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yêu cầu mật khẩu:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const Text('• Ít nhất 8 ký tự'),
                      const Text('• Ít nhất 1 chữ in hoa'),
                      const Text('• Ít nhất 1 chữ thường'),
                      const Text('• Ít nhất 1 số'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Current Password
                Obx(
                  () => TextFormField(
                    controller: currentPasswordController,
                    obscureText: !showCurrentPassword.value,
                    validator: (value) => Validators.validatePassword(value),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () => showCurrentPassword.value = !showCurrentPassword.value,
                        icon: Icon(showCurrentPassword.value ? Iconsax.eye : Iconsax.eye_slash),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // New Password
                Obx(
                  () => TextFormField(
                    controller: newPasswordController,
                    obscureText: !showNewPassword.value,
                    validator: (value) => Validators.validatePassword(value),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () => showNewPassword.value = !showNewPassword.value,
                        icon: Icon(showNewPassword.value ? Iconsax.eye : Iconsax.eye_slash),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // Confirm New Password
                Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu mới';
                      }
                      if (value != newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () => showConfirmPassword.value = !showConfirmPassword.value,
                        icon: Icon(showConfirmPassword.value ? Iconsax.eye : Iconsax.eye_slash),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                await _controller.changePassword(
                                  currentPassword: currentPasswordController.text.trim(),
                                  newPassword: newPasswordController.text.trim(),
                                  confirmPassword: confirmPasswordController.text.trim(),
                                );
                                if (controller.error.value.isEmpty) {
                                  Get.back();
                                }
                              }
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text('Cập nhật mật khẩu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
