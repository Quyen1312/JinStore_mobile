import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/features/authentication/screens/splash/splash_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/all_products/all_products.dart'; // Lớp AllProducts
import 'package:flutter_application_jin/features/shop/screens/cart/cart.dart';                 // Lớp CartScreen
import 'package:flutter_application_jin/features/shop/screens/discount/discount.dart';
import 'package:flutter_application_jin/features/shop/screens/home/home.dart';                   // Lớp HomeScreen
import 'package:flutter_application_jin/features/shop/screens/product_details/product_detail.dart'; // Lớp ProductDetail
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_review_section.dart';
import 'package:flutter_application_jin/features/shop/screens/search/search_screen.dart';          // Lớp SearchScreen // Placeholder, bạn cần tạo màn hình này
import 'package:flutter_application_jin/features/shop/screens/checkout/checkout.dart';           // Lớp CheckoutScreen            // Lớp Coupons
import 'package:flutter_application_jin/features/shop/screens/order/order.dart';                   // Lớp OrderScreen
import 'package:flutter_application_jin/features/personalization/screens/address/address.dart';    // Lớp UserAddressScreen
import 'package:flutter_application_jin/features/personalization/screens/profile/profile.dart';    // Lớp ProfileScreen
import 'package:flutter_application_jin/features/personalization/screens/settings/settings.dart';  // Lớp SettingsScreen
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Import Product model
import 'package:flutter_application_jin/service/dependencies.dart';
import 'package:flutter_application_jin/utils/theme/theme.dart';
import 'package:get/get.dart';
// SharedPreferences đã được xử lý trong DependencyInjection.init()

// Hàm main, điểm khởi đầu của ứng dụng
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences.getInstance() được gọi trong DependencyInjection.init() rồi.
  await DependencyInjection.init();
  runApp(const App());
}

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
      initialRoute: AppRoutes.home, // Sử dụng initialRoute với hằng số
      getPages: AppRoutes.routes,
    );
  }
}

class AppRoutes {
  // Định nghĩa các hằng số cho tên route
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String search = '/search';
  static const String allProducts = '/all-products'; // Đổi tên route cho rõ ràng
  static const String productDetail = '/product-detail';
  static const String allCategories = '/all-categories';
  static const String productReviews = '/product-reviews';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String userAddress = '/user-address';
  static const String myOrders = '/my-orders';
  static const String coupons = '/coupons';
  static const String checkout = '/checkout';
  // Thêm các hằng số route khác nếu cần

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => const OnBoardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: cart, page: () => const CartScreen()),
    GetPage(name: search, page: () => const SearchScreen()),
    GetPage(
      name: productDetail,
      page: () {
        final product = Get.arguments as ProductModel; // Đảm bảo truyền Product object
        return ProductDetailScreen(product: product); // Sử dụng tên lớp ProductDetail của bạn
      },
    ),
    GetPage(
      name: allProducts,
      page: () {
        // Nhận tham số từ Get.parameters nếu dùng Get.toNamed với parameters
        // Hoặc nhận từ Get.arguments nếu truyền một Map các arguments
        final String title = Get.parameters['title'] ?? 'Sản phẩm';
        return AllProductScreen( // Sử dụng tên lớp AllProducts của bạn
          title: title,
        );
      },
    ),
    GetPage(
      name: productReviews,
      page: () {
        final String productId = Get.arguments as String; // Đảm bảo truyền productId
        return ProductReviewsScreen(productId: productId);
      },
    ),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: userAddress, page: () => const UserAddressScreen()),
    GetPage(name: myOrders, page: () => const OrderScreen()),
    GetPage(name: coupons, page: () =>  DiscountScreen()), // Sử dụng tên lớp Coupons của bạn
    GetPage(name: checkout, page: () => const CheckoutScreen()),
  ];
}