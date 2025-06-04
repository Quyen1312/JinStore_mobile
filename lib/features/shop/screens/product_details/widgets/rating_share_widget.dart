import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Iconsax.star_1, color: AppColors.warning, size: AppSizes.iconMd),
        const SizedBox(width: AppSizes.xs / 2),
        Text(
          product.averageRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        // Ghi chú: ProductModel hiện tại không có trường numReviews.
        // Nếu bạn muốn hiển thị số lượt đánh giá ở đây, ProductModel cần được cập nhật.
        // Ví dụ, nếu có product.numReviews:
        // if (product.numReviews > 0)
        //   Text(
        //     ' (${product.numReviews})',
        //     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
        //   ),
      ],
    );
  }
}

// Widget hiển thị tổng quan rating và số lượt đánh giá
class OverallProductRating extends StatelessWidget {
  const OverallProductRating({
    super.key,
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                Text(
                  '/ 5.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.darkGrey),
                )
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceBtwItems),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: averageRating,
                  itemSize: AppSizes.iconLg,
                  unratedColor: AppColors.grey.withOpacity(0.5),
                  itemBuilder: (_, __) =>
                      const Icon(Iconsax.star_1, color: AppColors.warning),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  totalReviews > 0 ? '$totalReviews đánh giá' : 'Chưa có đánh giá',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
