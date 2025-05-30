import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/category/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/all_product/all_products.dart';
import 'package:flutter_application_jin/features/shop/screens/search/search_screen.dart'; // Màn hình tìm kiếm mới
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/texts/section_heading.dart'; // Đổi tên Sectionheading
import 'widgets/home_appbar.dart';
import 'widgets/home_category.dart';
import 'widgets/home_promo_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = ProductController.instance;
    final categoryController = CategoryController.instance; // Đảm bảo CategoryController được đăng ký

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
                  const HomeAppBar(),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  // SearchBar - Điều hướng đến SearchScreen
                  SearchContainer(
                    text: 'Tìm kiếm trong cửa hàng...',
                    showBorder: true, 
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                    onTap: () => Get.to(() => const SearchScreen()), 
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Sectionheading( 
                          showActionButton: false,
                          title: 'Danh mục nổi bật',
                          textColor: AppColors.white,
                          onPressed: () {},
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        const HomeCategories(), 
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections * 1.5), // Tăng khoảng cách
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider - Cần dữ liệu động hoặc controller riêng
                  const PromoSlider(), 
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Sectionheading(
                    title: 'Sản phẩm nổi bật',
                    onPressed: () => Get.to(() => AllProductScreen(
                          title: 'Tất cả sản phẩm',
                          // Truyền danh sách allProducts để AllProductScreen hiển thị tất cả
                          products: productController.allProducts, 
                        )),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Obx(() {
                    // Sử dụng featuredProducts cho mục "Sản phẩm nổi bật"
                    if (productController.isLoadingFeaturedProducts.value && productController.featuredProducts.isEmpty) {
                      return const VerticalProductShimmer(itemCount: 4);
                    }
                    if (productController.featuredProducts.isEmpty && !productController.isLoadingFeaturedProducts.value) {
                      return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
                            child: Text('Không có sản phẩm nổi bật nào.',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ));
                    }
                    return GridLayout(
                      itemCount: productController.featuredProducts.length, // Chỉ hiển thị featuredProducts
                      mainAxisExtent: 288, // Có thể cần điều chỉnh
                      itemBuilder: (_, index) {
                        final product = productController.featuredProducts[index];
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
