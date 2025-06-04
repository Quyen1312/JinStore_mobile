import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; 
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailImageSlider extends StatelessWidget {
  const ProductDetailImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    
    // ✅ Fix: Kiểm tra product.images null và empty
    final hasImages = product.images != null && product.images!.isNotEmpty;
    final defaultImageUrl = hasImages ? product.images!.first.url : '';
    
    // ✅ Fix: Khởi tạo với giá trị an toàn
    final RxString selectedImageUrl = defaultImageUrl.obs;

    // Debug logging
    print('🛍️ ProductDetailImageSlider Debug:');
    print('- Has images: $hasImages');
    print('- Images count: ${product.images?.length ?? 0}');
    print('- Default image URL: $defaultImageUrl');

    return CurvedEdgesWidget(
      child: Container(
        color: dark ? AppColors.darkerGrey : AppColors.light,
        child: Stack(
          children: [
            // -- Main Large Image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.productImageRadius * 2),
                child: Center(
                  child: Obx(() {
                    final imageUrl = selectedImageUrl.value.isNotEmpty 
                        ? selectedImageUrl.value 
                        : defaultImageUrl;
                    
                    print('🖼️ Displaying main image: $imageUrl');
                    
                    // ✅ Fix: Hiển thị placeholder nếu không có ảnh
                    if (imageUrl.isEmpty) {
                      return Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: dark ? AppColors.dark : AppColors.light,
                          borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
                          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.image,
                              size: 100,
                              color: AppColors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có hình ảnh',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    // ✅ Sử dụng RoundedImage với network image
                    return RoundedImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 300,
                      isNetworkImage: true,
                      fit: BoxFit.contain,
                      backgroundColor: dark ? AppColors.dark : AppColors.white,
                      borderRadius: AppSizes.productImageRadius,
                      applyImageRadius: true,
                    );
                  }),
                ),
              ),
            ),

            // -- Back Button
            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: dark 
                    ? AppColors.black.withOpacity(0.7) 
                    : AppColors.white.withOpacity(0.8),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: dark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ),

            // ✅ Fix: Image Slider (thumbnail images) - Sử dụng RoundedImage
            if (hasImages && product.images!.length > 1)
              Positioned(
                right: 0,
                bottom: 30,
                left: AppSizes.defaultSpace,
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: product.images!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.spaceBtwItems),
                    itemBuilder: (_, index) {
                      final imageUrl = product.images![index].url;
                      print('🔄 Building thumbnail $index: $imageUrl');
                      
                      return Obx(() {
                        final isSelected = selectedImageUrl.value == imageUrl;
                        
                        return RoundedImage(
                          imageUrl: imageUrl,
                          width: 80,
                          height: 80,
                          isNetworkImage: true,
                          fit: BoxFit.cover,
                          backgroundColor: dark ? AppColors.dark : AppColors.white,
                          borderRadius: AppSizes.productImageRadius,
                          applyImageRadius: true,
                          // ✅ Highlight selected image với border
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.grey.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          padding: const EdgeInsets.all(AppSizes.xs),
                          onTap: () {
                            print('👆 Thumbnail tapped: $imageUrl');
                            selectedImageUrl.value = imageUrl;
                          },
                        );
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}