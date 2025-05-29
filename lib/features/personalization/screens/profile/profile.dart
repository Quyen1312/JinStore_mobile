import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/change_password.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                    const CircularImage(
                      image: Images.banner1,
                      width: 80,
                      height: 80,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change Profile Picture',
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              const SizedBox(
                height: AppSizes.spaceBtwItems / 2,
              ),
              const Divider(),
              const SizedBox(
                height: AppSizes.spaceBtwItems,
              ),

              // Heading Profile Info
              const Sectionheading(title: 'Profile Information'),
              const SizedBox(
                height: AppSizes.spaceBtwItems,
              ),

              ProfileMenu(
                  onTap: () => Get.to(() => const ChangeName()),
                  title: 'Name',
                  value: 'ltmq'),
              ProfileMenu(
                  onTap: () {},
                  title: 'Username',
                  value: 'ltmq'),
              ProfileMenu(
                  onTap: () {},
                  title: 'E-mail',
                  value: ''),
              ProfileMenu(
                  onTap: () {},
                  title: 'Phone Number',
                  value: ''),
              ProfileMenu(onTap: () {}, title: 'Gender', value: ''),
              ProfileMenu(
                  onTap: () {}, title: 'Date of Birth', value: '10 Oct, 1994'),

              const Divider(),
              const SizedBox(
                height: AppSizes.spaceBtwItems,
              ),

              Center(
                child: TextButton(
                    onPressed: () => const ChangePassword(),
                    child: const Text(
                      'Change password',
                      style: TextStyle(color: AppColors.primary),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
