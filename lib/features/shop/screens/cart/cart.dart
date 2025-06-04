import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart'; // Giả sử bạn có CustomAppBar
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/discount_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/checkout.dart'; // Import màn hình Checkout
import 'package:flutter_application_jin/navigation_menu.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart'; // Cho JLoaders
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final discountController = Get.put(DiscountController()); // Initialize discount controller
    final bool dark = HelperFunctions.isDarkMode(context);

    // Listen to cart changes and recalculate discount
    ever(controller.cartTotalAmount, (double newTotal) {
      discountController.recalculateDiscountAmount(newTotal);
    });

    return Scaffold(
      appBar: Appbar( // Sử dụng CustomAppBar nếu có, hoặc AppBar thông thường
        title: Text('Giỏ hàng của bạn', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        actions: [
          Obx(() {
            // Chỉ hiển thị nút xóa nếu có ít nhất một loại sản phẩm trong giỏ
            if (controller.displayCartItems.isNotEmpty) {
              return IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Xác nhận xóa',
                    titleStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: AppSizes.fontSizeLg),
                    middleText: 'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng không? Thao tác này không thể hoàn tác.',
                    middleTextStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding: const EdgeInsets.all(AppSizes.md),
                    confirm: ElevatedButton(
                      onPressed: () async {
                        await controller.clearUserCart();
                        // Clear discount when cart is cleared
                        discountController.removeSelectedDiscount();
                        Get.back(); // Đóng dialog
                        Loaders.successSnackBar(title: 'Đã xóa', message: 'Giỏ hàng của bạn đã được làm trống.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, // Màu đỏ cho nút xóa
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
                      ),
                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: AppSizes.sm), child: Text('Xóa tất cả', style: TextStyle(color: AppColors.white))),
                    ),
                    cancel: OutlinedButton(
                      onPressed: () => Get.back(),
                       style: OutlinedButton.styleFrom(
                         side: BorderSide(color: dark ? AppColors.darkGrey : AppColors.grey),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
                       ),
                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: AppSizes.sm), child: Text('Hủy')),
                    ),
                  );
                },
                icon: const Icon(Iconsax.trash_copy, color: AppColors.error), // Icon rõ ràng hơn
                tooltip: 'Xóa toàn bộ giỏ hàng',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Trạng thái Loading
        if (controller.isLoading.value && controller.displayCartItems.isEmpty) { // Chỉ loading toàn màn hình nếu chưa có item nào
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // Trạng thái Lỗi
        if (controller.error.value.isNotEmpty && controller.displayCartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.warning_2_copy, size: 60, color: AppColors.warning),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text('Đã xảy ra lỗi', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSizes.sm),
                  Text(controller.error.value, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchCart(),
                    icon: const Icon(Iconsax.refresh_copy),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        }

        // Trạng thái Giỏ hàng trống (sau khi đã load xong và không có lỗi)
        if (controller.displayCartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Iconsax.shopping_bag_copy, size: 100, color: AppColors.darkGrey.withOpacity(0.5)),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Text('Giỏ hàng trống trơn!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Có vẻ như bạn chưa thêm sản phẩm nào vào giỏ. Hãy khám phá và mua sắm ngay nhé!',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections * 2),
                  ElevatedButton(
                    onPressed: () => Get.offAll(()=>const NavigationMenu()), // Điều hướng về trang chủ
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white
                    ),
                    child: const Text('Khám phá sản phẩm'),
                  ),
                ],
              ),
            ),
          );
        }

        // Hiển thị các mục trong giỏ hàng
        return SingleChildScrollView( // Bọc toàn bộ nội dung có thể cuộn (trừ bottom bar)
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              children: [
                // Header với checkbox chọn tất cả và thống kê
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkerGrey.withOpacity(0.5) : AppColors.lightContainer,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      // Row chọn tất cả
                      Row(
                        children: [
                          Obx(() => Checkbox(
                            value: controller.isAllSelected,
                            tristate: true,
                            onChanged: (bool? value) {
                              controller.toggleSelectAll();
                            },
                            activeColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                          Text(
                            'Chọn tất cả',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Text(
                            '${controller.selectedItemsCount}/${controller.displayCartItems.length} sản phẩm',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ],
                      ),
                      
                      // Thống kê tiết kiệm (nếu có)
                      Obx(() {
                        if (controller.selectedItemsSavings > 0) {
                          return Container(
                            margin: const EdgeInsets.only(top: AppSizes.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Iconsax.discount_shape_copy, 
                                     color: Colors.green, size: 16),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  'Tiết kiệm: ${controller.formatCurrency(controller.selectedItemsSavings)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),

                // Danh sách các Cart Items
                // CartItems widget đã được sửa để nhận showAddRemoveButtons
                const CartItems(showAddRemoveButtons: true),
                const SizedBox(height: AppSizes.spaceBtwSections),
              ],
            ),
          ),
        );
      }),
      
      // Thanh toán ở dưới cùng
      bottomNavigationBar: Obx(() {
        if (controller.displayCartItems.isEmpty || !controller.hasSelectedItems) {
          return const SizedBox.shrink(); // Không hiển thị thanh toán nếu giỏ hàng trống hoặc không có item nào được chọn
        }
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkerGrey : AppColors.lightContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadiusLg),
              topRight: Radius.circular(AppSizes.cardRadiusLg),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGrey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thông tin tổng tiền chi tiết
              if (controller.selectedItemsOriginalTotal > controller.cartTotalAmount.value) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền gốc:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      controller.formatCurrency(controller.selectedItemsOriginalTotal),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Giảm giá:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '-${controller.formatCurrency(controller.selectedItemsSavings)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSizes.spaceBtwItems),
              ],
              
              // Tổng cộng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng cộng:', style: Theme.of(context).textTheme.titleMedium),
                      Obx(() => Text(
                        '(${controller.selectedItemsCount} sản phẩm được chọn)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      )),
                    ],
                  ),
                  Obx(() => Text(
                        controller.formattedCartTotal, // Sử dụng formatted total
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              
              // Nút thanh toán
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (controller.hasSelectedItems) // Điều kiện cho phép nhấn nút
                      ? () {
                          // Load available discounts before going to checkout
                          discountController.fetchAvailableDiscountsForCurrentUser();
                          
                          // Có thể truyền danh sách sản phẩm được chọn vào CheckoutScreen
                          Get.to(() => const CheckoutScreen(), arguments: {
                            'selectedItems': controller.selectedItems,
                            'totalAmount': controller.cartTotalAmount.value,
                          });
                        }
                      : null, // Disable nút nếu không có item nào được chọn
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSizes.md),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white, 
                      fontWeight: FontWeight.bold
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.card_copy, size: 20),
                      const SizedBox(width: AppSizes.xs),
                      Text('Tiến hành thanh toán (${controller.selectedItemsCount})'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}