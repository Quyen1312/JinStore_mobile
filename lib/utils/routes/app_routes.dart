import 'package:get/get.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/checkout.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/payment_success_screen.dart';

class AppRoutes {
  static final pages = [
    GetPage(
      name: '/checkout',
      page: () => const CheckoutScreen(),
    ),
    GetPage(
      name: '/payment-success',
      page: () => const PaymentSuccessScreen(),
    ),
  ];
} 