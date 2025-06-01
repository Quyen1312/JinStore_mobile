import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; // Sửa thành JAppBar
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:flutter_application_jin/common/widgets/list_tiles/profile_tile.dart';
import 'package:flutter_application_jin/common/widgets/list_tiles/settings_menu_tiles.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart'; // Sửa thành JSectionHeading
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Import AuthController
import 'package:flutter_application_jin/features/personalization/screens/address/address.dart'; // Import UserAddressScreen// Import ProfileScreen
import 'package:flutter_application_jin/features/shop/screens/cart/cart.dart'; // Import CartScreen // Import CouponsScreen (hoặc tên đúng của màn hình coupons)
import 'package:flutter_application_jin/features/shop/screens/discount/discount.dart';
import 'package:flutter_application_jin/features/shop/screens/order/order.dart'; // Import OrderScreen
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sửa import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy instance của AuthController để dùng cho logout
    final authController = AuthController.instance; // Hoặc Get.find<AuthController>()

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  Appbar( // Sử dụng JAppBar
                    title: Text(
                      'Tài khoản', // Đổi 'Account' thành 'Tài khoản' cho nhất quán
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: AppColors.white),
                    ),
                    showBackArrow: true, // Thêm nút back nếu SettingsScreen không phải là tab chính
                    // Hoặc nếu là tab chính thì không cần showBackArrow và title có thể căn giữa hoặc trái
                  ),

                  // User Profile Card
                  const ProfileTile(),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh SectionHeading sang trái
                children: [
                  // Account Settings
                  const Sectionheading(title: 'Cài đặt tài khoản', showActionButton: false), // Sử dụng JSectionHeading
                  const SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),

                  SettingsMenuTiles(
                      onTap: () => Get.to(() => const UserAddressScreen()), // Điều hướng đến UserAddressScreen
                      icon: Iconsax.location_copy, // Dùng _copy cho icon filled hơn
                      title: 'Địa chỉ của tôi',
                      subTitle: 'Thiết lập địa chỉ giao hàng'),
                  SettingsMenuTiles(
                      onTap: () => Get.to(() => const CartScreen()), // Điều hướng đến CartScreen
                      icon: Iconsax.shopping_cart_copy, // Dùng _copy
                      title: 'Giỏ hàng của tôi',
                      subTitle: 'Thêm, xóa sản phẩm và thanh toán'),
                  SettingsMenuTiles(
                      onTap: () => Get.to(() => const OrderScreen()), // Điều hướng đến OrderScreen
                      icon: Iconsax.bag_tick_copy, // Dùng _copy
                      title: 'Đơn hàng của tôi',
                      subTitle: 'Đơn hàng đang xử lý và đã hoàn thành'),
                  SettingsMenuTiles(
                      onTap: () => Get.to(() => DiscountScreen()), // Điều hướng đến CouponsScreen (đảm bảo tên class đúng)
                      icon: Iconsax.discount_shape_copy, // Dùng _copy
                      title: 'Mã giảm giá',
                      subTitle: 'Danh sách các mã giảm giá của bạn'),

                  // Logout button
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {
                          authController.logout(); // Gọi hàm logout từ AuthController
                        },
                        child: const Text('Đăng xuất')), // Đổi 'Logout' thành 'Đăng xuất'
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections * 1.5, // Giữ nguyên 2.5 nếu bạn muốn khoảng trống lớn hơn
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}