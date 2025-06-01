import 'package:get/get.dart';
import 'package:flutter_application_jin/service/order/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList orders = [].obs;
  final RxMap currentOrder = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders({String? status}) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final orderList = await _orderService.getUserOrders(status: status);
      orders.value = orderList;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final orderDetails = await _orderService.getOrderDetails(orderId);
      currentOrder.value = orderDetails;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final order = await _orderService.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      
      // Refresh orders list after creating new order
      await fetchUserOrders();
      
      return order;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final updatedOrder = await _orderService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      
      // Update current order if it matches the updated order
      if (currentOrder.value['id'] == orderId) {
        currentOrder.value = updatedOrder;
      }
      
      // Refresh orders list
      await fetchUserOrders();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get order status text
  String getOrderStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  // Helper method to check if order can be cancelled
  bool canCancelOrder(String status) {
    return ['pending', 'confirmed'].contains(status.toLowerCase());
  }
} 