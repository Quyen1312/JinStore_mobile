import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/shop/controllers/order_controller.dart';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';// Import order details screen
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

  Widget _buildStatusFilterTabs(BuildContext context, OrderController controller) {
    final List<Map<String, String>> statusTabs = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'pending', 'label': 'Chờ xác nhận'},
      {'key': 'paid', 'label': 'Đã thanh toán'},
      {'key': 'processing', 'label': 'Đang xử lý'},
      {'key': 'shipping', 'label': 'Đang giao'},
      {'key': 'delivered', 'label': 'Đã giao'},
      {'key': 'received', 'label': 'Đã nhận'},
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
      controller.fetchMyOrders(status: status); // Fetch orders by status
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

  Widget _buildOrderItem(BuildContext context, bool dark, OrderModel order, OrderController controller) {
    final statusColor = _getStatusColor(controller.getOrderStatusColor(order.status));
    
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
                    Text(
                      controller.getOrderStatusText(order.status),
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

          // Row 3: Order Items Count & Payment Method
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
              
              // Payment Method
              Row(
                children: [
                  Icon(
                    order.paymentMethod.toLowerCase() == 'vnpay' 
                        ? Iconsax.card 
                        : Iconsax.money_recive,
                    size: AppSizes.iconSm,
                    color: order.isPaid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems / 2),
                  Text(
                    order.paymentMethod.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.apply(
                      color: order.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons (if applicable)
          if (_shouldShowActionButtons(order, controller))
            ..._buildActionButtons(context, order, controller),
        ],
      ),
    );
  }

  bool _shouldShowActionButtons(OrderModel order, OrderController controller) {
    return controller.canUserCancelOrder(order.status) || 
           controller.canUserUpdateOrder(order.status);
  }

  List<Widget> _buildActionButtons(BuildContext context, OrderModel order, OrderController controller) {
    final buttons = <Widget>[];
    
    if (controller.canUserCancelOrder(order.status)) {
      buttons.add(
        const SizedBox(height: AppSizes.spaceBtwItems),
      );
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _cancelOrder(context, order, controller),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
            child: const Text('Hủy đơn hàng'),
          ),
        ),
      );
    }
    
    if (controller.canUserUpdateOrder(order.status)) {
      buttons.add(
        const SizedBox(height: AppSizes.spaceBtwItems / 2),
      );
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _markAsReceived(context, order, controller),
            child: const Text('Xác nhận đã nhận hàng'),
          ),
        ),
      );
    }
    
    return buttons;
  }

  void _viewOrderDetails(OrderModel order, OrderController controller) {
    // Navigate to order details screen with order ID using Get.to()
    Get.to(() => const OrderDetailsScreen(), arguments: order.id);
  }

  void _cancelOrder(BuildContext context, OrderModel order, OrderController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateExistingOrderStatus(
                orderId: order.id,
                newStatus: 'cancelled',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hủy đơn hàng'),
          ),
        ],
      ),
    );
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
      case 'canceled':
        return Iconsax.close_circle;
      case 'refunded':
        return Iconsax.refresh;
      case 'failed':
        return Iconsax.warning_2;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getStatusColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return AppColors.info;
      case 'purple':
        return AppColors.secondary;
      case 'teal':
        return const Color(0xFF20B2AA);
      case 'red':
        return AppColors.error;
      case 'amber':
        return const Color(0xFFFFC107);
      case 'grey':
      default:
        return Colors.grey;
    }
  }
}