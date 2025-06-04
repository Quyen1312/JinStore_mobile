// payment_service.dart
import 'dart:convert';
import 'package:flutter_application_jin/service/base_service.dart';

class PaymentService extends BaseService {
  @override
  String get serviceName => 'PaymentService';

  /// Tạo URL thanh toán VNPay
  /// Backend: POST /payments/vnpay/create_url
  Future<String> createVNPayPaymentUrl({
    required String orderId,
    String? bankCode,
    String? language,
  }) async {
    try {
      await ensureAuthenticated();
      
      final Map<String, dynamic> body = {
        'orderId': orderId,
      };
      if (bankCode != null && bankCode.isNotEmpty) {
        body['bankCode'] = bankCode;
      }
      if (language != null && language.isNotEmpty) {
        body['language'] = language;
      }
      
      print("$serviceName createVNPayPaymentUrl Body: ${jsonEncode(body)}");
      final response = await post('/payments/vnpay/create_url', body);

      // Handle VNPay specific response format
      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final responseData = response.body as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['paymentUrl'] is String) {
          return responseData['paymentUrl'] as String;
        } else {
          final error = responseData['error'] ?? responseData['message'] ?? 'Không thể tạo URL thanh toán';
          throw error;
        }
      } else {
        throw 'Lỗi server khi tạo URL thanh toán';
      }
    } catch (e) {
      print('Lỗi trong $serviceName.createVNPayPaymentUrl: $e');
      throw e is String ? e : 'Lỗi khi tạo URL thanh toán: ${e.toString()}';
    }
  }

  // ⚠️ REMOVED: Các methods sau KHÔNG có endpoint tương ứng trong backend routes:
  // - getPaymentStatus() - NO ROUTE: GET /payments/status/:orderId
  // - confirmCODPayment() - NO ROUTE: POST /payments/confirm-cod  
  // - getAvailablePaymentMethods() - NO ROUTE: GET /payments/methods
  // - cancelPayment() - NO ROUTE: POST /payments/cancel

  // Chỉ giữ lại methods có route thật sự trong backend
}