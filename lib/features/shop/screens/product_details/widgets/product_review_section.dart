import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/controllers/review_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/review_card.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductReviewsSection extends StatefulWidget {
  const ProductReviewsSection({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  late final ReviewController reviewController;

  @override
  void initState() {
    super.initState();
    final productTag = widget.product.id;
    if (Get.isRegistered<ReviewController>(tag: productTag)) {
      reviewController = Get.find<ReviewController>(tag: productTag);
    } else {
      reviewController = Get.put(ReviewController(), tag: productTag, permanent: false);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        reviewController.fetchProductReviews(widget.product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Sectionheading(
            title: 'Đánh giá & Nhận xét', showActionButton: false),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),

        Obx(() => OverallProductRating(
              averageRating: widget.product.averageRating,
              totalReviews: reviewController.productReviews.length,
            )),
        const SizedBox(height: AppSizes.spaceBtwItems),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.edit_2_copy),
            label: const Text('Viết đánh giá của bạn'),
            onPressed: () => _showSubmitReviewDialog(context, widget.product.id, reviewController),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg))),
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwSections),

        Obx(() => Sectionheading(
              title: 'Đánh giá gần đây (${reviewController.productReviews.length})',
              showActionButton: reviewController.productReviews.length > 3,
              buttonTitle: 'Xem tất cả',
              onPressed: () => Get.to(() => ProductReviewsScreen(
                productId: widget.product.id, 
                productTag: widget.product.id
              )),
            )),
        const SizedBox(height: AppSizes.spaceBtwItems),

        Obx(() {
          if (reviewController.isLoading.value && reviewController.productReviews.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: CircularProgressIndicator(color: AppColors.primary),
            ));
          }
          if (!reviewController.isLoading.value && reviewController.productReviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                child: Column(
                  children: [
                    Icon(Iconsax.message_notif_copy, size: 60, color: AppColors.darkGrey.withOpacity(0.7)),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text('Chưa có đánh giá nào.', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSizes.xs),
                    Text('Hãy là người đầu tiên chia sẻ cảm nhận của bạn!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey)),
                  ],
                ),
              ),
            );
          }
          final reviewsToShow = reviewController.productReviews.take(3).toList();
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewsToShow.length,
            itemBuilder: (context, index) {
              // Loại bỏ user parameter vì không cần thiết nếu ReviewCardWidget có thể tự lấy user info
              return ReviewCardWidget(review: reviewsToShow[index]);
            },
            separatorBuilder: (_, __) => const Divider(height: AppSizes.spaceBtwSections * 1.2, thickness: 0.5),
          );
        }),
        const SizedBox(height: AppSizes.spaceBtwSections),
      ],
    );
  }

  void _showSubmitReviewDialog(BuildContext context, String productId, ReviewController controller) {
    controller.resetReviewForm();
    controller.selectedReviewDetail.value = null;

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: AppSizes.lg, left: AppSizes.defaultSpace, right: AppSizes.defaultSpace,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg + AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: HelperFunctions.isDarkMode(context) ? AppColors.darkerGrey : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGrey.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 5,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Viết đánh giá của bạn", style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Iconsax.close_square_copy, color: AppColors.darkGrey),
                    onPressed: () => Get.back(),
                    tooltip: 'Đóng',
                  )
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Center(
                child: Obx(() => RatingBar.builder(
                  initialRating: controller.currentRating.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 40.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Iconsax.star_1, color: AppColors.warning),
                  onRatingUpdate: (rating) {
                    controller.currentRating.value = rating;
                  },
                )),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              TextFormField(
                controller: controller.commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'Nhận xét của bạn',
                  hintText: 'Chia sẻ cảm nhận chi tiết về sản phẩm (chất lượng, mẫu mã, dịch vụ,...). Đánh giá của bạn giúp người khác có lựa chọn tốt hơn!',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections * 1.5),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton.icon(
                  icon: controller.isLoading.value
                      ? const SizedBox.shrink()
                      : const Icon(Iconsax.send_1_copy),
                  label: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                      : const Text('Gửi đánh giá'),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          await controller.submitNewReview(productId: productId);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.inputFieldRadius),
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg))),
                )),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
    );
  }
}

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({
    super.key, 
    required this.productId, 
    required this.productTag
  });

  final String productId;
  final String productTag;

  @override
  Widget build(BuildContext context) {
    final ReviewController controller;
    if (Get.isRegistered<ReviewController>(tag: productTag)) {
      controller = Get.find<ReviewController>(tag: productTag);
    } else {
      print("CẢNH BÁO: ReviewController với tag '$productTag' không được tìm thấy cho ProductReviewsScreen. Sẽ tạo mới và fetch lại.");
      controller = Get.put(ReviewController(), tag: productTag, permanent: false);
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.productReviews.isEmpty ||
            (controller.productReviews.isNotEmpty && controller.productReviews.first.productId != productId)) {
             controller.fetchProductReviews(productId);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả Đánh giá')),
      body: Obx(() {
        if (controller.isLoading.value && controller.productReviews.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!controller.isLoading.value && controller.productReviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.message_notif_copy, size: 80, color: AppColors.darkGrey.withOpacity(0.7)),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text('Chưa có đánh giá nào cho sản phẩm này.', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  Text('Hãy là người đầu tiên để lại đánh giá!', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          itemCount: controller.productReviews.length,
          itemBuilder: (_, index) => ReviewCardWidget(review: controller.productReviews[index]),
          separatorBuilder: (_, __) => const Divider(height: AppSizes.spaceBtwSections * 1.2, thickness: 0.5, indent: AppSizes.sm, endIndent: AppSizes.sm),
        );
      }),
    );
  }
}