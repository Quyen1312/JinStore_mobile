import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_category.dart';
import 'widgets/home_promo_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    return Scaffold(
      backgroundColor: HelperFunctions.isDarkMode(context)
          ? AppColors.dark
          : AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  //  AppBar
                  const HomeAppBar(),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),

                  // SearchBar
                  SearchContainer(
                    text: 'Search in store'.tr,
                    showBorder: false,
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),

                  // Categories
                  const Padding(
                    padding: EdgeInsets.only(left: AppSizes.defaultSpace),
                    child: Column(
                      children: [
                        // Heading
                        Sectionheading(
                          showActionButton: false,
                          title: 'Popular Categories',
                          textColor: AppColors.white,
                        ),
                        SizedBox(
                          height: AppSizes.spaceBtwItems,
                        ),

                        // Categories
                        HomeCategories(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider
                  const PromoSlider(),

                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),

                  // Popular Products
                  Sectionheading(
                    title: 'Popular Products'.tr,
                    showActionButton: true,
                    onPressed: () => Get.toNamed('/products'),
                  ),
                  const SizedBox(
                    height: AppSizes.sm,
                  ),
                  Obx(() {
                    if (productController.isLoading.value) {
                      return const VerticalProductShimmer();
                    }

                    return GridLayout(
                      itemCount: productController.productList.length,
                      itemBuilder: (_, index) {
                        final product = productController.productList[index];
                        return ProductCardVertical(product: product);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


