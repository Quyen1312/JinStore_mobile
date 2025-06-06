import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/shop/controllers/order_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/product_detail.dart'; // ✅ NEW: Import ProductDetailScreen
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments as String? ?? '';
    final orderController = Get.find<OrderController>();
    final dark = HelperFunctions.isDarkMode(context);

    // Load order details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderId.isNotEmpty) {
        orderController.fetchOrderDetails(orderId);
      }
    });

    return Scaffold(
      appBar: Appbar(
        title: Text('Chi tiết đơn hàng', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        actions: [
          IconButton(
            onPressed: () => _copyOrderId(orderId),
            icon: const Icon(Iconsax.copy),
            tooltip: 'Sao chép mã đơn hàng',
          ),
        ],
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.error.value.isNotEmpty) {
          return _buildErrorState(context, orderController, orderId);
        }

        final order = orderController.currentOrderDetails.value;
        if (order == null) {
          return _buildNotFoundState(context);
        }

        return _buildContent(context, dark, order, orderController);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, OrderController controller, String orderId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, size: 64, color: Colors.grey),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text('Có lỗi xảy ra', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            Text(controller.error.value, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spaceBtwItems),
            ElevatedButton(
              onPressed: () => controller.fetchOrderDetails(orderId),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.shopping_bag, size: 64, color: Colors.grey),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text('Không tìm thấy đơn hàng', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.spaceBtwItems),
          ElevatedButton(onPressed: () => Get.back(), child: const Text('Quay lại')),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool dark, OrderModel order, OrderController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            // Order Header
            _buildOrderHeader(context, dark, order, controller),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Order Items
            _buildOrderItems(context, dark, order),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Shipping & Payment Info
            _buildShippingPaymentInfo(context, dark, order, controller),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Order Summary
            _buildOrderSummary(context, dark, order),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // ✅ FIXED: Action Buttons - No cancel button
            _buildActionButtons(context, order, controller),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Order header với status display chính xác
  Widget _buildOrderHeader(BuildContext context, bool dark, OrderModel order, OrderController controller) {
    final statusColor = _getStatusColor(order.status);
    
    return RoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: dark ? AppColors.dark : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã đơn hàng', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  Text('#${order.id.substring(order.id.length - 8).toUpperCase()}', 
                       style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(order.status), color: statusColor, size: 16),
                    const SizedBox(width: AppSizes.xs),
                    Text(_getStatusText(order.status), 
                         style: Theme.of(context).textTheme.labelMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          
          // Quick info
          Row(
            children: [
              _buildQuickInfo(context, 'Ngày đặt', HelperFunctions.getFormattedDate(order.createdAt), Iconsax.calendar),
              const SizedBox(width: AppSizes.spaceBtwItems),
              _buildQuickInfo(
                context, 
                'Thanh toán', 
                order.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán', 
                order.isPaid ? Iconsax.tick_circle : Iconsax.clock, 
                valueColor: order.isPaid ? Colors.green : Colors.orange
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(BuildContext context, String label, String value, IconData icon, {Color? valueColor}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, bool dark, OrderModel order) {
    return RoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: dark ? AppColors.dark : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sản phẩm đã đặt', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text('${order.orderItems.length} sản phẩm', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor)),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          
          // Product list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.orderItems.length,
            separatorBuilder: (_, __) => const Divider(height: AppSizes.spaceBtwItems * 2),
            itemBuilder: (_, index) => _buildProductItem(context, order.orderItems[index], order),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, OrderItemModel item, OrderModel order) {
    final canReview = (order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'received');
    
    return InkWell(
      onTap: () => _navigateToProduct(item, order),
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: const Icon(Iconsax.image, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: AppSizes.sm),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayName, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(HelperFunctions.formatCurrency(item.price), 
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                      const SizedBox(width: AppSizes.sm),
                      Text('x${item.quantity}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                  Text('Tổng: ${HelperFunctions.formatCurrency(item.price * item.quantity)}', 
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            
            // Actions - ✅ REMOVED: Arrow icon, only show review button
            Column(
              children: [
                if (canReview) ...[
                  GestureDetector(
                    onTap: () => _navigateToReview(item, order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.star, size: 10, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text('Đánh giá', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingPaymentInfo(BuildContext context, bool dark, OrderModel order, OrderController controller) {
    return RoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: dark ? AppColors.dark : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin giao hàng & thanh toán', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.spaceBtwItems),
          
          // Shipping address
          _buildInfoRow(context, 'Địa chỉ giao hàng', order.shippingAddressText, Iconsax.location),
          const SizedBox(height: AppSizes.spaceBtwItems / 2),
          
          // Payment method
          _buildInfoRow(context, 'Phương thức thanh toán', order.paymentMethod.toUpperCase(), 
                       order.paymentMethod.toLowerCase() == 'vnpay' ? Iconsax.card : Iconsax.money),
          const SizedBox(height: AppSizes.spaceBtwItems / 2),
          
          // Customer info if available
          if (order.hasCompleteUserInfo) ...[
            _buildInfoRow(context, 'Khách hàng', '${order.customerName} - ${order.customerPhone}', Iconsax.user),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
          ],
          
          // Note if available
          if (order.note != null && order.note!.isNotEmpty) ...[
            _buildInfoRow(context, 'Ghi chú', order.note!, Iconsax.note),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool dark, OrderModel order) {
    final subtotal = order.orderItems.fold<double>(0, (total, item) => total + (item.price * item.quantity));
    final discountAmount = order.discountId != null ? subtotal + order.shippingFee - order.totalAmount : 0.0;
    
    // Free shipping logic
    const double freeShippingThreshold = 500000.0;
    final wasFreeShipping = subtotal >= freeShippingThreshold && order.shippingFee == 0;
    
    return RoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: dark ? AppColors.dark : AppColors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính', style: Theme.of(context).textTheme.bodyMedium),
              Text(HelperFunctions.formatCurrency(subtotal), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems / 2),
          
          // Shipping fee với free shipping indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Phí vận chuyển', style: Theme.of(context).textTheme.bodyMedium),
                  if (wasFreeShipping) ...[
                    const SizedBox(width: AppSizes.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'MIỄN PHÍ',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                wasFreeShipping ? 'Miễn phí' : HelperFunctions.formatCurrency(order.shippingFee), 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: wasFreeShipping ? Colors.green : null,
                  fontWeight: wasFreeShipping ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
          
          if (discountAmount > 0) ...[
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giảm giá', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green)),
                Text('-${HelperFunctions.formatCurrency(discountAmount)}', 
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          
          const Divider(height: AppSizes.spaceBtwItems),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng thanh toán', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(HelperFunctions.formatCurrency(order.totalAmount), 
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Action buttons - REMOVED cancel button completely
  Widget _buildActionButtons(BuildContext context, OrderModel order, OrderController controller) {
    final List<Widget> buttons = [];

    // ✅ REMOVED: Cancel button logic completely removed

    // Mark as received button - only show when delivered
    if (order.status.toLowerCase() == 'delivered') {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markAsReceived(order, controller),
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('Xác nhận đã nhận hàng'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(AppSizes.md),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // Order again button
    if (order.status.toLowerCase() == 'received' || order.status.toLowerCase() == 'delivered') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(height: AppSizes.spaceBtwItems));
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _orderAgain(order),
            icon: const Icon(Iconsax.refresh),
            label: const Text('Đặt lại đơn hàng'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(AppSizes.md)),
          ),
        ),
      );
    }

    return buttons.isNotEmpty ? Column(children: buttons) : const SizedBox.shrink();
  }

  // Action methods
  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    Loaders.successSnackBar(title: 'Đã sao chép', message: 'Mã đơn hàng đã được sao chép');
  }

  void _navigateToProduct(OrderItemModel item, OrderModel order) {
    try {
      if (item.productDetails != null) {
        Get.toNamed('/product-detail', arguments: item.productDetails);
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('Thông tin sản phẩm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Thông tin chi tiết sản phẩm không khả dụng.'),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Text('Mã sản phẩm: ${item.productId}'),
                Text('Tên sản phẩm: ${item.displayName}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Loaders.warningSnackBar(
                    title: 'Đang phát triển',
                    message: 'Tính năng xem chi tiết sản phẩm đang được phát triển.',
                  );
                },
                child: const Text('Tìm sản phẩm'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Lỗi navigation',
        message: 'Không thể mở trang sản phẩm: ${e.toString()}',
      );
    }
  }

  void _navigateToReview(OrderItemModel item, OrderModel order) {
    try {
      // ✅ FIXED: Navigate to product details using Get.to
      if (item.productDetails != null) {
        Get.offAll(
          () => ProductDetailScreen(
            product: item.productDetails!,
          ),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        // Fallback dialog nếu không có product details
        Get.dialog(
          AlertDialog(
            title: const Text('Đánh giá sản phẩm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sản phẩm: ${item.displayName}'),
                const SizedBox(height: 8),
                Text('Mã đơn hàng: #${order.id.substring(order.id.length - 8).toUpperCase()}'),
                const SizedBox(height: 16),
                const Text('Thông tin sản phẩm không đầy đủ để mở trang chi tiết.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Lỗi navigation', 
        message: 'Không thể mở trang sản phẩm: ${e.toString()}',
      );
    }
  }

  // ✅ REMOVED: _cancelOrder method completely removed

  void _markAsReceived(OrderModel order, OrderController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận đã nhận hàng'),
        content: const Text('Bạn có chắc chắn đã nhận được hàng không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Chưa')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateExistingOrderStatus(orderId: order.id, newStatus: 'received');
            },
            child: const Text('Đã nhận hàng'),
          ),
        ],
      ),
    );
  }

  void _orderAgain(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đặt lại đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn cách thêm ${order.orderItems.length} sản phẩm vào giỏ hàng:'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            const Text(
              '• Thêm tự động: Thử thêm tất cả (có thể không thành công với một số sản phẩm)\n'
              '• Xem từng sản phẩm: Điều hướng đến từng sản phẩm để thêm thủ công',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          OutlinedButton(
            onPressed: () {
              Get.back();
              _navigateToProducts(order);
            },
            child: const Text('Xem từng sản phẩm'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _addToCart(order);
            },
            child: const Text('Thêm tự động'),
          ),
        ],
      ),
    );
  }

  void _navigateToProducts(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Danh sách sản phẩm'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: order.orderItems.length,
            itemBuilder: (context, index) {
              final item = order.orderItems[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.image, size: 20),
                ),
                title: Text(item.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Số lượng: ${item.quantity}'),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () {
                  Get.back();
                  _navigateToProduct(item, order);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _addToCart(OrderModel order) async {
    try {
      final cartController = Get.find<CartController>();
      int successCount = 0;
      int totalItems = order.orderItems.length;
      
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      for (final item in order.orderItems) {
        try {
          if (item.productDetails != null) {
            await cartController.addItemToCart(item.productDetails!, quantity: item.quantity);
            successCount++;
          } else {
            print('Warning: Product details not available for ${item.displayName}');
          }
        } catch (e) {
          print('Failed to add ${item.displayName}: $e');
        }
      }
      
      Get.back();
      
      if (successCount > 0) {
        Loaders.successSnackBar(
          title: 'Thành công',
          message: successCount == totalItems 
              ? 'Đã thêm tất cả sản phẩm vào giỏ hàng'
              : 'Đã thêm $successCount/$totalItems sản phẩm vào giỏ hàng',
        );
        Get.toNamed('/cart');
      } else {
        Loaders.warningSnackBar(
          title: 'Không thể thêm',
          message: 'Không thể thêm sản phẩm nào vào giỏ hàng. Thông tin sản phẩm không đầy đủ.',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      
      Loaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể thêm sản phẩm vào giỏ hàng: ${e.toString()}',
      );
    }
  }

  // ✅ FIXED: Helper methods với status display chính xác
  String _getStatusText(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'paid':
        return 'Đã thanh toán';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'received':
        return 'Đã nhận hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending': return Iconsax.clock;
      case 'paid': return Iconsax.tick_circle;
      case 'processing': return Iconsax.box;
      case 'shipping': return Iconsax.truck;
      case 'delivered': return Iconsax.location_tick;
      case 'received': return Iconsax.verify;
      case 'cancelled': return Iconsax.close_circle;
      default: return Iconsax.info_circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending': return Colors.orange;
      case 'paid': return Colors.green;
      case 'processing': return Colors.blue;
      case 'shipping': return Colors.purple;
      case 'delivered': return const Color(0xFF20B2AA); // Teal
      case 'received': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}