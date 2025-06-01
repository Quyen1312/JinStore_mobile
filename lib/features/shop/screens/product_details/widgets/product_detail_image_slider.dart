import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; 
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart'; 

class ProductDetailImageSlider extends StatelessWidget {
  const ProductDetailImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    // Sử dụng GetX để quản lý ảnh được chọn hiển thị lớn
    final RxString selectedImageUrl = (product.images.isNotEmpty ? product.images[0].url : '').obs;

    return CurvedEdgesWidget( // Widget bo cong các cạnh dưới của header
      child: Container(
        color: dark ? AppColors.darkerGrey : AppColors.light,
        child: Stack(
          children: [
            // -- Main Large Image
            SizedBox(
              height: 400, // Chiều cao của ảnh lớn
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.productImageRadius * 2),
                child: Center(
                  child: Obx(() => Image.network( // Hiển thị ảnh được chọn
                        selectedImageUrl.value.isNotEmpty
                            ? selectedImageUrl.value
                            : (product.images.isNotEmpty ? product.images[0].url : ''), // Ảnh mặc định nếu selected rỗng
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.image_not_supported, size: 100, color: AppColors.grey)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )),
                ),
              ),
            ),

            // -- Image Slider (thumbnail images)
            if (product.images.length > 1) // Chỉ hiển thị slider nếu có nhiều hơn 1 ảnh
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
                    itemCount: product.images.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.spaceBtwItems),
                    itemBuilder: (_, index) {
                      final imageUrl = product.images[index].url;
                      return Obx(() {
                        final isSelected = selectedImageUrl.value == imageUrl;
                        return RoundedImage(
                          width: 80,
                          isNetworkImage: true,
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          backgroundColor: dark ? AppColors.dark : AppColors.white,
                          // Thêm viền cho ảnh được chọn
                          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                          padding: const EdgeInsets.all(AppSizes.sm),
                          onTap: () => selectedImageUrl.value = imageUrl, // Cập nhật ảnh được chọn
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