import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Import AuthController
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart'; // Thêm import này
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController.instance; // Sử dụng AuthController
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final RxBool oldPasswordVisible = false.obs;
    final RxBool newPasswordVisible = false.obs;
    final RxBool confirmNewPasswordVisible = false.obs;


    return Scaffold(
      appBar: Appbar(
        showBackArrow: true,
        title: Text('Đổi mật khẩu', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Mật khẩu của bạn phải có ít nhất 6 ký tự và bao gồm một ký tự đặc biệt.', // Ví dụ yêu cầu mật khẩu
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Text field and button
            Form(
              key: formKey,
              child: Column(
                children: [
                  Obx(() => TextFormField(
                    controller: oldPasswordController,
                    obscureText: !oldPasswordVisible.value,
                    // Sử dụng AppValidator
                    validator: (value) => Validator.validatePassword(value),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        icon: Icon(oldPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                        onPressed: () => oldPasswordVisible.value = !oldPasswordVisible.value,
                      )
                    ),
                  )),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  Obx(() => TextFormField(
                    controller: newPasswordController,
                    obscureText: !newPasswordVisible.value,
                    // Sử dụng AppValidator
                    validator: (value) => Validator.validatePassword(value),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        icon: Icon(newPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                        onPressed: () => newPasswordVisible.value = !newPasswordVisible.value,
                      )
                    ),
                  )),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  Obx(() => TextFormField(
                    controller: confirmNewPasswordController,
                    obscureText: !confirmNewPasswordVisible.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu mới.';
                      }
                      if (value != newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        icon: Icon(confirmNewPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                        onPressed: () => confirmNewPasswordVisible.value = !confirmNewPasswordVisible.value,
                      )
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Save button
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final passwordData = {
                      "oldPassword": oldPasswordController.text.trim(),
                      "newPassword": newPasswordController.text.trim(),
                      // Backend API có thể cần thêm userId nếu không lấy từ token
                    };
                    authController.changePassword(passwordData);
                  }
                },
                child: const Text('Lưu'),
              )),
            )
          ],
        ),
      ),
    );
  }
}
