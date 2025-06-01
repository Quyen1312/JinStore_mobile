import 'package:flutter_application_jin/service/address/address_service.dart';
import 'package:flutter_application_jin/service/auth/auth_service.dart';
import 'package:flutter_application_jin/service/category/category_service.dart';
import 'package:flutter_application_jin/service/discount/discount_service.dart';
import 'package:flutter_application_jin/service/payment/payment_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart/cart_service.dart';
import 'user/user_service.dart';
import 'order/order_service.dart';
import 'review/review_service.dart';
import 'product/product_service.dart';

class DependencyInjection {
  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';

  static Future<void> init() async {
    // Core dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.lazyPut(() => sharedPreferences, fenix: true);

    // Get stored tokens
    final token = sharedPreferences.getString(tokenKey);
    final refreshToken = sharedPreferences.getString(refreshTokenKey);

    // Initialize Auth Service first
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);

    // Initialize other services with token
    Get.lazyPut<ProductService>(() => ProductService(token: token), fenix: true);
    Get.lazyPut<CartService>(() => CartService(token: token ?? ''), fenix: true);
    Get.lazyPut<UserService>(() => UserService(token: token ?? ''), fenix: true);
    Get.lazyPut<OrderService>(() => OrderService(token: token ?? ''), fenix: true);
    Get.lazyPut<ReviewService>(() => ReviewService(token: token ?? ''), fenix: true);
    Get.lazyPut<CategoryService>(() => CategoryService(token: token ?? ''), fenix: true);
    Get.lazyPut<DiscountService>(() => DiscountService(token: token ?? ''), fenix: true);
    Get.lazyPut<PaymentService>(() => PaymentService(token: token ?? ''), fenix: true);
    Get.lazyPut<AddressService>(() => AddressService(token: token ?? ''), fenix: true);
  }

  static void reset() {
    // Delete all service instances
    Get.delete<ProductService>(force: true);
    Get.delete<CartService>(force: true);
    Get.delete<UserService>(force: true);
    Get.delete<OrderService>(force: true);
    Get.delete<ReviewService>(force: true);
    Get.delete<CategoryService>(force: true);
    Get.delete<DiscountService>(force: true);
    Get.delete<PaymentService>(force: true);
    Get.delete<AddressService>(force: true);
    Get.delete<AuthService>(force: true);
  }

  static void updateToken(String? token) async {
    // Save token to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(tokenKey, token);
    } else {
      await prefs.remove(tokenKey);
    }

    // Update all services with new token
    Get.find<ProductService>().updateToken(token);
    Get.find<CartService>().updateToken(token ?? '');
    Get.find<UserService>().updateToken(token ?? '');
    Get.find<OrderService>().updateToken(token ?? '');
    Get.find<ReviewService>().updateToken(token ?? '');
    Get.find<CategoryService>().updateToken(token ?? '');
    Get.find<DiscountService>().updateToken(token ?? '');
    Get.find<PaymentService>().updateToken(token ?? '');
    Get.find<AddressService>().updateToken(token ?? '');
  }

  // Helper method to check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // Helper method to get current token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
} 