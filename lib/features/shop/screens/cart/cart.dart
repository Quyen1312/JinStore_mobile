import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          // Clear cart button
          Obx(() {
            if (controller.cartItemCount.value > 0) {
              return IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Xóa giỏ hàng',
                    titleStyle: Theme.of(context).textTheme.headlineSmall,
                    content: const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Text(
                        'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    confirm: ElevatedButton(
                      onPressed: () {
                        controller.clearCart();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Xóa tất cả'),
                    ),
                    cancel: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Hủy'),
                    ),
                  );
                },
                icon: const Icon(Iconsax.trash),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Show loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error if any
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã xảy ra lỗi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  controller.error.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => controller.fetchCart(),
                    child: const Text('Thử lại'),
                  ),
                ),
              ],
            ),
          );
        }

        // Show empty cart
        if (controller.cartItemCount.value == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.shopping_bag, size: 64),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Text(
                  'Giỏ hàng trống',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Hãy thêm sản phẩm vào giỏ hàng của bạn',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ),
              ],
            ),
          );
        }

        // Show cart items
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: Column(
                    children: [
                      // Cart Items
                      const CartItems(),
                      const SizedBox(height: AppSizes.spaceBtwSections),

                      // Coupon TextField
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Nhập mã giảm giá',
                          prefixIcon: const Icon(Iconsax.discount_shape),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle coupon application
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(AppSizes.sm),
                              ),
                              child: const Text('Áp dụng'),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Checkout Bottom Bar
            Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                color: dark ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.cardRadiusLg),
                  topRight: Radius.circular(AppSizes.cardRadiusLg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền'),
                      Obx(() => Text(
                        '${controller.total.value.toStringAsFixed(0)}đ',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to checkout
                        if (controller.cartItemCount.value > 0) {
                          Get.toNamed('/checkout');
                        }
                      },
                      child: const Text('Thanh toán'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
