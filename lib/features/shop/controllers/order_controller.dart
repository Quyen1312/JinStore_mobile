import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/service/order_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final OrderService _orderService = Get.find<OrderService>();

  // Observable variables
  var isLoading = false.obs;
  var error = ''.obs;
  var orders = <OrderModel>[].obs;
  var currentOrderDetails = Rxn<OrderModel>();

  // ✅ CONSTANTS for free shipping logic
  static const double freeShippingThreshold = 500000.0; // 500k VND
  static const double standardShippingFee = 30000.0; // 30k VND

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
  }

  /// ✅ NEW: Calculate shipping fee with free shipping logic
  double calculateShippingFee(double subtotal) {
    return subtotal >= freeShippingThreshold ? 0.0 : standardShippingFee;
  }

  /// ✅ NEW: Check if order qualifies for free shipping
  bool isEligibleForFreeShipping(double subtotal) {
    return subtotal >= freeShippingThreshold;
  }

  /// ✅ NEW: Get amount needed for free shipping
  double getAmountNeededForFreeShipping(double subtotal) {
    return subtotal >= freeShippingThreshold ? 0.0 : (freeShippingThreshold - subtotal);
  }

  /// ✅ NEW: Process new order creation
  Future<OrderModel?> processNewOrder({
    required List<OrderItemModel> orderItems,
    required String shippingAddress,
    required double shippingFee,
    required String paymentMethod,
    required double totalAmount,
    String? note,
    String? source,
    String? discount,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final order = await _orderService.createOrder(
        orderItems: orderItems,
        shippingAddress: shippingAddress,
        shippingFee: shippingFee,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        note: note,
        source: source,
        discount: discount,
      );

      // Add to local orders list
      orders.insert(0, order);

      print('[OrderController] ✅ Created new order: ${order.id}');
      return order;
    } catch (e) {
      error.value = e.toString();
      print('[OrderController] ❌ Error creating order: $e');
      throw e; // Re-throw để checkout có thể handle
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user's orders
  Future<void> fetchMyOrders({String? status}) async {
    try {
      isLoading.value = true;
      error.value = '';
      orders.clear();

      final orderList = await _orderService.getMyOrders(status: status);
      orders.assignAll(orderList);

      print('[OrderController] ✅ Loaded ${orderList.length} orders');
    } catch (e) {
      error.value = e.toString();
      print('[OrderController] ❌ Error fetching orders: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể tải danh sách đơn hàng: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch order details
  Future<void> fetchOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      error.value = '';
      currentOrderDetails.value = null;

      final order = await _orderService.getOrderDetails(orderId);
      currentOrderDetails.value = order;

      print('[OrderController] ✅ Loaded order details: ${order.id}');
    } catch (e) {
      error.value = e.toString();
      print('[OrderController] ❌ Error fetching order details: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể tải chi tiết đơn hàng: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update order status
  Future<void> updateExistingOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedOrder = await _orderService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );

      // Update local data
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = updatedOrder;
      }

      // Update current order details if viewing
      if (currentOrderDetails.value?.id == orderId) {
        currentOrderDetails.value = updatedOrder;
      }

      Loaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã cập nhật trạng thái đơn hàng',
      );

      print('[OrderController] ✅ Updated order status: $orderId -> $newStatus');
    } catch (e) {
      error.value = e.toString();
      print('[OrderController] ❌ Error updating order status: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể cập nhật trạng thái đơn hàng: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ SIMPLIFIED METHODS - Match với backend logic

  /// Get order status text - match với backend enum
  String getOrderStatusText(String status) {
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

  /// Get order status color - match với backend enum
  String getOrderStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 'orange';
      case 'paid':
        return 'green';
      case 'processing':
        return 'blue';
      case 'shipping':
        return 'purple';
      case 'delivered':
        return 'teal';
      case 'received':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Get payment status text - chỉ dựa vào isPaid và status
  String getPaymentStatusText(OrderModel order) {
    if (order.paymentMethod.toLowerCase() == 'vnpay') {
      return order.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán';
    } else {
      // COD: chỉ "đã thanh toán" khi status = 'received'
      return order.status.toLowerCase() == 'received' 
          ? 'Đã thanh toán COD' 
          : 'Thanh toán khi nhận hàng';
    }
  }

  /// Get payment status color - chỉ dựa vào isPaid và status
  String getPaymentStatusColor(OrderModel order) {
    if (order.paymentMethod.toLowerCase() == 'vnpay') {
      return order.isPaid ? 'green' : 'red';
    } else {
      // COD: chỉ "green" khi status = 'received'
      return order.status.toLowerCase() == 'received' ? 'green' : 'orange';
    }
  }

  /// Check if order is paid - chỉ dựa vào isPaid từ backend
  bool isOrderPaid(OrderModel order) {
    return order.isPaid;
  }

  /// Check if user can cancel order - chỉ dựa vào status
  bool canUserCancelOrder(String status) {
    final cancelableStatuses = ['pending', 'paid', 'processing'];
    return cancelableStatuses.contains(status.toLowerCase().trim());
  }

  /// Check if user can update order - chỉ cho phép 'delivered' -> 'received'
  bool canUserUpdateOrder(String status) {
    return status.toLowerCase().trim() == 'delivered';
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchMyOrders();
  }

  /// Clear error
  void clearError() {
    error.value = '';
  }
}