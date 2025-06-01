import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/profile.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      if (userController.isLoading.value) {
        return ListTile(
          leading: const ShimmerEffect(width: 50, height: 50, radius: 50),
          title: const ShimmerEffect(width: 80, height: 15),
          subtitle: const ShimmerEffect(width: 120, height: 12),
          trailing: IconButton(
            icon: const Icon(Iconsax.edit_copy, color: AppColors.white),
            onPressed: onPressed ?? () => Get.to(() => const ProfileScreen()),
          ),
        );
      }

      final user = userController.currentUser.value;

      // Nếu user chưa có dữ liệu
      if (user == null) {
        return ListTile(
          leading: const CircularImage(
            image: Images.user,
            isNetworkImage: false,
            width: 50,
            height: 50,
            padding: 0,
          ),
          title: Text(
            'Người dùng',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.white),
          ),
          subtitle: Text(
            'Chưa có email',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.white),
          ),
          trailing: IconButton(
            icon: const Icon(Iconsax.edit_copy, color: AppColors.white),
            onPressed: onPressed ?? () => Get.to(() => const ProfileScreen()),
          ),
        );
      }

      final avatar = user.avatar?.isNotEmpty == true ? user.avatar! : Images.user;

      return ListTile(
        leading: CircularImage(
          image: avatar,
          isNetworkImage: user.avatar?.isNotEmpty == true,
          width: 50,
          height: 50,
          padding: 0,
        ),
        title: Text(
          user.fullname ?? '',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColors.white),
        ),
        subtitle: Text(
          user.email ?? '',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.white),
        ),
        trailing: IconButton(
          icon: const Icon(Iconsax.edit_copy, color: AppColors.white),
          onPressed: onPressed ?? () => Get.to(() => const ProfileScreen()),
        ),
      );
    });
  }
}
