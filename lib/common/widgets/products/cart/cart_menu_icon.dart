import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart'; // Import HelperFunctions
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/cart.dart';

class CartCounterIcon extends StatelessWidget {
  const CartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor,
    // this.counterTextColor, // Đã loại bỏ vì màu chữ được đặt cố định là trắng
  });

  final Color? iconColor;
  final Color? counterBgColor;

  @override
  Widget build(BuildContext context) {
    // Lấy instance của CartController.
    // Đảm bảo CartController đã được Get.put() ở đâu đó trong ứng dụng.
    // Có thể dùng CartController.instance nếu bạn đã định nghĩa static getter.
    final CartController controller = Get.find<CartController>();
    final bool dark = HelperFunctions.isDarkMode(context); // Sử dụng HelperFunctions

    return Stack(
      children: [
        IconButton(
          onPressed: () => Get.to(() => const CartScreen()),
          // Icon giỏ hàng, màu sắc được ưu tiên từ prop, nếu không thì dựa trên theme
          icon: Icon(Iconsax.shopping_bag_copy,
              color: iconColor ?? (dark ? AppColors.white : AppColors.black)),
        ),
        // Bộ đếm số lượng sản phẩm
        Obx(() {
          // Chỉ hiển thị bộ đếm nếu cartItemCount > 0
          // cartItemCount trong CartController nên là tổng số lượng các đơn vị sản phẩm.
          if (controller.cartItemsCount.value == 0) { // Sử dụng cartItemsCount từ CartController đã sửa
            return const SizedBox.shrink(); // Không hiển thị gì nếu giỏ hàng rỗng
          }
          return Positioned(
            right: 0,
            top: 0, // Điều chỉnh vị trí của badge nếu cần
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                // Màu nền của badge, ưu tiên từ prop, nếu không thì dùng màu lỗi (thường là đỏ)
                color: counterBgColor ?? AppColors.error,
                borderRadius: BorderRadius.circular(100), // Bo tròn để tạo hình tròn
              ),
              child: Center(
                child: Text(
                  controller.cartItemsCount.value.toString(), // Hiển thị số lượng item
                  style: Theme.of(context).textTheme.labelSmall!.apply(
                        color: AppColors.white, // Màu chữ cho bộ đếm (thường là trắng)
                        fontSizeFactor: 0.9, // Điều chỉnh kích thước chữ một chút cho vừa vặn
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
