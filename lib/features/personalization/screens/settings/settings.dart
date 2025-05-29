import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:flutter_application_jin/common/widgets/list_tiles/profile_tile.dart';
import 'package:flutter_application_jin/common/widgets/list_tiles/settings_menu_tiles.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  Appbar(
                    title: Text(
                      'Account',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: AppColors.white),
                    ),
                  ),

                  // User Profile Card
                  const ProfileTile(),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Account Settings
                  const Sectionheading(title: 'Account Settings'),
                  const SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),

                  SettingsMenuTiles(
                      onTap: () {
                        Get.to(() {});
                      },
                      icon: Iconsax.safe_home,
                      title: 'My Addresses',
                      subTitle: 'Set shopping delivery address'),
                  SettingsMenuTiles(
                      onTap: () {
                      },
                      icon: Iconsax.shopping_cart,
                      title: 'My Cart',
                      subTitle: 'Add, remove products and move to checkout'),
                  SettingsMenuTiles(
                      onTap: () {
                        Get.to(() {});
                      },
                      icon: Iconsax.bag_tick,
                      title: 'My Orders',
                      subTitle: 'In-progress and Completed orders'),
                  SettingsMenuTiles(
                      onTap: () {
                        Get.to(() {});
                      },
                      icon: Iconsax.discount_shape,
                      title: 'My Coupons',
                      subTitle: 'List of all the discounted coupons'),
                  // Logout button
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {
                        },
                        child: const Text('Logout')),
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections * 1.5,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
