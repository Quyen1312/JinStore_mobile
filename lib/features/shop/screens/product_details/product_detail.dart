// File: lib/features/shop/screens/product_details/product_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart'; // Sửa tên class nếu bạn đổi
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_review_section.dart'; // File bạn cung cấp
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart'; // Import AppColors
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart'; // Import HelperFunctions
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sửa import từ iconsax -> iconsax_flutter
import 'package:readmore/readmore.dart';

// Controllers
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/review_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';


class ProductDetailScreen extends StatelessWidget { // Đổi tên class từ ProductDetail -> ProductDetailScreen
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controllers
    // final productController = Get.put(ProductController()); // Có thể đã put ở global
    final reviewController = Get.put(ReviewController());
    final cartController = Get.put(CartController()); // Đảm bảo CartController đã được put global hoặc ở đây

    // Tải review cho sản phẩm này khi màn hình được build
    // Gọi sau khi frame đầu tiên được render để tránh lỗi không cần thiết
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.fetchProductReviews(product.id);
      // Optional: làm mới thông tin sản phẩm hiện tại nếu cần
      // ProductController.instance.fetchProductById(product.id);
    });

    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: BottomAddToCartWidget(product: product), // Truyền product vào
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

                  // -- Price, Title, Stock, Brand (trong ProductMetaData)
                  ProductMetaData(product: product),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // -- Attributes (nếu sản phẩm có)
                  // if (product.productType == ProductType.variable.toString() && product.productAttributes != null && product.productAttributes!.isNotEmpty)
                  // ProductAttribute(product: product), // Cần ProductAttribute được thiết kế để xử lý attributes/variations
                  // const SizedBox(height: AppSizes.spaceBtwSections),


                  // -- Description
                  const Sectionheading(title: 'Mô tả', showActionButton: false), // Sử dụng JSectionHeading
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ReadMoreText(
                    product.description ?? 'Không có mô tả cho sản phẩm này.',
                    trimLines: 3, // Hiển thị tối đa 3 dòng ban đầu
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
                  // Sử dụng ProductReviewsSection bạn đã cung cấp
                  // Đảm bảo tên class Sectionheading trong file đó là JSectionHeading hoặc ngược lại cho nhất quán
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