import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; // Sử dụng Appbar của bạn
import 'package:flutter_application_jin/features/shop/controllers/cart/cart_controller.dart'; // Import CartController
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/checkout.dart'; // Màn hình Checkout
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    // Gọi fetchUserCart nếu muốn tải lại giỏ hàng mỗi khi vào màn hình này,
    // nhưng thường thì CartController đã tự quản lý việc này.
    // cartController.fetchUserCart(); 

    return Scaffold(
      appBar: Appbar( // Sử dụng Appbar của bạn
        title: Text(
          'Giỏ hàng',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true, // Hiển thị nút back
      ),

      body: Obx(() { // Bọc body bằng Obx để rebuild khi isLoading thay đổi
          if (cartController.isLoading.value && cartController.cartItems.isEmpty) {
            return const Center(child: CircularProgressIndicator()); // Hiển thị loading nếu đang tải và chưa có item
          }
          // CartItems đã có xử lý Obx bên trong cho danh sách
          return const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: CartItems(), 
            ),
          );
        }
      ),

      bottomNavigationBar: Obx(() => cartController.cartItems.isEmpty
          ? const SizedBox.shrink() // Không hiển thị bottom bar nếu giỏ hàng rỗng
          : Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: ElevatedButton(
                onPressed: () {
                  // Kiểm tra xem giỏ hàng có trống không trước khi điều hướng
                  if (cartController.cartItems.isNotEmpty) {
                    Get.to(() => {}); // Điều hướng đến màn hình Checkout
                  } else {
                    Loaders.warningSnackBar(title: 'Giỏ hàng trống', message: 'Vui lòng thêm sản phẩm vào giỏ hàng trước khi thanh toán.');
                  }
                },
                child: Text('Thanh toán (${cartController.cartSubtotal.value.toStringAsFixed(0)} VND)'), // Hiển thị tổng tiền
              ),
            )),
    );
  }
}
