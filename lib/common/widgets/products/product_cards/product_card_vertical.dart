import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Đảm bảo model này KHÔNG yêu cầu oldPrice nếu bạn xóa hoàn toàn
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Import cần thiết cho CartController
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart'; // Để hiển thị SnackBar (Giả định tên lớp là JLoaders)

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    // Lấy CartController, đảm bảo nó đã được Get.put() ở đâu đó
    final cartController = Get.find<CartController>();

    return GestureDetector(
      // 1. Nhấn vào toàn bộ thẻ -> Đi đến chi tiết sản phẩm
      onTap: () {
        Get.toNamed('/product-detail', arguments: product);
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1), // Sử dụng padding nhỏ để border của shadow được rõ hơn
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
                    applyImageRadius: true, // Bo tròn cho chính ảnh
                    isNetworkImage: true,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),

            // -- Details
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems / 2),
                ],
              ),
            ),

            const Spacer(), // Đẩy phần giá và nút xuống dưới cùng

            // -- Price & Add to cart button
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm, bottom: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // -- Price
                  Flexible(
                    child: ProductPriceText(price: '${product.price}'),
                  ),

                  // -- Add to cart button
                  InkWell(
                    onTap: () {
                      // 2. Nhấn vào biểu tượng -> Thêm vào giỏ hàng
                      cartController.addToCart(product.id, 1);
                      Loaders.successSnackBar(
                          title: 'Thành công!',
                          message: '${product.name} đã được thêm vào giỏ hàng.');
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.cardRadiusMd),
                      bottomRight: Radius.circular(AppSizes.productImageRadius),
                    ),
                    child: Container(
                      width: AppSizes.iconLg * 1.2,
                      height: AppSizes.iconLg * 1.2,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
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