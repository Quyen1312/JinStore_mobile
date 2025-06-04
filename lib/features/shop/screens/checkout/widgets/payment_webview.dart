import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  
  // URL patterns for success/failure detection
  static const String successPattern = '/payments/vnpay/return_url';
  static const String cancelPattern = '/payments/vnpay/return_url';

  @override
  void initState() {
    super.initState();
    
    // Nếu là web platform, sử dụng url_launcher thay vì WebView
    if (kIsWeb) {
      _handleWebPlatform();
    } else {
      _initializeWebView();
    }
  }

  // Xử lý cho web platform
  void _handleWebPlatform() async {
    // Hiển thị dialog hướng dẫn cho user
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Thanh toán VNPay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn sẽ được chuyển đến trang thanh toán VNPay.'),
            const SizedBox(height: 16),
            const Text('Sau khi thanh toán xong, vui lòng quay lại ứng dụng.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(widget.paymentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                Get.back(result: null); // Đóng dialog
              },
              child: const Text('Mở trang thanh toán'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đã thanh toán xong'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    
    // Trả về kết quả
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  // Khởi tạo WebView cho mobile platforms
  void _initializeWebView() {
    _controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(),
    );

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            
            // Check for success/failure patterns
            if (url.contains(successPattern)) {
              _handlePaymentResult(url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentResult(String url) {
    try {
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      final transactionStatus = uri.queryParameters['vnp_TransactionStatus'];
      final amount = uri.queryParameters['vnp_Amount'];
      final transactionNo = uri.queryParameters['vnp_TransactionNo'];
      
      // VNPay success codes: 00
      bool isSuccess = responseCode == '00' && transactionStatus == '00';
      
      // Prepare result data
      Map<String, dynamic> resultData = {
        'orderId': widget.orderId,
        'responseCode': responseCode,
        'transactionStatus': transactionStatus,
        'transactionId': transactionNo,
        'amount': amount != null ? double.tryParse(amount) : null,
      };
      
      if (isSuccess) {
        // Success
        Get.offAllNamed('/payment-success', arguments: resultData);
      } else {
        // Failure
        resultData['errorMessage'] = _getErrorMessage(responseCode ?? '');
        resultData['errorCode'] = responseCode;
        Get.offAllNamed('/payment-failure', arguments: resultData);
      }
      
    } catch (e) {
      // Error parsing URL
      Get.offAllNamed('/payment-failure', arguments: {
        'orderId': widget.orderId,
        'errorMessage': 'Có lỗi xảy ra khi xử lý kết quả thanh toán',
        'errorCode': 'URL_PARSE_ERROR',
      });
    }
  }

  String _getErrorMessage(String responseCode) {
    switch (responseCode) {
      case '07':
        return 'Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).';
      case '09':
        return 'Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.';
      case '10':
        return 'Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần';
      case '11':
        return 'Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.';
      case '12':
        return 'Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa.';
      case '13':
        return 'Giao dịch không thành công do Quý khách nhập sai mật khẩu xác thực giao dịch (OTP).';
      case '24':
        return 'Giao dịch không thành công do: Khách hàng hủy giao dịch';
      case '51':
        return 'Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.';
      case '65':
        return 'Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.';
      case '75':
        return 'Ngân hàng thanh toán đang bảo trì.';
      case '79':
        return 'Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định.';
      default:
        return 'Giao dịch không thành công. Vui lòng thử lại sau.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu là web, không hiển thị gì (đã xử lý trong initState)
    if (kIsWeb) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mobile WebView
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false),
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}