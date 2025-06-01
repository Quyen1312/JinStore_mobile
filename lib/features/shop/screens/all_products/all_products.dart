import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; // Sử dụng JAppBar
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Model là class Product
import 'package:flutter_application_jin/service/product/product_service.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart'; // Chỉ cần import 'package:get/get.dart';

class AllProductScreen extends StatelessWidget {
  final String title;
  final Future<void>? futureMethod; // Future để kích hoạt tải sản phẩm
  final List<ProductModel>? products;    // Hoặc danh sách sản phẩm đã có sẵn

  const AllProductScreen({
    super.key,
    required this.title,
    this.futureMethod,
    this.products,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng instance vì controller đã được put ở global
    final productController = Get.put(ProductController());

    // Widget dùng để hiển thị lưới sản phẩm, bọc trong Obx để theo dõi thay đổi
    Widget buildProductGrid(List<ProductModel> productsToDisplay) {
      if (productsToDisplay.isEmpty) {
        return Center(
          child: Text('Không có sản phẩm nào để hiển thị.',
              style: Theme.of(context).textTheme.bodyMedium),
        );
      }
      return GridLayout(
        itemCount: productsToDisplay.length,
        itemBuilder: (_, index) => ProductCardVertical(
          product: productsToDisplay[index],
        ),
      );
    }

    // Widget chính hiển thị sản phẩm dựa trên Obx từ ProductController
    // Được sử dụng khi futureMethod hoàn thành hoặc khi không có futureMethod/products trực tiếp
    Widget controllerDrivenProductList() {
      return Obx(() {
        if (productController.isLoadingAllProducts.value && productController.allProducts.isEmpty) {
          return const VerticalProductShimmer(itemCount: 6);
        }
        if (productController.error.value.isNotEmpty && productController.allProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${productController.error.value}', textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () {
                    // Cần một cách để gọi lại đúng phương thức fetch ban đầu
                    // Ví dụ: nếu màn hình này cho category, gọi lại getProductsByCategory
                    // Tạm thời, gọi fetchProducts() (tải tất cả)
                    if (futureMethod == null && products == null) { // Chỉ gọi nếu không có phương thức tải cụ thể nào khác
                       productController.fetchAllProducts();
                    } else if (futureMethod != null) {
                       // Người dùng cần cung cấp cách gọi lại futureMethod hoặc logic tương ứng
                       // Ví dụ: (futureMethod as Function)(); // Cần ép kiểu và cẩn thận
                       // Hoặc controller có hàm retryLastFetch()
                    }
                  },
                  child: const Text('Thử lại'),
                )
              ],
            ),
          );
        }
        return buildProductGrid(productController.allProducts);
      });
    }

    return Scaffold(
      appBar: Appbar( // Sử dụng JAppBar
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: () { // Sử dụng IIFE (Immediately Invoked Function Expression) để chọn widget hiển thị
            if (products != null) {
              // Trường hợp 1: Hiển thị danh sách sản phẩm được truyền trực tiếp
              if (products!.isEmpty) {
                return Center(
                  child: Text('Không có sản phẩm nào để hiển thị.',
                      style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              return buildProductGrid(products!);
            } else if (futureMethod != null) {
              // Trường hợp 2: Sử dụng FutureBuilder để đợi futureMethod
              return FutureBuilder<void>(
                future: futureMethod,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const VerticalProductShimmer(itemCount: 6);
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                            Text('Lỗi tải dữ liệu: ${snapshot.error}', textAlign: TextAlign.center),
                            const SizedBox(height: AppSizes.spaceBtwItems),
                            ElevatedButton(
                              onPressed: () {
                                // Cần có cơ chế để thử lại futureMethod
                                // Ví dụ: nếu futureMethod được truyền từ StatefulWidget, StatefulWidget đó có thể setState để trigger lại
                                print("Cần cơ chế retry cho futureMethod");
                              },
                              child: const Text('Thử lại')
                            )
                         ],
                      )
                    );
                  }
                  // Khi futureMethod hoàn thành (thành công),
                  // productController.products sẽ được cập nhật (nếu futureMethod làm vậy).
                  // Hiển thị danh sách sản phẩm từ controller.
                  return controllerDrivenProductList();
                },
              );
            } else {
              // Trường hợp 3: Không có products trực tiếp, không có futureMethod.
              // Hiển thị sản phẩm từ ProductController (đã được tải từ onInit hoặc trước đó).
              return controllerDrivenProductList();
            }
          }(),
        ),
      ),
    );
  }
}