import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/images/rounded_images.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/product_model.dart';

class ProductDetailImageSlider extends StatelessWidget {
  const ProductDetailImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return CurvedEdgesWidget(
      child: Container(
        color: dark ? AppColors.darkerGrey : AppColors.light,
        child: Stack(
          children: [
            /// Main Large Image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.productImageRadius * 2),
                child: Center(
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images[0].url,
                          fit: BoxFit.contain,
                        )
                      : const Placeholder(),
                ),
              ),
            ),

            /// Image Slider
            if (product.images.length > 1)
              Positioned(
                right: 0,
                bottom: 30,
                left: AppSizes.defaultSpace,
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: product.images.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.spaceBtwItems),
                    itemBuilder: (_, index) => RoundedImage(
                      width: 80,
                      backgroundColor: dark ? AppColors.dark : AppColors.white,
                      border: Border.all(color: AppColors.primary),
                      padding: const EdgeInsets.all(AppSizes.sm),
                      imageUrl: product.images[index].url,
                    ),
                  ),
                ),
              ),

            // Appbar icons
            const Appbar(
              showBackArrow: true,
            )
          ],
        ),
      ),
    );
  }
}
