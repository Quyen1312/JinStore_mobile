import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Import cần thiết cho CartController
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({super.key, required this.product});

  final ProductModel product;

  // Helper method để format giá tiền
  String formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    )}đ';
  }

  // Helper method để tính giá sau discount
  double calculateDiscountPrice() {
    if (product.discount > 0) {
      return product.price * (1 - product.discount / 100);
    }
    return product.price;
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();
    final bool isOutOfStock = product.quantity <= 0;
    final double discountPrice = calculateDiscountPrice();
    final bool hasDiscount = product.discount > 0;

    return GestureDetector(
      // 1. Nhấn vào toàn bộ thẻ -> Đi đến chi tiết sản phẩm
      onTap: () {
        Get.toNamed('/product-detail', arguments: product);
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.1),
              blurRadius: 50,
              spreadRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            RoundedContainer(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm),
              backgroundColor: dark ? AppColors.dark : AppColors.light,
              child: Stack(
                children: [
                  // -- Thumbnail Image
                  RoundedImage(
                    imageUrl: product.images.isNotEmpty ? product.images[0].url : '',
                    applyImageRadius: true,
                    isNetworkImage: true,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  
                  // -- Discount Badge (nếu có discount)
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.discount.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),

            // -- Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Product Name (Phóng to và màu primary)
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 4),

                    // -- Product Description (Very compact)
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // -- Price & Add to cart button
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm, bottom: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // -- Price Section
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount Price
                        Text(
                          formatPrice(discountPrice),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        
                        // Original Price (if has discount)
                        if (hasDiscount)
                          Text(
                            formatPrice(product.price),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textSecondary.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // -- Add to cart button
                  InkWell(
                    onTap: isOutOfStock
                        ? () {
                            Loaders.warningSnackBar(
                                title: 'Hết hàng',
                                message: 'Sản phẩm ${product.name} hiện đã hết hàng.');
                          }
                        : () {
                            cartController.addItemToCart(product, quantity: 1);
                          },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.cardRadiusMd),
                      bottomRight: Radius.circular(AppSizes.productImageRadius),
                    ),
                    child: Container(
                      width: AppSizes.iconLg * 1.2,
                      height: AppSizes.iconLg * 1.2,
                      decoration: BoxDecoration(
                        color: isOutOfStock ? AppColors.darkGrey : AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.cardRadiusMd),
                          bottomRight: Radius.circular(AppSizes.productImageRadius),
                        ),
                      ),
                      child: const Center(
                          child: Icon(Iconsax.additem_copy, color: AppColors.white, size: AppSizes.iconMd)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}