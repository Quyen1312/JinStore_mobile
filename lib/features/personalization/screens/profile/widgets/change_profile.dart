import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChangeProfile extends StatelessWidget {
  const ChangeProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final fullnameController = TextEditingController(text: controller.currentUser.value?.fullname ?? '');
    final phoneController = TextEditingController(text: controller.currentUser.value?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
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
                  'Thông tin của bạn',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Cập nhật thông tin cá nhân của bạn',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Form Fields
                TextFormField(
                  controller: fullnameController,
                  validator: (value) => Validators.validateFullName(value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Họ và tên',
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                TextFormField(
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.call),
                    labelText: 'Số điện thoại',
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // Email field (readonly)
                TextFormField(
                  initialValue: controller.currentUser.value?.email ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct),
                    labelText: 'Email',
                    hintText: 'Email không thể thay đổi',
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                await controller.updateUserProfile(
                                  fullname: fullnameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                );
                                if (controller.error.value.isEmpty) {
                                  Get.back();
                                  Get.snackbar(
                                    'Thành công',
                                    'Cập nhật thông tin thành công',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              }
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text('Lưu thay đổi'),
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
