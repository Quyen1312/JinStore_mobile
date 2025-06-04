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
import 'package:flutter_application_jin/utils/theme/theme.dart';
import 'package:get/get.dart';

// WebView platform imports - THÊM CÁC IMPORT NÀY
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

/// Main function - entry point of the application
Future<void> main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WebView platform for web - THÊM ĐOẠN NÀY
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }
  
  // Initialize dependencies
  await DependencyInjection.init();
  
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
      
      // Routes
      initialRoute: '/',
      getPages: [
        // Splash & Authentication
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnBoardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        
        // Main Navigation
        GetPage(name: '/home', page: () => const NavigationMenu()),
        
        // Shop Features
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/search', page: () => const SearchScreen()),
        GetPage(
          name: '/all-products', 
          page: () => AllProductScreen(
            title: Get.parameters['title'] ?? 'Sản phẩm',
          ),
        ),
        GetPage(
          name: '/product-detail',
          page: () {
            final product = Get.arguments as ProductModel?;
            if (product == null) {
              Get.offNamed('/home');
              return const NavigationMenu();
            }
            return ProductDetailScreen(product: product);
          },
        ),
        GetPage(
          name: '/product-reviews',
          page: () => ProductReviewsScreen(
            productId: Get.arguments as String? ?? '',
            productTag: '',
          ),
        ),
        
        // User Features
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/user-address', page: () => const UserAddressScreen()),
        GetPage(name: '/my-orders', page: () => const OrderScreen()),
        GetPage(name: '/coupons', page: () => DiscountScreen()),
        GetPage(name: '/checkout', page: () => const CheckoutScreen()),

        //payment
        GetPage(name: '/payment-success', page: () => const PaymentSuccessScreen()),
        GetPage(name: '/payment-failure', page: () => const PaymentFailureScreen()),
      ],
    );
  }
}