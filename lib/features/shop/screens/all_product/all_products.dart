import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class AllProductScreen extends StatelessWidget {
  const AllProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                if (productController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GridLayout(
                  itemCount: productController.productList.length,
                  itemBuilder: (_, index) => ProductCardVertical(
                    product: productController.productList[index],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}