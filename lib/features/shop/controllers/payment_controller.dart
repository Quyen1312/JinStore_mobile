import 'package:flutter_application_jin/service/payment_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find();

  final PaymentService _paymentService = Get.find<PaymentService>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // Payment state tracking
  final RxString currentOrderId = ''.obs;
  final RxString currentPaymentUrl = ''.obs;
  final RxBool paymentInProgress = false.obs;

  /// Create VNPay payment URL with improved error handling
  Future<String?> initiateVNPayPayment({
    required String orderId,
    String? bankCode,
    String? language = 'vn',
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        isLoading.value = true;
        error.value = '';
        paymentInProgress.value = true;
        currentOrderId.value = orderId;
        
        print("PaymentController: Attempting VNPay payment creation (attempt $attempts/$maxRetries)");
        print("OrderID: $orderId, BankCode: $bankCode, Language: $language");
        
        final paymentUrl = await _paymentService.createVNPayPaymentUrl(
          orderId: orderId,
          bankCode: bankCode,
          language: language,
        );
        
        if (paymentUrl.isNotEmpty) {
          currentPaymentUrl.value = paymentUrl;
          print("PaymentController: VNPay URL created successfully");
          
          // Reset retry count on success
          attempts = maxRetries;
          return paymentUrl;
        } else {
          throw Exception('Empty payment URL received');
        }
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        error.value = e.toString();
        print('PaymentController Error (attempt $attempts): $e');
        
        if (attempts < maxRetries) {
          // Wait before retry with exponential backoff
          final delaySeconds = attempts * 2;
          print('PaymentController: Retrying in $delaySeconds seconds...');
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      } finally {
        isLoading.value = false;
      }
    }

    // All retries exhausted
    paymentInProgress.value = false;
    currentOrderId.value = '';
    currentPaymentUrl.value = '';
    
    // Show user-friendly error message
    _handlePaymentError(lastException);
    return null;
  }

  /// Handle different types of payment errors
  void _handlePaymentError(Exception? error) {
    String userMessage;
    String title = 'Lỗi thanh toán';
    
    if (error == null) {
      userMessage = 'Có lỗi không xác định khi tạo thanh toán';
    } else {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('network') || errorString.contains('connection')) {
        title = 'Lỗi kết nối';
        userMessage = 'Không thể kết nối đến cổng thanh toán. Kiểm tra kết nối mạng và thử lại.';
      } else if (errorString.contains('timeout')) {
        title = 'Hết thời gian chờ';
        userMessage = 'Kết nối đến cổng thanh toán quá chậm. Vui lòng thử lại.';
      } else if (errorString.contains('server') || errorString.contains('500')) {
        title = 'Lỗi server';
        userMessage = 'Cổng thanh toán đang gặp sự cố. Vui lòng thử lại sau vài phút.';
      } else if (errorString.contains('unauthorized') || errorString.contains('401')) {
        title = 'Lỗi xác thực';
        userMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      } else if (errorString.contains('order')) {
        title = 'Lỗi đơn hàng';
        userMessage = 'Không tìm thấy thông tin đơn hàng. Vui lòng thử tạo đơn hàng mới.';
      } else if (errorString.contains('empty')) {
        title = 'Lỗi hệ thống';
        userMessage = 'Cổng thanh toán trả về thông tin không hợp lệ. Vui lòng thử lại.';
      } else {
        userMessage = 'Không thể tạo liên kết thanh toán. Vui lòng thử phương thức thanh toán khác hoặc liên hệ hỗ trợ.';
      }
    }
    
    Loaders.errorSnackBar(
      title: title,
      message: userMessage,
    );
  }

  /// Reset payment state (call when user cancels or completes payment)
  void resetPaymentState() {
    paymentInProgress.value = false;
    currentOrderId.value = '';
    currentPaymentUrl.value = '';
    error.value = '';
    isLoading.value = false;
  }

  /// Check if payment is currently in progress for an order
  bool isPaymentInProgressForOrder(String orderId) {
    return paymentInProgress.value && currentOrderId.value == orderId;
  }

  /// Validate payment prerequisites
  Future<bool> validatePaymentPrerequisites(String orderId) async {
    try {
      // Check if order ID is valid
      if (orderId.isEmpty) {
        throw Exception('Order ID is empty');
      }
      
      // Check if another payment is in progress
      if (paymentInProgress.value && currentOrderId.value != orderId) {
        throw Exception('Another payment is in progress');
      }
      
      // Additional validations can be added here
      // e.g., check order status, user authentication, etc.
      
      return true;
    } catch (e) {
      error.value = e.toString();
      Loaders.errorSnackBar(
        title: 'Lỗi xác thực',
        message: e.toString(),
      );
      return false;
    }
  }

  /// Alternative payment methods fallback
  List<Map<String, dynamic>> getAlternativePaymentMethods() {
    return [
      {
        'code': 'cod',
        'name': 'Thanh toán khi nhận hàng',
        'description': 'Thanh toán bằng tiền mặt khi nhận hàng',
        'isAvailable': true,
      },
      {
        'code': 'bank_transfer',
        'name': 'Chuyển khoản ngân hàng',
        'description': 'Chuyển khoản qua thông tin tài khoản',
        'isAvailable': true,
      },
    ];
  }

  /// Get payment method display name
  String getPaymentMethodName(String code) {
    switch (code.toLowerCase()) {
      case 'vnpay':
        return 'VNPay';
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      default:
        return code.toUpperCase();
    }
  }

  /// Format payment amount for display
  String formatPaymentAmount(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}đ';
  }

  /// Payment method availability check
  bool isPaymentMethodAvailable(String method) {
    switch (method.toLowerCase()) {
      case 'vnpay':
        return true; // Always available if service is working
      case 'cod':
        return true; // Always available
      case 'bank_transfer':
        return true; // Always available
      default:
        return false;
    }
  }

  @override
  void onClose() {
    resetPaymentState();
    super.onClose();
  }
}