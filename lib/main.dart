import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/features/authentication/screens/splash/splash_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/all_products/all_products.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/cart.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/payment_failure_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/payment_success_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/discount/discount.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/product_detail.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_review_section.dart';
import 'package:flutter_application_jin/features/shop/screens/search/search_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/checkout.dart';
import 'package:flutter_application_jin/features/shop/screens/order/order.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/address.dart';
import 'package:flutter_application_jin/features/personalization/screens/profile/profile.dart';
import 'package:flutter_application_jin/features/personalization/screens/settings/settings.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/navigation_menu.dart';
import 'package:flutter_application_jin/service/dependencies/dependencies.dart';
import 'package:flutter_application_jin/service/google_signin_service.dart';
import 'package:flutter_application_jin/utils/theme/theme.dart';
import 'package:get/get.dart';

// WebView platform imports
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

/// Main function - entry point of the application
Future<void> main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 [Main] Starting JinStore application...');
  
  // Initialize WebView platform for web
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
    print('🌐 [Main] WebView platform initialized for web');
  }
  
  // ✅ Initialize Google Sign-In Service
  try {
    GoogleSignInService.instance.initialize();
    if (kIsWeb) {
      print('🌐 [Main] Google Sign-In disabled for web development');
    } else {
      print('📱 [Main] Google Sign-In initialized for mobile platform');
    }
  } catch (e) {
    print('⚠️ [Main] Google Sign-In initialization warning: $e');
    // Continue app initialization even if Google Sign-In fails
  }
  
  // Initialize dependencies
  try {
    await DependencyInjection.init();
    print('✅ [Main] Dependencies initialized successfully');
  } catch (e) {
    print('❌ [Main] Dependencies initialization failed: $e');
    // You might want to show error dialog or handle this gracefully
  }
  
  print('🎯 [Main] Launching app...');
  
  // Run the app
  runApp(const App());
}

/// Main App Widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JinStore',
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      
      // ✅ Add error handling for routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Page not found'),
                SizedBox(height: 16),
                Text('Please check the URL or go back to home.'),
              ],
            ),
          ),
        ),
      ),
      
      // Routes
      initialRoute: '/',
      getPages: [
        // Splash & Authentication
        GetPage(
          name: '/',
          page: () => SplashScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnBoardingScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/signup',
          page: () => const SignupScreen(),
          transition: Transition.rightToLeft,
        ),
        
        // Main Navigation
        GetPage(
          name: '/home',
          page: () => const NavigationMenu(),
          transition: Transition.fadeIn,
        ),
        
        // Shop Features
        GetPage(
          name: '/cart',
          page: () => const CartScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/all-products',
          page: () => AllProductScreen(
            title: Get.parameters['title'] ?? 'Sản phẩm',
          ),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/product-detail',
          page: () {
            final product = Get.arguments as ProductModel?;
            if (product == null) {
              // ✅ Better error handling
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  'Lỗi',
                  'Không thể tải thông tin sản phẩm',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.offNamed('/home');
              });
              return const NavigationMenu();
            }
            return ProductDetailScreen(product: product);
          },
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/product-reviews',
          page: () => ProductReviewsScreen(
            productId: Get.arguments as String? ?? '',
            productTag: '',
          ),
          transition: Transition.rightToLeft,
        ),
        
        // User Features
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/user-address',
          page: () => const UserAddressScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/my-orders',
          page: () => const OrderScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/coupons',
          page: () => DiscountScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/checkout',
          page: () => const CheckoutScreen(),
          transition: Transition.rightToLeft,
        ),

        // Payment
        GetPage(
          name: '/payment-success',
          page: () => const PaymentSuccessScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/payment-failure',
          page: () => const PaymentFailureScreen(),
          transition: Transition.fadeIn,
        ),
      ],
      
      // ✅ Global error handling
      builder: (context, child) {
        // Handle global errors
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Đã xảy ra lỗi'),
                  const SizedBox(height: 8),
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorDetails.exception.toString(),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed('/'),
                    child: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ),
          );
        };
        
        return child ?? const SizedBox.shrink();
      },
    );
  }
}