import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';

class HomeAppBar extends StatelessWidget {
  HomeAppBar({
    super.key,
  });

  final cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Appbar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.homeAppbarTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: AppColors.grey),
          ),
          Text(
            AppTexts.homeAppbarSubTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: AppColors.grey),
          ),
        ],
      ),
      actions: const [
        CartCounterIcon(
          iconColor: AppColors.white,
        )
      ],
    );
  }
}
