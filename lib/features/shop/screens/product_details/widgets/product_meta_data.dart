import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/circular_image.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import '../../../../../utils/constants/sizes.dart';

class ProductMetaData extends StatelessWidget {
  const ProductMetaData({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final darkMode = HelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Price & Sale Price
        Row(
          children: [
            /// Sale Tag
            if (product.discount > 0)
              Row(
                children: [
                  /// Actual Price
                  Text(
                    '\$${product.price}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(decoration: TextDecoration.lineThrough),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                ],
              ),

            /// Price
            ProductPriceText(
              price: product.discount > 0
                  ? (product.price * (1 - product.discount)).toString()
                  : product.price.toString(),
              isLarge: true,
            ),
          ],
        ), // Row
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),

        /// Title
        ProductTitleText(title: product.name),
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),

        /// Stock Status
        Row(
          children: [
            const ProductTitleText(title: 'Status'),
            const SizedBox(
              width: AppSizes.spaceBtwItems,
            ),
            Text(
              product.quantity > 0 ? 'In Stock' : 'Out of Stock',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),

        /// Brand
        if (product.categoryId != null)
          Row(
            children: [
              CircularImage(
                image: product.images.isNotEmpty ? product.images[0].url : '',
                width: 32,
                height: 32,
                overlayColor: darkMode ? AppColors.white : AppColors.black,
              ),
            ],
          )
      ],
    );
  }
}
