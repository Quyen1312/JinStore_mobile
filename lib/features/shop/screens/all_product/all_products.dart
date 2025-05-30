import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class AllProductScreen extends StatelessWidget {
  final String title;
  final Future<void>? futureMethod; // Future để tải sản phẩm (ví dụ: theo category)
  final List<ProductModel>? products; // Hoặc danh sách sản phẩm đã có sẵn

  const AllProductScreen({
    super.key,
    required this.title,
    this.futureMethod,
    this.products,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu không có futureMethod và không có products, thì mặc định lấy allProducts từ controller
    // Điều này cho phép màn hình này được tái sử dụng.
    final productController = ProductController.instance;

    return Scaffold(
      appBar: Appbar(
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: FutureBuilder<void>(
            future: futureMethod, // Nếu futureMethod được cung cấp, nó sẽ được thực thi
            builder: (context, snapshot) {
              // Hiển thị Shimmer khi futureMethod đang chạy (nếu có)
              // Hoặc khi isLoading của controller là true nếu không có futureMethod
              final isLoading = futureMethod != null 
                                  ? snapshot.connectionState == ConnectionState.waiting 
                                  : productController.isLoadingCategoryProducts.value; // Hoặc isLoadingCategoryProducts tùy ngữ cảnh

              if (isLoading && (products == null || products!.isEmpty)) {
                return const VerticalProductShimmer(itemCount: 6);
              }

              // Xác định danh sách sản phẩm để hiển thị
              List<ProductModel> displayProducts = products ?? productController.allProducts;
              // Nếu đang xem sản phẩm theo danh mục và futureMethod đã chạy xong (hoặc không có futureMethod)
              // thì productsByCategory sẽ được dùng nếu nó không rỗng.
              // Điều này cần logic rõ ràng hơn khi gọi màn hình này.
              // Ví dụ, nếu title là "Sản phẩm theo [Tên Danh Mục]", thì dùng productsByCategory.
              // Tạm thời, nếu `products` được truyền vào, dùng nó, nếu không thì dùng `allProducts`.
              // Nếu bạn muốn hiển thị `productsByCategory` ở đây, bạn cần truyền nó vào `products`
              // hoặc có một cách để `productController` biết ngữ cảnh.

              if (displayProducts.isEmpty && !isLoading) {
                return Center(
                    child: Text('Không có sản phẩm nào để hiển thị.',
                        style: Theme.of(context).textTheme.bodyMedium));
              }

              return GridLayout(
                itemCount: displayProducts.length,
                itemBuilder: (_, index) => ProductCardVertical(
                  product: displayProducts[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
