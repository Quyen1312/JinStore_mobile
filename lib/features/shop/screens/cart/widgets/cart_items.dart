import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/add_remove_button.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_item.dart'; // Đổi tên thành CartItemWidget
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart/cart_controller.dart'; // Import CartController
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart'; // Import CartItemModel
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class CartItems extends StatelessWidget {
  const CartItems({
    super.key, 
    this.showAddRemoveButton = true,
  });

  final bool showAddRemoveButton;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return Obx(() {
      if (cartController.cartItems.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceBtwSections),
            child: Text('Giỏ hàng của bạn đang trống!', style: Theme.of(context).textTheme.titleMedium),
          ),
        );
      }
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Nếu CartItems nằm trong SingleChildScrollView khác
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwSections),
        itemCount: cartController.cartItems.length,
        itemBuilder: (_, index) {
          final item = cartController.cartItems[index];
          return Column(
            children: [
              CartItemWidget(cartItem: item), // Truyền CartItemModel
              if (showAddRemoveButton) const SizedBox(height: AppSizes.spaceBtwItems),
              
              if (showAddRemoveButton)
                Padding( // Thêm Padding để căn chỉnh
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn chỉnh các phần tử
                    children: [
                      // Add remove button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SizedBox(width: 70), // Bỏ SizedBox cố định này
                          ProductQuantityWithAddRemoveButton(
                            quantity: item.quantity,
                            isLoading: cartController.isLoading.value,
                            add: () => cartController.incrementQuantity(item),
                            remove: () => cartController.decrementQuantity(item),
                          ),
                        ],
                      ),
                      
                      // Product total price for this item
                      ProductPriceText(price: (item.price * item.quantity).toStringAsFixed(0)), // Tính tổng tiền cho item này
                    ],
                  ),
                )
            ],
          );
        },
      );
    });
  }
}
