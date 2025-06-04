import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_profile.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_password.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/profile_menu.dart';
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
                    Obx(() {
                      final avatarUrl = controller.getAvatarUrl();
                      final isValidNetworkUrl = avatarUrl.isNotEmpty && 
                                               (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
                      
                      return CircularImage(
                        image: isValidNetworkUrl ? avatarUrl : Images.user,
                        isNetworkImage: isValidNetworkUrl,
                        width: 80,
                        height: 80,
                        padding: 0,
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement image picker functionality
                        _showImagePickerDialog(context, controller);
                      },
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
              Obx(() {
                // Show loading if user data is being fetched
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: [
                    ProfileMenu(
                      onTap: () => Get.to(() => const ChangeProfile()),
                      title: 'Họ và tên',
                      value: _getDisplayValue(controller.getFormattedName()),
                      icon: Iconsax.user,
                    ),
                    ProfileMenu(
                      onTap: () {},
                      title: 'Email',
                      value: _getDisplayValue(controller.currentUser.value?.email ?? ''),
                      icon: Iconsax.direct,
                    ),
                    ProfileMenu(
                      onTap: () => Get.to(() => const ChangeProfile()),
                      title: 'Số điện thoại',
                      value: _getDisplayValue(controller.getPhone()),
                      icon: Iconsax.call,
                    ),
                  ],
                );
              }),

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
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to display fallback text for empty values
  String _getDisplayValue(String value) {
    return value.isNotEmpty ? value : 'Chưa cập nhật';
  }

  /// Show dialog for image picker options
  void _showImagePickerDialog(BuildContext context, UserController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thay đổi ảnh đại diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera functionality
                  _pickImageFromCamera(controller);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery functionality
                  _pickImageFromGallery(controller);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _pickImageFromCamera(UserController controller) {
    // TODO: Implement camera image picker
    // You'll need to add image_picker package and implement this
    print('Pick image from camera');
  }

  void _pickImageFromGallery(UserController controller) {
    // TODO: Implement gallery image picker
    // You'll need to add image_picker package and implement this
    print('Pick image from gallery');
  }
}