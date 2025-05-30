import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart/cart_controller.dart'; // Import CartController
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/cart.dart'; // Đường dẫn đến CartScreen

class CartCounterIcon extends StatelessWidget {
  const CartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor, // Sẽ dùng màu từ theme hoặc màu cố định
    // this.counterTextCOlor, // Sẽ dùng màu từ theme hoặc màu cố định
  });

  final Color? iconColor;
  final Color? counterBgColor;
  // final Color? counterTextCOlor; // Không cần nữa nếu style chung

  @override
  Widget build(BuildContext context) {
    // Lấy instance của CartController
    final CartController controller = Get.find<CartController>(); 
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        IconButton(
          onPressed: () => Get.to(() => const CartScreen()),
          icon: Icon(Iconsax.shopping_bag_copy, color: iconColor ?? (dark ? AppColors.white : AppColors.black)), // Thêm copy cho icon
        ),
        // Chỉ hiển thị bộ đếm nếu có sản phẩm trong giỏ
        Obx(() {
          if (controller.cartItemCount.value == 0) {
            return const SizedBox.shrink(); // Không hiển thị gì nếu giỏ hàng rỗng
          }
          return Positioned(
            right: 0,
            top: 0, // Điều chỉnh vị trí nếu cần
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                // Sử dụng màu đỏ hoặc màu primary cho background của bộ đếm
                color: counterBgColor ?? AppColors.error, 
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  controller.cartItemCount.value.toString(), // Hiển thị số lượng item
                  style: Theme.of(context).textTheme.labelSmall!.apply( // Dùng labelSmall cho vừa
                        color: AppColors.white, // Màu chữ cho bộ đếm
                        fontSizeFactor: 0.9,    // Giảm kích thước chữ một chút
                      ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
