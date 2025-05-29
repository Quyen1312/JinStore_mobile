import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../custom_shapes/containers/rounded_container.dart';

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 50,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
          color: dark ? AppColors.darkerGrey : AppColors.white,
        ),
        child: Column(
          children: [
            RoundedContainer(
              height: 180,
              width: 180,
              padding: const EdgeInsets.all(AppSizes.sm),
              backgroundColor: dark ? AppColors.dark : AppColors.white,
              child: Stack(
                children: [
                  // Thumbnail Image
                  Center(
                    child: RoundedImage(
                      height: 150,
                      width: 150,
                      isNetworkImage: true,
                      imageUrl: product.images.isNotEmpty ? product.images[0].url : '',
                      applyImageRadius: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),

            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text
                    ProductTitleText(
                      title: product.name,
                      smallSize: true,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Price
                      ProductPriceText(
                        price: product.price.toString(),
                        isLarge: true,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppSizes.cardRadiusMd),
                            bottomRight: Radius.circular(AppSizes.productImageRadius),
                          ),
                        ),
                        child: SizedBox(
                          width: AppSizes.iconLg * 1.2,
                          height: AppSizes.iconLg * 1.2,
                          child: const Center(
                            child: Icon(
                              Iconsax.add,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}