// File: lib/features/shop/screens/product_reviews/widgets/review_card_widget.dart (tạo thư mục nếu chưa có)
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:readmore/readmore.dart'; // Thêm package này vào pubspec.yaml: readmore: ^2.2.0
import 'package:intl/intl.dart'; // Cho DateFormat

class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppSizes.iconMd, // Kích thước avatar
                  // Sử dụng userAvatar hoặc ảnh mặc định
                  backgroundImage: review.userAvatar != null && review.userAvatar!.isNotEmpty
                      ? NetworkImage(review.userAvatar!)
                      : const AssetImage(Images.user) as ImageProvider, // Đảm bảo Images.user tồn tại
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                Text(review.userName, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)), // Nút tùy chọn (nếu cần)
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),

        // Rating
        Row(
          children: [
            RatingBarIndicator(
              rating: review.rating.toDouble(),
              itemSize: AppSizes.iconLg, // Kích thước sao
              itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.spaceBtwItems),
            Text(DateFormat('dd/MM/yyyy').format(review.createdAt), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),

        // Comment
        ReadMoreText(
          review.comment,
          trimLines: 3,
          trimMode: TrimMode.Line,
          trimCollapsedText: ' xem thêm',
          trimExpandedText: ' ẩn bớt',
          moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

      ],
    );
  }
}