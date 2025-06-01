import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_item.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class CartItems extends StatelessWidget {
  const CartItems({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;

    return Obx(() {
      final items = controller.cart['items'] as List? ?? [];
      
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwItems),
        itemBuilder: (context, index) {
          final item = items[index];
          return Dismissible(
            key: Key(item['productId']),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSizes.defaultSpace),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              controller.removeCartItem(item['productId']);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  CartItemWidget(
                    cartItem: CartItemModel(
                      id: item['productId'],
                      name: item['name'],
                      price: item['price'].toDouble(),
                      quantity: item['quantity'],
                      imageUrl: item['image'],
                      unit: item['unit'],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  
                  // Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Buttons
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (item['quantity'] > 1) {
                                controller.updateCartItem(
                                  item['productId'],
                                  item['quantity'] - 1,
                                );
                              } else {
                                Get.defaultDialog(
                                  title: 'Xóa sản phẩm',
                                  middleText: 'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?',
                                  confirm: ElevatedButton(
                                    onPressed: () {
                                      controller.removeCartItem(item['productId']);
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Xóa'),
                                  ),
                                  cancel: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Hủy'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            item['quantity'].toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () {
                              controller.updateCartItem(
                                item['productId'],
                                item['quantity'] + 1,
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),

                      // Item Total
                      Text(
                        '${(item['price'] * item['quantity']).toStringAsFixed(0)}đ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
