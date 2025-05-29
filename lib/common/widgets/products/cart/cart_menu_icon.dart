import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/screens/cart/cart.dart';

class CartCounterIcon extends StatelessWidget {
  const CartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor,
    this.counterTextCOlor,
  });

  final Color? iconColor, counterBgColor, counterTextCOlor;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IconButton(
        onPressed: () => Get.to(() => const CartScreen()),
        icon: Icon(Iconsax.shopping_bag, color: iconColor),
      ),
      Positioned(
        right: 0,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
          child: Center(
              child: Obx(
            () => Text(
              AppTexts.and,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .apply(color: AppColors.white, fontSizeFactor: 0.8),
            ),
          )),
        ),
      )
    ]);
  }
}
