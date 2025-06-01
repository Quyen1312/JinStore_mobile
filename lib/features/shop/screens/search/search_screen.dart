import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; // Đổi tên thành JAppBar nếu đó là tên lớp của bạn
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Import Product model để GridLayout có thể dùng
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // final productController = Get.put(ProductController()); // Nên dùng Get.find() nếu đã put ở global, hoặc Get.lazyPut
  // Để tránh khởi tạo lại controller mỗi khi vào màn hình, tốt nhất là ProductController được quản lý global hơn.
  // Tuy nhiên, nếu đây là lần đầu tiên dùng, Get.put() là OK.
  // Hoặc, nếu ProductController đã được put ở đâu đó (ví dụ main.dart hoặc 1 binding):
  final ProductController productController = Get.find<ProductController>();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear previous search results when entering the screen
    // Chỉ clear nếu searchQuery không rỗng, để giữ lại trạng thái nếu người dùng quay lại từ chi tiết sản phẩm
    // Hoặc luôn clear tùy theo UX bạn muốn.
    // Nếu người dùng đang chủ động vào màn Search, thì việc clear là hợp lý.
    productController.searchResults.clear();
    productController.searchQuery.value = ''; // Reset query trong controller

    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    // Không nên cancel _debounceTimer ở đây vì nó thuộc về ProductController
    // ProductController sẽ tự quản lý timer của nó trong onClose.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: Appbar( // Đảm bảo tên lớp Appbar của bạn là 'Appbar' hoặc 'JAppBar'
        title: Text('Tìm kiếm', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            // Search TextField
            TextFormField(
              controller: searchController,
              focusNode: searchFocusNode,
              // SỬA Ở ĐÂY: Gọi performClientSearch
              onChanged: (value) => productController.performClientSideSearch(value), // Không cần trim() ở đây nếu performClientSearch đã trim()
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.search_normal_copy), // Dùng _copy cho icon filled hơn nếu muốn
                suffixIcon: Obx(() {
                  return productController.searchQuery.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            productController.performClientSideSearch(''); // Gọi với query rỗng để clear results và reset states
                            FocusScope.of(context).requestFocus(searchFocusNode);
                          },
                          icon: const Icon(Iconsax.close_circle_copy), // Dùng _copy
                        )
                      : const SizedBox.shrink();
                }),
                hintText: 'Tìm kiếm sản phẩm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: BorderSide(color: dark ? AppColors.darkGrey : AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: BorderSide(color: dark ? AppColors.darkGrey : AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: const BorderSide(color: AppColors.primary), // Giữ const nếu AppColors.primary là const
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Search Results
            Expanded(
              child: Obx(() {
                // Show loading state
                if (productController.isPerformingClientSearch.value) {
                  return const VerticalProductShimmer(itemCount: 4);
                }

                // Show empty state when no query OR after a query if searchResults is empty but query is not (để phân biệt)
                if (productController.searchQuery.value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.search_normal_1_copy, // Dùng _copy
                          size: 72,
                          color: dark ? AppColors.darkerGrey : AppColors.grey,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Text(
                          'Tìm kiếm sản phẩm',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                // Show not found state (query is not empty, but no results)
                if (productController.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.search_zoom_out_copy, // Dùng _copy hoặc icon khác
                          size: 72,
                          color: dark ? AppColors.darkerGrey : AppColors.grey,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Text(
                          'Không tìm thấy sản phẩm',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems / 2),
                        Text(
                          'Thử tìm kiếm với từ khóa khác nhé!', // Sửa lỗi chính tả
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Show results
                return GridLayout(
                  itemCount: productController.searchResults.length,
                  itemBuilder: (context, index) {
                    // Đảm bảo searchResults chứa đối tượng Product
                    final ProductModel product = productController.searchResults[index];
                    return ProductCardVertical(product: product);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}