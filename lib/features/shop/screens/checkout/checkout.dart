import 'package:flutter/material.dart';
import 'package:flutter_application_jin/bottom_navigation_bar.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/coupon_widget.dart';
import 'package:flutter_application_jin/common/widgets/success_screen/success_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'widgets/billing_payment_section.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/payment_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/payment_webview.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final paymentController = Get.find<PaymentController>();
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              // Cart Items
              const CartItems(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Coupon Section
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã giảm giá',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          prefixIcon: Icon(Iconsax.discount_shape),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle coupon application
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(AppSizes.md),
                        ),
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Order Summary
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Column(
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng đơn hàng',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Obx(() => Text(
                          '${cartController.total.value.toStringAsFixed(0)}đ',
                          style: Theme.of(context).textTheme.titleMedium,
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Shipping Fee
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí vận chuyển'),
                        Text('30,000đ'),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Discount if any
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Giảm giá'),
                        Text('0đ'),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    const Divider(),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng thanh toán',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Obx(() => Text(
                          '${(cartController.total.value + 30000).toStringAsFixed(0)}đ',
                          style: Theme.of(context).textTheme.titleLarge,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Payment Methods
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Column(
                  children: [
                    Text(
                      'Phương thức thanh toán',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    
                    // VNPay Option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 45,
                        height: 30,
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.asset(
                          'assets/images/vnpay.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: const Text('Thanh toán VNPay'),
                      trailing: Icon(Iconsax.arrow_right_3),
                      onTap: () async {
                        try {
                          final orderId = DateTime.now().millisecondsSinceEpoch.toString();
                          final amount = cartController.total.value + 30000;
                          
                          // Create VNPay payment URL
                          final paymentUrl = await paymentController.createVNPayUrl(
                            orderId: orderId,
                            amount: amount,
                          );
                          
                          // Navigate to WebView
                          final result = await Get.to(() => PaymentWebView(
                            paymentUrl: paymentUrl,
                            orderId: orderId,
                          ));
                          
                          if (result == true) {
                            // Payment successful
                            Get.snackbar(
                              'Thành công',
                              'Thanh toán thành công',
                              snackPosition: SnackPosition.TOP,
                            );
                            // Clear cart and navigate to success screen
                            await cartController.clearCart();
                            Get.offAllNamed('/payment-success');
                          }
                        } catch (e) {
                          Get.snackbar(
                            'Lỗi',
                            'Không thể tạo đơn hàng. Vui lòng thử lại sau.',
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                    ),
                    
                    // COD Option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 45,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                        ),
                        child: const Icon(Iconsax.money),
                      ),
                      title: const Text('Thanh toán khi nhận hàng'),
                      trailing: Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Handle COD payment
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Xác nhận đặt hàng'),
                            content: const Text('Bạn có chắc chắn muốn đặt hàng và thanh toán khi nhận hàng?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                  // Process COD order
                                  try {
                                    // Clear cart and navigate to success screen
                                    await cartController.clearCart();
                                    Get.offAllNamed('/payment-success');
                                  } catch (e) {
                                    Get.snackbar(
                                      'Lỗi',
                                      'Không thể tạo đơn hàng. Vui lòng thử lại sau.',
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  }
                                },
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
