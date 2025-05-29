import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/device/device_utility.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? AppColors.black : AppColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        labelColor: dark ? AppColors.white : AppColors.darkerGrey,
        unselectedLabelColor: dark ? AppColors.white : AppColors.darkerGrey,
        indicatorColor: dark ? AppColors.white : AppColors.primary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(DeviceUtils.getAppBarHeight());
}
