import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/icons/circular_icon.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/images.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../custom_shapes/containers/rounded_container.dart';
import '../../images/rounded_images.dart';
import '../../texts/product_price_text.dart';

class ProductCardHorizontal extends StatelessWidget {
  const ProductCardHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Container(
      width: 338,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
        color: dark ? AppColors.darkerGrey : AppColors.softGrey,
      ),
      child: Row(
        children: [
          // Thumbnail
          RoundedContainer(
            height: 128,
            padding: const EdgeInsets.all(AppSizes.sm),
            backgroundColor: dark ? AppColors.dark : AppColors.light,
            child: Stack(
              children: [
                const SizedBox(
                  height: 120,
                  width: 120,
                  child: RoundedImage(
                    imageUrl: Images.applePay,
                    applyImageRadius: true,
                  ),
                ),

                /// -- Sale Tag
                Positioned(
                  top: 12,
                  child: RoundedContainer(
                    radius: AppSizes.sm,
                    backgroundColor: AppColors.secondary.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm, vertical: AppSizes.xs),
                    child: Text('25%',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .apply(color: AppColors.black)),
                  ),
                ),

                ///-- Favourite Icon Button
                const Positioned(
                  top: 0,
                  right: 0,
                  child: CircularIcon(icon: Iconsax.heart5, color: Colors.red),
                ),
              ],
            ),
          ),

          // Details
          SizedBox(
            width: 196,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: AppSizes.sm, left: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductTitleText(
                        title: 'Green Nike Half Sleeves Shirt',
                        smallSize: true,
                      ),
                      SizedBox(
                        height: AppSizes.spaceBtwItems / 2,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pricing
                      const Flexible(child: ProductPriceText(price: '256.0')),
                      // Add to cart
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppSizes.cardRadiusMd),
                            bottomRight:
                                Radius.circular(AppSizes.productImageRadius),
                          ),
                        ),
                        child: const SizedBox(
                          width: AppSizes.iconLg * 1.2,
                          height: AppSizes.iconLg * 1.2,
                          child: Center(
                            child: Icon(Iconsax.add, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
