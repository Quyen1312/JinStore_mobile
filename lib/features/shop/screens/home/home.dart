import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
// Import controllers - đảm bảo chỉ import một lần và đúng đường dẫn
import 'package:flutter_application_jin/features/shop/controllers/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Import Product model
import 'package:flutter_application_jin/features/shop/screens/all_products/all_products.dart'; // Sửa đường dẫn nếu cần (all_product -> all_products)
import 'package:flutter_application_jin/features/shop/screens/search/search_screen.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/texts/section_heading.dart'; // Sử dụng JSectionHeading
import 'widgets/home_appbar.dart'; // Đảm bảo đây là JAppBar hoặc HomeAppBar tùy chỉnh của bạn
import 'widgets/home_category.dart';
import 'widgets/home_promo_slider.dart'; // Giữ nguyên PromoSlider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng .instance hoặc Get.find() vì controller đã được put trong DependencyInjection
    final productController = Get.put(ProductController());
    
    // CategoryController được HomeCategories sử dụng nội bộ qua .instance hoặc Get.find()
    // final categoryController = CategoryController.instance; // Không cần put lại ở đây nếu HomeCategories đã xử lý

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
                  // Sử dụng HomeAppBar tùy chỉnh của bạn
                   HomeAppBar(),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  SearchContainer(
                    text: 'Tìm kiếm trong cửa hàng...',
                    showBorder: true,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                    onTap: () => Get.to(() => const SearchScreen()), // Điều hướng đến SearchScreen đã tạo
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Sectionheading( // Sử dụng JSectionHeading
                          showActionButton: false,
                          title: 'Danh mục nổi bật',
                          textColor: AppColors.white,
                          onPressed: () => const AllProductScreen(title: '') // Có thể điều hướng đến màn hình tất cả danh mục
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        // HomeCategories tự xử lý việc lấy CategoryController và hiển thị
                        const HomeCategories(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections * 1.5),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider - Giữ nguyên theo code của bạn, về lâu dài cần HomeController
                  const PromoSlider(),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // Heading Sản phẩm nổi bật
                  Sectionheading( // Sử dụng JSectionHeading
                    title: 'Sản phẩm nổi bật',
                    showActionButton: true, // Hiển thị nút "Xem tất cả"
                    buttonTitle: 'Xem tất cả',
                    onPressed: () => Get.to(() => const AllProductScreen(
                          title: 'Tất cả sản phẩm',
                          // Không cần truyền futureMethod hay products ở đây nữa
                          // AllProductsScreen sẽ tự lấy dữ liệu qua ProductController
                        )),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Products Grid - Sử dụng ProductController.products
                  Obx(() {
                    // Hiển thị shimmer khi đang tải và danh sách sản phẩm rỗng
                    if (productController.isLoadingAllProducts.value && productController.allProducts.isEmpty) {
                      return const VerticalProductShimmer(itemCount: 4);
                    }

                    // Hiển thị lỗi nếu có và danh sách sản phẩm rỗng
                    if (productController.error.value.isNotEmpty && productController.allProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lỗi: ${productController.error.value}', textAlign: TextAlign.center),
                            const SizedBox(height: AppSizes.spaceBtwItems),
                            ElevatedButton(
                              onPressed: () => productController.fetchAllProducts(), // Gọi lại fetchProducts
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Hiển thị nếu không có sản phẩm nào (sau khi đã tải xong)
                    if (productController.allProducts.isEmpty && !productController.isLoadingAllProducts.value) {
                       return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
                          child: Text('Không có sản phẩm nổi bật nào.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ));
                    }

                    // Lấy 4 sản phẩm đầu tiên làm sản phẩm nổi bật
                    final featuredProducts = productController.allProducts.take(4).toList();

                    return GridLayout( // Hoặc GridView.builder nếu bạn muốn
                      itemCount: featuredProducts.length,
                      mainAxisExtent: 288,
                      itemBuilder: (_, index) {
                        final ProductModel product = featuredProducts[index]; // Đảm bảo product là kiểu Product
                        return ProductCardVertical(product: product);
                      },
                    );
                  }),
                ],
              ),
            ),
             const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}