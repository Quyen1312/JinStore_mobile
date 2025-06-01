// File: lib/features/shop/screens/product_details/widgets/rating_share_widget.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sửa import cho đúng
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Import ProductModel
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class RatingAndShare extends StatelessWidget {
  const RatingAndShare({
    super.key,
    required this.product, // Thêm tham số product
  });

  final ProductModel product; // Khai báo product

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rating
        Row(
          children: [
            const Icon(Iconsax.star_1, color: Colors.amber, size: 24), // Sử dụng star_1 nếu muốn icon đầy sao
            const SizedBox(width: AppSizes.spaceBtwItems / 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    // Sử dụng product.rating, định dạng 1 chữ số sau dấu phẩy
                    text: product.averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}