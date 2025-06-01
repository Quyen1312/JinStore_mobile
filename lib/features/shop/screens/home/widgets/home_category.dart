import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/category_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/all_products/all_products.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController(categoryService: Get.find()));

    return Obx(() {
      final isLoading = categoryController.isLoading.value;
      final categories = categoryController.categoryList;
      final error = categoryController.error.value;

      if (isLoading && categories.isEmpty) {
        return const CategoryShimmer();
      }

      if (error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Đã xảy ra lỗi', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Text(error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () => categoryController.fetchAllCategories(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }

      if (categories.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
            child: Text(
              'Không có danh mục nào.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
            ),
          ),
        );
      }

      return SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: categories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = categories[index];
            return VerticalImageText(
              image: category.image.url,
              title: category.name ?? '',
              isNetworkImage: category.image != null,
              textColor: AppColors.textWhite,
              backgroundColor: Colors.transparent,
              onTap: () {
                Get.to(() => AllProductScreen(
                      title: category.name,
                      futureMethod: ProductController.instance.fetchProductsByCategoryId(category.id)
                    ));
              },
            );
          },
        ),
      );
    });
  }
}
