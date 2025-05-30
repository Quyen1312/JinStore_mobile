import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/chips/choice_chips.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import '../../../../../utils/constants/sizes.dart';

class ProductAttribute extends StatelessWidget {
  const ProductAttribute({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final darkMode = HelperFunctions.isDarkMode(context);
    return Column(
      children: [
        // -- Selected Attribute Pricing & Description
        RoundedContainer(
          padding: const EdgeInsets.all(AppSizes.md),
          backgroundColor: darkMode ? AppColors.darkerGrey : AppColors.grey,
          child: Column(
            children: [
              // Title, Product and Stock Status
              Row(
                children: [
                  const Sectionheading(
                      title: 'Information', showActionButton: false),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ProductTitleText(
                              title: 'Price : ', smallSize: true),
                          const SizedBox(width: AppSizes.spaceBtwItems),

                          // Actual Price
                          if (product.discount != null && product.discount! > 0) ...[
                            Text(
                              '\$${product.price}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .apply(
                                      decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: AppSizes.spaceBtwItems),
                          ],

                          // Sale Price
                          ProductPriceText(
                            price: product.discount != null && product.discount! > 0
                                ? (product.price! * (1 - product.discount!))
                                    .toString()
                                : product.price!.toString(),
                          ),
                        ],
                      ),

                      // Stock
                      Row(
                        children: [
                          const ProductTitleText(
                              title: 'Stock : ', smallSize: true),
                          Text(
                            product.quantity > 0
                                ? '${product.quantity} ${product.unit}'
                                : 'Out of Stock',
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),

              // Variation Description
              if (product.description.isNotEmpty)
                ProductTitleText(
                  title: product.description,
                  smallSize: true,
                  maxLines: 4,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // -- Attributes
        if (product.information.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Sectionheading(title: 'Product Information'),
              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              Wrap(
                spacing: 8,
                children: product.information
                    .map(
                      (info) => CustomChoiceChip(
                        text: '${info.key}: ${info.value}',
                        selected: false,
                        onSelected: (_) {},
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
