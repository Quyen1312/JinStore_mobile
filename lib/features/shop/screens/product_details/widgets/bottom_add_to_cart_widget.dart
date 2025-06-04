// File: lib/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sửa import
import 'package:flutter_application_jin/common/widgets/icons/circular_icon.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart'; // Cho JLoaders

class BottomAddToCartWidget extends StatelessWidget { // Đổi tên class cho nhất quán
  const BottomAddToCartWidget({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance; // Hoặc Get.find<CartController>()
    final darkMode = HelperFunctions.isDarkMode(context);
    final RxInt quantity = 1.obs; // Quản lý số lượng bằng RxInt

    // Kiểm tra xem sản phẩm có trong giỏ hàng chưa để lấy số lượng hiện tại (nếu cần)
    // Hoặc đơn giản là luôn bắt đầu với 1 khi vào chi tiết sản phẩm mới.
    // final existingCartItem = cartController.getCartItemByProductId(product.id);
    // if (existingCartItem != null) {
    //   quantity.value = existingCartItem.quantity;
    // }


    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.defaultSpace,
          vertical: AppSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: darkMode ? AppColors.darkerGrey : AppColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircularIcon(
                icon: Iconsax.minus_copy, // Dùng minus_copy
                backgroundColor: darkMode ? AppColors.darkGrey : AppColors.lightGrey,
                width: 40,
                height: 40,
                color: darkMode ? AppColors.white : AppColors.black,
                onPressed: () {
                  if (quantity.value > 1) {
                    quantity.value--;
                  }
                },
              ),
              const SizedBox(width: AppSizes.spaceBtwItems),
              Obx(() => Text(quantity.value.toString(), style: Theme.of(context).textTheme.titleSmall)),
              const SizedBox(width: AppSizes.spaceBtwItems),
              CircularIcon(
                icon: Iconsax.additem_copy, // Dùng add_item_copy
                backgroundColor: AppColors.primary, // Màu chính
                width: 40,
                height: 40,
                color: AppColors.white,
                onPressed: () {
                  if (quantity.value < product.quantity) { // Kiểm tra stock
                    quantity.value++;
                  } else {
                    Loaders.warningSnackBar(title: 'Hết hàng', message: 'Số lượng sản phẩm trong kho không đủ.');
                  }
                },
              )
            ],
          ),
          ElevatedButton(
            onPressed: product.quantity > 0 ? () {
              // Sửa cách gọi addToCart: truyền toàn bộ object product và sử dụng named parameter quantity
              cartController.addItemToCart(product, quantity: quantity.value);
              // Có thể reset quantity về 1 sau khi thêm, hoặc giữ nguyên để user có thể tiếp tục tăng/giảm và cập nhật
              // quantity.value = 1; // Nếu muốn reset
              Loaders.successSnackBar(title: 'Thành công', message: '${product.name} (x${quantity.value}) đã được thêm vào giỏ hàng.');
            } : null, // Vô hiệu hóa nút nếu hết hàng
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(AppSizes.md),
              backgroundColor: product.quantity > 0 ? AppColors.primary : AppColors.darkGrey, // Thay đổi màu nút nếu hết hàng
              side: BorderSide(color: product.quantity > 0 ? AppColors.primary : AppColors.darkGrey),
            ),
            child: Text(product.quantity > 0 ? 'Thêm vào giỏ' : 'Hết hàng', style: const TextStyle(color: AppColors.white)),
          )
        ],
      ),
    );
  }
}