import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/shop/controllers/order_controller.dart';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/features/shop/screens/order/order_details_screen.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';

class OrderListItems extends StatefulWidget {
  const OrderListItems({super.key});

  @override
  State<OrderListItems> createState() => _OrderListItemsState();
}

class _OrderListItemsState extends State<OrderListItems> {
  final RxString _selectedStatus = 'all'.obs;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final orderController = Get.put(OrderController());

    return Obx(() {
      return Column(
        children: [
          // Status Filter Tabs
          _buildStatusFilterTabs(context, orderController),
          const SizedBox(height: AppSizes.spaceBtwSections),
          
          // Orders List
          _buildOrdersList(context, dark, orderController),
        ],
      );
    });
  }

  // ✅ UPDATED: Status filter tabs để match với backend enum
  Widget _buildStatusFilterTabs(BuildContext context, OrderController controller) {
    final List<Map<String, String>> statusTabs = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'pending', 'label': 'Chờ xác nhận'},
      {'key': 'paid', 'label': 'Đã thanh toán'}, // Chỉ cho VNPay
      {'key': 'processing', 'label': 'Đang xử lý'},
      {'key': 'shipping', 'label': 'Đang giao'},
      {'key': 'delivered', 'label': 'Đã giao'},
      {'key': 'received', 'label': 'Đã nhận'}, // COD sẽ hiển thị ở đây khi received
      {'key': 'cancelled', 'label': 'Đã hủy'},
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusTabs.length,
        itemBuilder: (context, index) {
          final tab = statusTabs[index];
          final isSelected = _selectedStatus.value == tab['key'];
          
          return GestureDetector(
            onTap: () {
              _selectedStatus.value = tab['key']!;
              _filterOrdersByStatus(controller, tab['key']!);
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, 
                vertical: AppSizes.sm
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
              ),
              child: Center(
                child: Text(
                  tab['label']!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppColors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterOrdersByStatus(OrderController controller, String status) {
    if (status == 'all') {
      controller.fetchMyOrders(); // Fetch all orders
    } else {
      controller.fetchMyOrders(status: status); // Fetch orders by status with exact backend enum
    }
  }

  Widget _buildOrdersList(BuildContext context, bool dark, OrderController controller) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.error.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              controller.error.value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            ElevatedButton(
              onPressed: () => controller.fetchMyOrders(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (controller.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.shopping_bag,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'Chưa có đơn hàng nào',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Các đơn hàng của bạn sẽ xuất hiện ở đây',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => controller.fetchMyOrders(),
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(
            height: AppSizes.spaceBtwItems,
          ),
          itemCount: controller.orders.length,
          itemBuilder: (_, index) {
            final order = controller.orders[index];
            return _buildOrderItem(context, dark, order, controller);
          },
        ),
      ),
    );
  }

  // ✅ FIXED: Correct status display and no cancel button
  Widget _buildOrderItem(BuildContext context, bool dark, OrderModel order, OrderController controller) {
    // ✅ FIXED: Get correct status color using the proper method
    final statusColor = _getStatusColor(order.status);
    
    return RoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: dark ? AppColors.dark : AppColors.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Status and Action
          Row(
            children: [
              // Status Icon
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: statusColor,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.spaceBtwItems / 2),

              // Status & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ FIXED: Use correct Vietnamese status text
                    Text(
                      _getStatusText(order.status),
                      style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: statusColor,
                        fontWeightDelta: 1,
                      ),
                    ),
                    Text(
                      HelperFunctions.getFormattedDate(order.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Action Button
              IconButton(
                onPressed: () => _viewOrderDetails(order, controller),
                icon: const Icon(
                  Iconsax.arrow_right_34,
                  size: AppSizes.iconSm,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),

          // Row 2: Order Info
          Row(
            children: [
              // Order ID
              Expanded(
                child: Row(
                  children: [
                    const Icon(Iconsax.tag),
                    const SizedBox(width: AppSizes.spaceBtwItems / 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            '#${order.id.substring(order.id.length - 8).toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Total Amount
              Expanded(
                child: Row(
                  children: [
                    const Icon(Iconsax.money),
                    const SizedBox(width: AppSizes.spaceBtwItems / 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng tiền',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            HelperFunctions.formatCurrency(order.totalAmount),
                            style: Theme.of(context).textTheme.titleMedium!.apply(
                              color: AppColors.primary,
                              fontWeightDelta: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Row 3: Items & Payment info
          const SizedBox(height: AppSizes.spaceBtwItems / 2),
          Row(
            children: [
              // Items Count
              Expanded(
                child: Row(
                  children: [
                    const Icon(Iconsax.shopping_cart, size: AppSizes.iconSm),
                    const SizedBox(width: AppSizes.spaceBtwItems / 2),
                    Text(
                      '${order.orderItems.length} sản phẩm',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Payment Method & Status
              Row(
                children: [
                  Icon(
                    order.paymentMethod.toLowerCase() == 'vnpay' 
                        ? Iconsax.card 
                        : Iconsax.money_recive,
                    size: AppSizes.iconSm,
                    color: _getPaymentStatusColor(order),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems / 2),
                  Text(
                    _getPaymentDisplayText(order),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPaymentStatusColor(order),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✅ REMOVED: Cancel button logic completely removed
          // Only show "Mark as received" button when applicable
          if (_shouldShowReceivedButton(order))
            ..._buildReceivedButton(context, order, controller),
        ],
      ),
    );
  }

  // ✅ FIXED: Only show received button, no cancel button
  bool _shouldShowReceivedButton(OrderModel order) {
    return order.status.toLowerCase() == 'delivered';
  }

  List<Widget> _buildReceivedButton(BuildContext context, OrderModel order, OrderController controller) {
    return [
      const SizedBox(height: AppSizes.spaceBtwItems),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _markAsReceived(context, order, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xác nhận đã nhận hàng'),
        ),
      ),
    ];
  }

  void _viewOrderDetails(OrderModel order, OrderController controller) {
    Get.to(() => const OrderDetailsScreen(), arguments: order.id);
  }

  void _markAsReceived(BuildContext context, OrderModel order, OrderController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận đã nhận hàng'),
        content: const Text('Bạn có chắc chắn đã nhận được hàng không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Chưa'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateExistingOrderStatus(
                orderId: order.id,
                newStatus: 'received',
              );
            },
            child: const Text('Đã nhận hàng'),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Correct status display methods
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return const Color(0xFF20B2AA); // Teal
      case 'received':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Iconsax.clock;
      case 'paid':
        return Iconsax.tick_circle;
      case 'processing':
        return Iconsax.box;
      case 'shipping':
        return Iconsax.truck;
      case 'delivered':
        return Iconsax.location_tick;
      case 'received':
        return Iconsax.verify;
      case 'cancelled':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  // ✅ FIXED: Correct payment status display
  String _getPaymentDisplayText(OrderModel order) {
    if (order.paymentMethod.toLowerCase() == 'vnpay') {
      return order.isPaid ? 'VNPay (Đã TT)' : 'VNPay (Chưa TT)';
    } else {
      // COD
      return order.status.toLowerCase() == 'received' 
          ? 'COD (Đã TT)' 
          : 'COD';
    }
  }

  Color _getPaymentStatusColor(OrderModel order) {
    if (order.paymentMethod.toLowerCase() == 'vnpay') {
      return order.isPaid ? Colors.green : Colors.orange;
    } else {
      // COD
      return order.status.toLowerCase() == 'received' 
          ? Colors.green 
          : Colors.orange;
    }
  }
}