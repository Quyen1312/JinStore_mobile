import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class BottomAddToCart extends StatelessWidget {
  const BottomAddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = HelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.defaultSpace,
          vertical: AppSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: darkMode ? AppColors.darkerGrey : AppColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircularIcon(
                icon: Iconsax.minus,
                backgroundColor: AppColors.darkGrey,
                width: 40,
                height: 40,
                color: AppColors.white,
              ),
              const SizedBox(
                width: AppSizes.spaceBtwItems,
              ),
              Text(
                '2',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(
                width: AppSizes.spaceBtwItems,
              ),
              const CircularIcon(
                icon: Iconsax.add,
                backgroundColor: Colors.black,
                width: 40,
                height: 40,
                color: AppColors.white,
              )
            ],
          ),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.black),
              ),
              child: const Text('Add to Cart'))
        ],
      ),
    );
  }
}
