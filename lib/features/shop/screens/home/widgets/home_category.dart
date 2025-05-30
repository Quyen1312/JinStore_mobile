import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/category_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/category/category_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/all_product/all_products.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart'; 
import 'package:flutter_application_jin/utils/constants/sizes.dart'; 
import 'package:get/get.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = CategoryController.instance; 

    return Obx(() {
      // Hiển thị shimmer loading khi đang tải và danh sách rỗng
      if (categoryController.isLoading.value && categoryController.categoryList.isEmpty) {
        return const CategoryShimmer(itemCount: 6); 
      }

      // Hiển thị thông báo nếu danh sách rỗng sau khi tải xong
      if (categoryController.categoryList.isEmpty && !categoryController.isLoading.value) {
        return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.spaceBtwSections, bottom: AppSizes.spaceBtwSections),
              child: Text('Không có danh mục nào.',
                  // Sử dụng màu trắng nếu nền là PrimaryHeaderContainer (thường tối màu)
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white)),
            ));
      }

      // Hiển thị danh sách danh mục
      return SizedBox(
        height: 100, // Điều chỉnh chiều cao nếu cần để phù hợp với text và padding
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categoryController.categoryList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = categoryController.categoryList[index];
            // Lấy URL hình ảnh từ category.image.url
            // CategoryModel có trường 'image' là một đối tượng CategoryImage, chứa 'url'
            final imageUrl = category.image.url; 
            
            return VerticalImageText(
              image: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl: imageUrl,
              title: category.name,
              isNetworkImage: (imageUrl.isNotEmpty), 
              // Đặt màu chữ là trắng để dễ đọc trên PrimaryHeaderContainer
              textColor: AppColors.white, 
              backgroundColor: Colors.transparent, // Để không che nền header
              onTap: () {
                // Điều hướng đến màn hình hiển thị sản phẩm theo danh mục
                Get.to(() => AllProductScreen(
                      title: category.name,
                      futureMethod: ProductController.instance.fetchProductsByCategoryId(category.id), 
                    ));
              },
            );
          },
        ),
      );
    });
  }
}
