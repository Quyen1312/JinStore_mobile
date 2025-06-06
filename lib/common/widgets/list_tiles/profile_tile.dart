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
    // final userController = Get.find<UserController>(); // Dòng này đúng
    // Thay vào đó, để an toàn hơn khi widget này có thể được dùng ở nơi UserController chưa sẵn sàng ngay,
    // hoặc để widget có thể tái sử dụng với controller khác (dù hiện tại là UserController)
    // bạn có thể truyền controller vào hoặc dùng Get.put nếu đây là nơi đầu tiên nó được dùng.
    // Tuy nhiên, với Get.find(), giả định UserController đã được khởi tạo ở đâu đó trước đó.
    // Để giữ nguyên logic gốc, ta dùng Get.find()
    final userController = UserController.instance; // Sử dụng instance getter nếu có

    return Obx(() {
      // 1. Shimmer Loading State
      if (userController.isLoading.value && userController.currentUser.value == null) { // Chỉ hiển thị shimmer khi đang load VÀ chưa có data
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

      // 2. User Data Not Available (sau khi loading xong mà vẫn null)
      final user = userController.currentUser.value;
      if (user == null) {
        return ListTile(
          leading: const CircularImage(
            image: Images.user, // Ảnh placeholder mặc định
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
            'Chưa có thông tin', // Thông báo chung hơn
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

      // 3. User Data Available
      // Truy cập user.avatar.url. User model đã được sửa để avatar là object Avatar {url, publicId}
      // và avatar trong User là non-nullable, url trong Avatar cũng non-nullable (default là chuỗi rỗng)
      final String avatarUrl = user.avatar.url;
      final bool isNetworkImg = avatarUrl.isNotEmpty;

      return ListTile(
        leading: CircularImage(
          image: isNetworkImg ? avatarUrl : Images.user, // Nếu url rỗng, dùng ảnh user mặc định
          isNetworkImage: isNetworkImg,
          width: 50,
          height: 50,
          padding: 0,
          // Thêm fallback nếu ảnh mạng lỗi (tùy chọn, CircularImage cần hỗ trợ)
          // onImageError: (exception, stackTrace) {
          //   return Image.asset(Images.user); // Ví dụ
          // },
        ),
        title: Text(
          user.fullname, // fullname trong UserModel đã sửa là non-nullable String
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColors.white),
        ),
        subtitle: Text(
          user.email, // email trong UserModel đã sửa là non-nullable String
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
