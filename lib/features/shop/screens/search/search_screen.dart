import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductController productController = ProductController.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Xóa kết quả tìm kiếm cũ và query khi vào màn hình
    // Không nên xóa allProducts ở đây
    productController.searchResults.clear();
    productController.searchQuery.value = ''; 
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Khi rời màn hình tìm kiếm, có thể muốn xóa kết quả để lần sau vào lại là mới
    // Hoặc giữ lại tùy theo UX mong muốn.
    // productController.searchResults.clear();
    // productController.searchQuery.value = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool darkMode = HelperFunctions.isDarkMode(context);
    // Lắng nghe thay đổi của _searchController để cập nhật searchQuery trong ProductController
    // Điều này đảm bảo debounce hoạt động ngay cả khi người dùng xóa text bằng nút clear
    _searchController.addListener(() {
      if (_searchController.text != productController.searchQuery.value) {
        productController.onSearchQueryChanged(_searchController.text.trim());
      }
    });

    return Scaffold(
      appBar: Appbar(
        title: Text('Tìm kiếm', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập tên sản phẩm để tìm...',
                prefixIcon: const Icon(Iconsax.search_normal_1_copy),
                suffixIcon: Obx(() {
                  if (productController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Iconsax.close_circle_copy),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).requestFocus(_searchFocusNode);
                      },
                    );
                  } else {
                    return const SizedBox.shrink(); // Return an empty widget
                  }
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: BorderSide(color: darkMode ? AppColors.darkGrey : AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: BorderSide(color: darkMode ? AppColors.darkGrey : AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              onChanged: (query) {
                productController.onSearchQueryChanged(query.trim());
              },
              // onFieldSubmitted không cần thiết nếu dùng debounce onChanged
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            Expanded(
              child: Obx(() {
                // Hiển thị shimmer khi isPerformingClientSearch là true VÀ searchQuery không rỗng
                if (productController.isPerformingClientSearch.value && productController.searchQuery.isNotEmpty) {
                   return const VerticalProductShimmer(itemCount: 6);
                }
                // Hiển thị "Không tìm thấy" nếu có query, không có kết quả, và không đang tìm kiếm
                if (productController.searchQuery.value.isNotEmpty && productController.searchResults.isEmpty && !productController.isPerformingClientSearch.value) {
                  return Center(
                    child: Text(
                      'Không tìm thấy sản phẩm nào cho "${productController.searchQuery.value}".',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // Hiển thị thông báo ban đầu nếu chưa có query
                if (productController.searchResults.isEmpty && productController.searchQuery.value.isEmpty) {
                   return Center(
                    child: Text(
                      'Nhập từ khóa để tìm kiếm sản phẩm.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // Hiển thị kết quả
                return GridLayout(
                  itemCount: productController.searchResults.length,
                  itemBuilder: (_, index) => ProductCardVertical(
                    product: productController.searchResults[index],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
