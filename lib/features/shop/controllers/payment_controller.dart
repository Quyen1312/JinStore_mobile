import 'package:get/get.dart';
import 'package:flutter_application_jin/service/payment/payment_service.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = Get.find<PaymentService>();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList payments = [].obs;
  final RxMap currentPayment = {}.obs;

  Future<String> createVNPayUrl({
    required String orderId,
    required double amount,
    String? bankCode,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _paymentService.createVNPayUrl(
        orderId: orderId,
        amount: amount,
        bankCode: bankCode,
      );
      
      return response['paymentUrl'] as String;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyVNPayReturn(Map<String, String> vnpParams) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _paymentService.verifyVNPayReturn(vnpParams);
      currentPayment.value = response;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentsByOrder(String orderId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final paymentList = await _paymentService.getPaymentsByOrder(orderId);
      payments.value = paymentList;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserPayments() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final paymentList = await _paymentService.getUserPayments();
      payments.value = paymentList;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> createRefund({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final refund = await _paymentService.createRefund(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );
      
      // Refresh payments list after creating refund
      await fetchUserPayments();
      
      return refund;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkRefundStatus(String refundId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final refundStatus = await _paymentService.getRefundStatus(refundId);
      currentPayment.value = refundStatus;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get payment status text
  String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'completed':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'partially_refunded':
        return 'Hoàn tiền một phần';
      default:
        return 'Không xác định';
    }
  }

  // Helper method to check if payment can be refunded
  bool canRefund(String status) {
    return ['completed'].contains(status.toLowerCase());
  }
} 