import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/controllers/review_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/shop/screens/review/review_card.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/device/device_utility.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'package:flutter_application_jin/utils/constants/colors.dart';


class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final reviewController = Get.put(ReviewController()); 


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Sectionheading(title: 'Đánh giá & Nhận xét', showActionButton: false),
        const SizedBox(height: AppSizes.spaceBtwItems),

        OverallProductRating(
            averageRating: product.averageRating,
         
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // Nút viết đánh giá
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            child: const Text('Viết đánh giá của bạn'),
            onPressed: () => _showSubmitReviewDialog(context, product.id, reviewController),
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwSections),

        // Danh sách các review (hiển thị 2-3 review đầu tiên)
        Sectionheading(
          title: 'Đánh giá (${reviewController.productReviews.length})', // Lấy số lượng từ controller
          showActionButton: reviewController.productReviews.length > 2, // Hiển thị nút "Xem tất cả" nếu nhiều hơn 2 review
          buttonTitle: 'Xem tất cả',
          onPressed: () => Get.to(() => ProductReviewsScreen(productId: product.id)), // Điều hướng đến màn hình tất cả review
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        Obx(() {
          if (reviewController.isLoading.value && reviewController.productReviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reviewController.productReviews.isEmpty) {
            return const Center(child: Text('Chưa có đánh giá nào cho sản phẩm này.'));
          }
          // Hiển thị tối đa 3 review, hoặc ít hơn nếu không đủ
          final reviewsToShow = reviewController.productReviews.take(3).toList();
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewsToShow.length,
            itemBuilder: (context, index) {
              return ReviewCardWidget(review: reviewsToShow[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwSections),
          );
        }),
        const SizedBox(height: AppSizes.spaceBtwSections),
      ],
    );
  }

  // Hàm hiển thị dialog/modal để gửi review
  void _showSubmitReviewDialog(BuildContext context, String productId, ReviewController controller) {
    controller.resetReviewForm(); // Reset form mỗi khi mở dialog
    Get.bottomSheet( // Hoặc Get.dialog()
      SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
        child: Container(
          padding: EdgeInsets.only(
            top: AppSizes.lg,
            left: AppSizes.defaultSpace,
            right: AppSizes.defaultSpace,
            bottom: DeviceUtils.getKeyboardHeight() + AppSizes.lg, // Đẩy lên khi bàn phím xuất hiện
          ),
          decoration: BoxDecoration(
            color: HelperFunctions.isDarkMode(context) ? AppColors.darkerGrey : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadiusLg),
              topRight: Radius.circular(AppSizes.cardRadiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Để lại đánh giá", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Obx(() => RatingBar.builder(
                initialRating: controller.currentRating.value,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false, // Cho phép nửa sao nếu muốn
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: AppColors.primary,
                ),
                onRatingUpdate: (rating) {
                  controller.currentRating.value = rating;
                },
              )),
              const SizedBox(height: AppSizes.spaceBtwSections),
              TextFormField(
                controller: controller.commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bình luận của bạn',
                  hintText: 'Chia sẻ cảm nhận của bạn về sản phẩm...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null // Vô hiệu hóa nút khi đang tải
                      : () => controller.createReview(productId: productId),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Gửi đánh giá'),
                )),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Quan trọng cho bottom sheet có thể điều chỉnh chiều cao
    );
  }
}


// File: lib/features/shop/screens/product_reviews/widgets/overall_product_rating.dart
// (Tạo file mới cho widget này)
class OverallProductRating extends StatelessWidget {
  const OverallProductRating({
    super.key,
    required this.averageRating,
    // this.ratingDistribution, // Map<String, double> ví dụ: {"5": 0.8, "4": 0.1, ...}
  });

  final double averageRating;
  // final Map<String, double>? ratingDistribution;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(averageRating.toStringAsFixed(1), style: Theme.of(context).textTheme.displayLarge),
        ),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              // Đây là ví dụ đơn giản, bạn có thể dùng ratingDistribution để vẽ các thanh progress bar
              RatingBarIndicator(
                rating: averageRating,
                itemSize: AppSizes.iconLg,
                itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.primary),
              ),
              // TODO: Add rating progress bars based on ratingDistribution
              // Ví dụ: _buildRatingProgressIndicator("5", ratingDistribution?["5"] ?? 0, context),
            ],
          ),
        ),
      ],
    );
  }
  // Widget _buildRatingProgressIndicator(String text, double value, BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(flex: 1, child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
  //       Expanded(
  //         flex: 11,
  //         child: SizedBox(
  //           width: DeviceUtils.getScreenWidth(context) * 0.8,
  //           child: LinearProgressIndicator(
  //             value: value,
  //             minHeight: 11,
  //             backgroundColor: AppColors.grey,
  //             valueColor: const AlwaysStoppedAnimation(AppColors.primary),
  //             borderRadius: BorderRadius.circular(7),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

// File: lib/features/shop/screens/product_reviews/product_reviews_screen.dart
// (Tạo file mới cho màn hình này)
class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReviewController>(); 

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá & Nhận xét')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Obx(() {
          if (controller.isLoading.value && controller.productReviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.productReviews.isEmpty) {
            return const Center(child: Text('Chưa có đánh giá nào.'));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.productReviews.length,
            itemBuilder: (_, index) => ReviewCardWidget(review: controller.productReviews[index]),
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwSections),
          );
        }),
      ),
    );
  }
}