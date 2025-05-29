import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/category_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/category/category_controller.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/image_text_widgets/vertical_image_text.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const CategoryShimmer();
      }

      return SizedBox(
        height: 80,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.categoryList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = controller.categoryList[index];
            return VerticalImageText(
              image: category.image.url,
              title: category.name,
              onTap: () => Get.toNamed('/category/${category.id}'),
            );
          },
        ),
      );
    });
  }
}

