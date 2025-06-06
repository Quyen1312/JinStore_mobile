import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; 
import 'package:flutter_application_jin/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart'; 
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_review_section.dart'; 
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart'; 
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart'; 
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_application_jin/features/shop/controllers/review_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';

class ProductDetailScreen extends StatelessWidget { 
  const ProductDetailScreen({
    super.key, 
    required this.product,
    this.showBackArrow = true, // ✅ NEW: Optional parameter to control back arrow
  });

  final ProductModel product;
  final bool showBackArrow; // ✅ NEW: Control back arrow visibility

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controllers
    final reviewController = Get.put(ReviewController());
    Get.put(CartController()); // Đảm bảo CartController đã được put global hoặc ở đây

    // Tải review cho sản phẩm này khi màn hình được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.fetchProductReviews(product.id);
    });

    HelperFunctions.isDarkMode(context);

    return Scaffold(
      // ✅ FIXED: Conditional AppBar with back arrow
      appBar: Appbar(
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: showBackArrow, // ✅ Use the parameter
        actions: [
          const CartCounterIcon(),
          // ✅ NEW: Add home button when no back arrow
          if (!showBackArrow)
            IconButton(
              onPressed: () => Get.offAllNamed('/'),
              icon: const Icon(Iconsax.home),
              tooltip: 'Về trang chủ',
            ),
        ],
      ),
      bottomNavigationBar: BottomAddToCartWidget(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1 - Product Image Slider
            ProductDetailImageSlider(product: product),

            // 2 - Product Details
            Padding(
              padding: const EdgeInsets.only(
                  right: AppSizes.defaultSpace,
                  left: AppSizes.defaultSpace,
                  bottom: AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -- Rating & Share
                  RatingWidget(product: product),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // -- Price, Title, Stock, Brand
                  ProductMetaData(product: product),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // -- Description
                  const Sectionheading(title: 'Mô tả', showActionButton: false),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ReadMoreText(
                    product.description,
                    trimLines: 3,
                    colorClickableText: AppColors.primary,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Xem thêm',
                    trimExpandedText: ' Ẩn bớt',
                    style: Theme.of(context).textTheme.bodyMedium,
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // -- Reviews
                  ProductReviewsSection(product: product),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}