import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_item.dart'; // Đã sửa để nhận DisplayCartItem
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
// Import DisplayCartItem. Nó có thể được định nghĩa trong cart_service.dart hoặc file riêng.
import 'package:flutter_application_jin/service/cart_service.dart' show DisplayCartItem;
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Cho icon xóa
import 'package:intl/intl.dart'; // For currency formatting

class CartItems extends StatelessWidget {
  const CartItems({
    super.key,
    this.showAddRemoveButtons = true, // Prop để kiểm soát hiển thị nút tăng/giảm
    this.showCheckboxes = true, // NEW: Prop để kiểm soát hiển thị checkbox
    this.selectedItemsOnly = false, // NEW: Chỉ hiển thị các item được chọn
  });

  final bool showAddRemoveButtons;
  final bool showCheckboxes; // NEW: Control checkbox visibility
  final bool selectedItemsOnly; // NEW: Show only selected items

  /// Format tiền tệ theo định dạng Việt Nam
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    )}đ';
  }

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;

    return Obx(() {
      // Sử dụng displayCartItems từ CartController
      List<DisplayCartItem> items = controller.displayCartItems;
      
      // NEW: Filter to show only selected items if selectedItemsOnly is true
      if (selectedItemsOnly) {
        items = items.where((item) => item.isSelected).toList();
      }

      if (items.isEmpty) {
        // Nếu CartItems được thiết kế để là phần chính của màn hình giỏ hàng,
        // bạn có thể hiển thị thông báo giỏ hàng trống ở đây.
        // Tuy nhiên, nếu CartScreen (widget cha) đã xử lý việc này,
        // thì CartItems chỉ cần không hiển thị gì.
        return const SizedBox.shrink();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Nếu ListView này nằm trong một Scrollable khác
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSizes.spaceBtwSections), // Khoảng cách giữa các item
        itemBuilder: (context, index) {
          final displayItem = items[index]; // Đối tượng DisplayCartItem

          return Dismissible(
            key: ValueKey(displayItem.productId), // Sử dụng ValueKey cho sự ổn định
            direction: showAddRemoveButtons ? DismissDirection.endToStart : DismissDirection.none, // Disable swipe to delete in checkout
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSizes.defaultSpace),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              ),
              child: const Icon(Iconsax.trash_copy, color: Colors.white, size: AppSizes.iconLg),
            ),
            onDismissed: showAddRemoveButtons ? (direction) {
              controller.removeItemFromCart(displayItem.productId);
            } : null,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                border: Border.all(
                  color: displayItem.isSelected && showCheckboxes
                      ? Theme.of(context).primaryColor.withOpacity(0.3)
                      : Theme.of(context).dividerColor.withOpacity(0.2),
                  width: displayItem.isSelected && showCheckboxes ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              ),
              child: Column(
                children: [
                  // Row chứa checkbox (nếu có) và thông tin sản phẩm
                  Row(
                    children: [
                      // Checkbox - NEW: Only show if showCheckboxes is true
                      if (showCheckboxes) ...[
                        Checkbox(
                          value: displayItem.isSelected,
                          onChanged: (bool? value) {
                            controller.toggleItemSelection(displayItem.productId);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                      // Ảnh sản phẩm
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          child: displayItem.images.isNotEmpty
                              ? Image.network(
                                  displayItem.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Iconsax.image_copy, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Iconsax.image_copy, color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      // Thông tin sản phẩm
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên sản phẩm
                            Text(
                              displayItem.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            // Hiển thị giá
                            Row(
                              children: [
                                // Giá sau giảm (nổi bật)
                                Text(
                                  formatCurrency(displayItem.discountPrice),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                if (displayItem.discount != null && displayItem.discount! > 0) ...[
                                  const SizedBox(width: AppSizes.xs),
                                  // Giá gốc bị gạch
                                  Text(
                                    formatCurrency(displayItem.price),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.xs),
                                  // Phần trăm giảm giá
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.xs,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-${displayItem.discount!.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (displayItem.unit != null) ...[
                              const SizedBox(height: AppSizes.xs / 2),
                              Text(
                                'Đơn vị: ${displayItem.unit}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            // NEW: Show quantity in checkout mode
                            if (!showAddRemoveButtons) ...[
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                'Số lượng: ${displayItem.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Chỉ hiển thị các nút điều khiển số lượng nếu showAddRemoveButtons là true
                  if (showAddRemoveButtons) ...[
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    const Divider(),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    // Hàng chứa các nút tăng/giảm số lượng và tổng tiền của item
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút giảm số lượng
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (displayItem.quantity > 1) {
                                    controller.updateItemQuantity(
                                      displayItem.productId,
                                      displayItem.quantity - 1,
                                    );
                                  } else {
                                    // Hiển thị dialog xác nhận xóa nếu số lượng là 1
                                    Get.defaultDialog(
                                      title: 'Xóa sản phẩm',
                                      middleText:
                                          'Bạn có chắc chắn muốn xóa "${displayItem.name}" khỏi giỏ hàng?',
                                      confirm: ElevatedButton(
                                        onPressed: () {
                                          controller.removeItemFromCart(
                                              displayItem.productId);
                                          Get.back(); // Đóng dialog
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white),
                                        child: const Text('Xóa'),
                                      ),
                                      cancel: OutlinedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Hủy'),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: const Icon(Iconsax.minus, size: 16, color: Colors.grey),
                                ),
                              ),
                            ),
                            // Hiển thị số lượng hiện tại
                            Container(
                              width: 50,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                              child: Text(
                                displayItem.quantity.toString(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Nút tăng số lượng
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: InkWell(
                                onTap: () {
                                  controller.updateItemQuantity(
                                    displayItem.productId,
                                    displayItem.quantity + 1,
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: const Icon(Iconsax.add, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị tổng tiền của item này (giá đã giảm * số lượng)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency(displayItem.totalDiscountPrice),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (displayItem.discount != null && displayItem.discount! > 0) ...[
                              Text(
                                'Tiết kiệm: ${formatCurrency((displayItem.price - displayItem.discountPrice) * displayItem.quantity)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    // NEW: In checkout mode, show total price at the bottom
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    const Divider(),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thành tiền:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency(displayItem.totalDiscountPrice),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (displayItem.discount != null && displayItem.discount! > 0) ...[
                              Text(
                                'Tiết kiệm: ${formatCurrency((displayItem.price - displayItem.discountPrice) * displayItem.quantity)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      );
    });
  }
}