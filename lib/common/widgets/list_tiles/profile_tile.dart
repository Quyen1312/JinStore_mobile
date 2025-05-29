import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/profile.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircularImage(
        image: Images.granolaIcon,
        width: 50,
        height: 50,
        padding: 0,
      ),
      title: Text(
        "LTMQ",
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .apply(color: AppColors.white),
      ),
      subtitle: Text(
        "ltmq@gmail.com",
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .apply(color: AppColors.white),
      ),
      trailing: IconButton(
        icon: const Icon(
          Iconsax.edit,
          color: AppColors.white,
        ),
        onPressed: () => Get.to(const ProfileScreen()),
      ),
    );
  }
}
