// File: lib/features/shop/screens/product_details/widgets/product_meta_data.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart'; // Cho sale tag
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
// import 'package:flutter_application_jin/common/widgets/images/circular_image.dart'; // Nếu có brand image
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart'; // Nếu có icon verify cho brand

class ProductMetaData extends StatelessWidget {
  const ProductMetaData({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final darkMode = HelperFunctions.isDarkMode(context);
    final salePercentage = product.discount; // Ví dụ: 10.0 cho 10%
    final originalPrice = product.price; // Giả sử product.price là giá gốc
    double discountedPrice = originalPrice;

    if (salePercentage != null && salePercentage > 0) {
      discountedPrice = originalPrice * (1 - (salePercentage / 100));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Price & Sale Price
        Row(
          children: [
            // Sale Tag (Hiển thị % giảm giá)
            if (salePercentage != null && salePercentage > 0)
              RoundedContainer(
                radius: AppSizes.sm,
                backgroundColor: AppColors.secondary.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
                child: Text('${salePercentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelLarge!.apply(color: AppColors.black)),
              ),
            if (salePercentage != null && salePercentage > 0) const SizedBox(width: AppSizes.spaceBtwItems),

            // Giá cũ (nếu có giảm giá)
            if (salePercentage != null && salePercentage > 0)
              ProductPriceText(
                price: '${product.price}', // Giá gốc
                lineThrough: true, // Gạch ngang
              ),
            if (salePercentage != null && salePercentage > 0) const SizedBox(width: AppSizes.spaceBtwItems / 2),
            
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),

        // -- Title
        ProductTitleText(title: product.name),
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),

        // -- Stock Status
        Row(
          children: [
            const ProductTitleText(title: 'Tình trạng: '),
            const SizedBox(width: AppSizes.spaceBtwItems / 2),
            Text(
              product.quantity > 0 ? 'Còn hàng (${product.quantity})' : 'Hết hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: product.quantity > 0 ? AppColors.success : AppColors.error
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 1.5),
      ],
    );
  }
}