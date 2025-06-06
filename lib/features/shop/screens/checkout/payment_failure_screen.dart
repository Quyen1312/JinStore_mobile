// File: lib/features/shop/screens/checkout/payment_failure_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from WebView
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final orderId = arguments['orderId'] as String?;
    final errorMessage = arguments['errorMessage'] as String?;
    final errorCode = arguments['errorCode'] as String?;
    final amount = arguments['amount'] as double?;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              const Spacer(),
              
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_outlined,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              
              const SizedBox(height: AppSizes.spaceBtwSections),
              
              // Error Title
              Text(
                'Thanh toán thất bại',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.spaceBtwItems),
              
              // Error Message
              Text(
                errorMessage ?? 'Có lỗi xảy ra trong quá trình thanh toán.\nVui lòng thử lại.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.spaceBtwSections),
              
              // Error Details Card
              if (orderId != null || errorCode != null || amount != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết lỗi',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),
                      
                      if (orderId != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mã đơn hàng:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                      ],
                      
                      if (amount != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Số tiền:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${amount.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                (match) => '.',
                              )}đ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                      ],
                      
                      if (errorCode != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mã lỗi:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              errorCode,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                      ],
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thời gian:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            DateTime.now().toString().substring(0, 19),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: AppSizes.spaceBtwSections),
              
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: Text(
                            'Đơn hàng của bạn đã được lưu',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text(
                      'Bạn có thể xem đơn hàng trong danh sách và thực hiện thanh toán lại sau.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              Column(
                children: [
                  // Try Again Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Go back to orders to retry payment
                        Get.offAllNamed('/my-orders');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Xem đơn hàng & Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  
                  // Alternative Payment Methods
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Go to checkout with COD option
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Phương thức thanh toán khác'),
                            content: const Text('Bạn có thể sử dụng phương thức "Thanh toán khi nhận hàng" hoặc chuyển khoản ngân hàng.'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Đóng'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  Get.offAllNamed('/my-orders');
                                },
                                child: const Text('Xem đơn hàng'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Thử phương thức khác'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  
                  // Contact Support
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Liên hệ hỗ trợ'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nếu bạn cần hỗ trợ, vui lòng liên hệ:'),
                                SizedBox(height: 8),
                                Text('📞 Hotline: 1900-xxxx'),
                                Text('📧 Email: support@app.com'),
                                Text('💬 Chat: Trong app'),
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
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Liên hệ hỗ trợ'),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  
                  // Continue Shopping Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Get.offAllNamed('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('Về trang chủ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}