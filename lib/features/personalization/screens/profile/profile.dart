import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_profile.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_password.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.notification),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              // Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(
                      () => CircularImage(
                        image: controller.getAvatarUrl().isNotEmpty
                            ? controller.getAvatarUrl()
                            : Images.user,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Thay đổi ảnh đại diện'),
                    ),
                  ],
                ),
              ),

              // Details
              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Heading Profile Info
              const Sectionheading(title: 'Thông tin cá nhân'),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Profile Menu Items
              Obx(() => Column(
                children: [
                  ProfileMenu(
                    onTap: () => Get.to(() => const ChangeProfile()),
                    title: 'Họ và tên',
                    value: controller.getFormattedName(),
                    icon: Iconsax.user,
                  ),
                  ProfileMenu(
                    onTap: () {},
                    title: 'Email',
                    value: controller.currentUser.value?.email ?? '',
                    icon: Iconsax.direct,
                  ),
                  ProfileMenu(
                    onTap: () => Get.to(() => const ChangeProfile()),
                    title: 'Số điện thoại',
                    value: controller.getPhone(),
                    icon: Iconsax.call,
                  ),
                ],
              )),

              const SizedBox(height: AppSizes.spaceBtwSections),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Security Section
              const Sectionheading(title: 'Bảo mật'),
              const SizedBox(height: AppSizes.spaceBtwItems),

              ProfileMenu(
                onTap: () => Get.to(() => const ChangePassword()),
                title: 'Đổi mật khẩu',
                value: '********',
                icon: Iconsax.password_check,
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Danger Zone
              const Sectionheading(
                title: 'Nguy hiểm',
                showActionButton: false,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              ProfileMenu(
                onTap: () {
                  // Show delete account confirmation dialog
                  Get.defaultDialog(
                    title: 'Xóa tài khoản',
                    titleStyle: Theme.of(context).textTheme.headlineSmall,
                    content: const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Text(
                        'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    confirm: ElevatedButton(
                      onPressed: () {
                        // Handle delete account
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Xóa tài khoản'),
                    ),
                    cancel: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Hủy'),
                    ),
                  );
                },
                title: 'Xóa tài khoản',
                value: '',
                icon: Iconsax.trash,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
