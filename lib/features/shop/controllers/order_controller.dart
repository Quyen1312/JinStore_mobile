// order_controller.dart
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/service/order_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final OrderService _orderService = Get.find<OrderService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Danh sách đơn hàng của người dùng hiện tại hoặc tất cả đơn hàng (cho admin)
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  // Đơn hàng đang được xem chi tiết
  final Rx<OrderModel?> currentOrderDetails = Rx<OrderModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe trạng thái đăng nhập để tải đơn hàng của người dùng
    ever(_authController.isLoggedIn, _handleAuthChangeForOrders);
    if (_authController.isLoggedIn.value) {
      fetchMyOrders();
    }
  }

  void _handleAuthChangeForOrders(bool isLoggedIn) {
    if (isLoggedIn) {
      fetchMyOrders();
    } else {
      orders.clear();
      currentOrderDetails.value = null;
    }
  }

  /// Lấy danh sách đơn hàng của người dùng hiện tại
  Future<void> fetchMyOrders({String? status}) async {
    if (!_authController.isLoggedIn.value) return;
    try {
      isLoading.value = true;
      error.value = '';
      final orderList = await _orderService.getMyOrders(status: status);
      orders.assignAll(orderList);
    } catch (e) {
      print("[OrderController] fetchMyOrders Error: $e");
      error.value = e.toString();
      orders.clear(); // Xóa danh sách nếu có lỗi
      Loaders.errorSnackBar(title: 'Lỗi tải đơn hàng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy chi tiết một đơn hàng
  Future<void> fetchOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      error.value = '';
      currentOrderDetails.value = null; // Reset trước khi fetch
      final orderDetailsData = await _orderService.getOrderDetails(orderId);
      currentOrderDetails.value = orderDetailsData;
    } catch (e) {
      print("[OrderController] fetchOrderDetails Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải chi tiết đơn hàng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Tạo đơn hàng mới
  Future<OrderModel?> processNewOrder({
    required List<OrderItemModel> orderItems,
    required String shippingAddress, // Fixed: match backend field name
    required double shippingFee,
    required String paymentMethod,
    required double totalAmount,
    String? note,
    String? source, // ví dụ: 'cart' để backend biết xóa giỏ hàng
  }) async {
    if (!_authController.isLoggedIn.value) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập để đặt hàng.');
      return null;
    }
    try {
      isLoading.value = true;
      error.value = '';
      final newOrder = await _orderService.createOrder(
        orderItems: orderItems,
        shippingAddress: shippingAddress, // Fixed: correct field name
        shippingFee: shippingFee,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        note: note,
        source: source,
      );
      await fetchMyOrders(); // Tải lại danh sách đơn hàng của người dùng
      Loaders.successSnackBar(title: 'Thành công', message: 'Đơn hàng của bạn đã được tạo.');
      return newOrder;
    } catch (e) {
      print("[OrderController] processNewOrder Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tạo đơn hàng', message: e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật trạng thái đơn hàng (có thể cho cả user và admin tùy theo logic backend)
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

      // Cập nhật đơn hàng trong danh sách local nếu có
      int index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }
      // Cập nhật currentOrderDetails nếu nó là đơn hàng đang được xem
      if (currentOrderDetails.value?.id == orderId) {
        currentOrderDetails.value = updatedOrder;
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Trạng thái đơn hàng đã được cập nhật.');
    } catch (e) {
      print("[OrderController] updateExistingOrderStatus Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi cập nhật trạng thái', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Chức năng cho Admin ---

  /// Admin: Lấy tất cả đơn hàng trong hệ thống
  Future<void> fetchAllOrdersAdmin({String? status}) async {
    try {
      isLoading.value = true;
      error.value = '';
      final orderList = await _orderService.getAllOrdersAdmin(status: status);
      orders.assignAll(orderList); // Gán vào list chính để hiển thị trên màn hình admin
    } catch (e) {
      print("[OrderController] fetchAllOrdersAdmin Error: $e");
      error.value = e.toString();
      orders.clear();
      Loaders.errorSnackBar(title: 'Lỗi tải tất cả đơn hàng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Lấy các đơn hàng của một người dùng cụ thể
  Future<List<OrderModel>> fetchOrdersByUserIdAdmin(String userId, {String? status}) async {
    try {
      isLoading.value = true;
      error.value = '';
      final orderList = await _orderService.getOrdersByUserIdAdmin(userId, status: status);
      // Không gán vào orders của controller này vì đây là của user khác, trả về để UI xử lý
      return orderList;
    } catch (e) {
      print("[OrderController] fetchOrdersByUserIdAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải đơn hàng người dùng', message: e.toString());
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Xóa một đơn hàng
  Future<void> deleteOrderAsAdmin(String orderId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _orderService.deleteOrderAdmin(orderId);
      orders.removeWhere((order) => order.id == orderId); // Xóa khỏi danh sách local
      if (currentOrderDetails.value?.id == orderId) {
        currentOrderDetails.value = null; // Xóa nếu đang xem chi tiết
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Đơn hàng đã được xóa.');
    } catch (e) {
      print("[OrderController] deleteOrderAsAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi xóa đơn hàng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper Methods - UPDATED with complete status mapping ---

  /// Convert backend status to user-friendly Vietnamese text
  String getOrderStatusText(String? status) {
    if (status == null) return 'Không xác định';
    
    // Handle case-insensitive comparison and various formats from backend
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'paid':
        return 'Đã thanh toán'; // ✅ ADDED: Backend sets this for VNPay success
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'received':
        return 'Đã nhận hàng';
      case 'cancelled':
      case 'canceled': // Handle both spellings
        return 'Đã hủy';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'failed':
        return 'Thất bại';
      default:
        // Return formatted version of unknown status
        return status.split('').map((char) => 
          char == status[0] ? char.toUpperCase() : char.toLowerCase()
        ).join('');
    }
  }

  /// Get status color for UI display
  String getOrderStatusColor(String? status) {
    if (status == null) return 'grey';
    
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
      case 'canceled':
        return 'red';
      case 'refunded':
        return 'amber';
      case 'failed':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Check if user can cancel this order
  bool canUserCancelOrder(String? status) {
    if (status == null) return false;
    
    // User can cancel orders that haven't been processed yet
    final cancelableStatuses = ['pending'];
    return cancelableStatuses.contains(status.toLowerCase().trim());
  }

  /// Check if order can be updated by user (for status updates)
  bool canUserUpdateOrder(String? status) {
    if (status == null) return false;
    
    // User can update certain statuses (e.g., mark as received)
    final updatableStatuses = ['delivered']; // User can mark delivered orders as received
    return updatableStatuses.contains(status.toLowerCase().trim());
  }

  /// Get next possible status transitions for admins
  List<String> getNextPossibleStatuses(String? currentStatus) {
    if (currentStatus == null) return [];
    
    switch (currentStatus.toLowerCase().trim()) {
      case 'pending':
        return ['paid', 'processing', 'cancelled'];
      case 'paid':
        return ['processing', 'cancelled', 'refunded'];
      case 'processing':
        return ['shipping', 'cancelled'];
      case 'shipping':
        return ['delivered', 'cancelled'];
      case 'delivered':
        return ['received', 'refunded'];
      case 'received':
        return ['refunded']; // Only refund possible after received
      default:
        return []; // Terminal states: cancelled, refunded, failed
    }
  }

  /// Check if status is terminal (no further updates possible)
  bool isTerminalStatus(String? status) {
    if (status == null) return false;
    
    final terminalStatuses = ['received', 'cancelled', 'canceled', 'refunded', 'failed'];
    return terminalStatuses.contains(status.toLowerCase().trim());
  }

  /// Filter orders by status locally (for UI performance)
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => 
      order.status.toLowerCase().trim() == status.toLowerCase().trim()
    ).toList();
  }

  /// Get order counts by status for dashboard
  Map<String, int> getOrderStatusCounts() {
    final counts = <String, int>{};
    for (final order in orders) {
      final status = order.status.toLowerCase().trim();
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }
}