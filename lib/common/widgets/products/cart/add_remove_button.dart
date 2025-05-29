import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/icons/circular_icon.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class ProductQuantityWithAddRemoveButton extends StatelessWidget {
  const ProductQuantityWithAddRemoveButton({
    super.key,
    required this.quantity,
    this.add,
    this.remove,
  });

  final int quantity;
  final VoidCallback? add, remove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularIcon(
          onPressed: remove,
          icon: Iconsax.minus,
          width: 32,
          height: 32,
          size: AppSizes.md,
          color: HelperFunctions.isDarkMode(context)
              ? AppColors.white
              : AppColors.black,
          backgroundColor: HelperFunctions.isDarkMode(context)
              ? AppColors.darkerGrey
              : AppColors.light,
        ),
        const SizedBox(
          width: AppSizes.spaceBtwItems,
        ),
        Text(
          quantity.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(
          width: AppSizes.spaceBtwItems,
        ),
        CircularIcon(
          onPressed: add,
          icon: Iconsax.add,
          width: 32,
          height: 32,
          size: AppSizes.md,
          color: HelperFunctions.isDarkMode(context)
              ? AppColors.white
              : AppColors.black,
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}
