import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user_controller.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/order_controller.dart'; // ✅ ADD: Missing import
import 'package:flutter_application_jin/features/shop/controllers/payment_controller.dart'; // ✅ ADD: Missing import
import 'package:flutter_application_jin/service/address_service.dart';
import 'package:flutter_application_jin/service/auth_service.dart';
import 'package:flutter_application_jin/service/category_service.dart';
import 'package:flutter_application_jin/service/discount_service.dart';
import 'package:flutter_application_jin/service/payment_service.dart';
import 'package:get/get.dart';
import '../cart_service.dart';
import '../user_service.dart';
import '../order_service.dart';
import '../review_service.dart';
import '../product_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    print('🚀 Initializing dependencies...');
    
    try {
      // 1. Initialize AuthService first
      print('🔧 Initializing AuthService...');
      Get.put<AuthService>(AuthService(), permanent: true);

      // 2. Initialize AuthController
      print('🎮 Initializing AuthController...');
      Get.put<AuthController>(AuthController(), permanent: true);
      
      // ✅ REMOVED: Don't call checkLoginStatus here to avoid race condition
      // Let SplashController handle the login check
      
      // 3. Initialize all services
      print('⚙️ Initializing services...');
      await _initializeServices();

      // 4. Initialize controllers
      print('🎛️ Initializing controllers...');
      _initializeControllers();
      
      print('✅ All dependencies initialized successfully');
      
    } catch (e) {
      print('❌ Error initializing dependencies: $e');
      rethrow;
    }
  }

  /// Initialize all services
  static Future<void> _initializeServices() async {
    // Get current token from AuthService
    final authService = Get.find<AuthService>();
    final token = await authService.getAccessToken();
    
    // Services using GetConnect with interceptors
    Get.put<AddressService>(AddressService(), permanent: true);
    Get.put<CartService>(CartService(), permanent: true);
    Get.put<DiscountService>(DiscountService(), permanent: true);
    Get.put<OrderService>(OrderService(), permanent: true);
    Get.put<PaymentService>(PaymentService(), permanent: true);
    Get.put<ReviewService>(ReviewService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);
    
    // Legacy services with token parameter
    Get.lazyPut<ProductService>(() => ProductService(token: token), fenix: true);
    Get.lazyPut<CategoryService>(() => CategoryService(token: token ?? ''), fenix: true);
  }

  /// Initialize controllers
  static void _initializeControllers() {
    // Core controllers
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<AddressController>(AddressController(), permanent: true);
    
    // ✅ ADD: Missing shop controllers
    Get.put<OrderController>(OrderController(), permanent: true);
    Get.put<PaymentController>(PaymentController(), permanent: true);
  }

  /// Update token for legacy services
  static Future<void> updateToken() async {
    final authService = Get.find<AuthService>();
    final token = await authService.getAccessToken();
    
    // Update legacy services
    if (Get.isRegistered<ProductService>()) {
      Get.find<ProductService>().updateToken(token);
    }
    if (Get.isRegistered<CategoryService>()) {
      Get.put<CategoryController>(
        CategoryController(categoryService: Get.find<CategoryService>()), 
        permanent: true
      );
      print('✅ CategoryController initialized with existing CategoryService');
    } else {
      print('⚠️ CategoryService not found, CategoryController will be initialized later');
    }
  }
    
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final authService = Get.find<AuthService>();
    return await authService.isLoggedIn();
  }

  /// Get current access token
  static Future<String?> getToken() async {
    final authService = Get.find<AuthService>();
    return await authService.getAccessToken();
  }

  /// Clean up all dependencies
  static void reset() {
    // Delete controllers first
    Get.delete<PaymentController>(force: true); // ✅ ADD: Missing cleanup
    Get.delete<OrderController>(force: true); // ✅ ADD: Missing cleanup
    Get.delete<AddressController>(force: true);
    Get.delete<UserController>(force: true);
    Get.delete<CartController>(force: true);
    Get.delete<AuthController>(force: true);
    Get.delete<CategoryController>(force: true);
    
    // Delete services
    Get.delete<ReviewService>(force: true);
    Get.delete<PaymentService>(force: true);
    Get.delete<OrderService>(force: true);
    Get.delete<DiscountService>(force: true);
    Get.delete<CartService>(force: true);
    Get.delete<AddressService>(force: true);
    Get.delete<UserService>(force: true);
    Get.delete<ProductService>(force: true);
    Get.delete<CategoryService>(force: true);
    Get.delete<AuthService>(force: true);
  }
}