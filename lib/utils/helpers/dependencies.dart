import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/data/repositories/user/user_repository.dart';
import 'package:flutter_application_jin/data/repositories/product/product_repository.dart';
import 'package:flutter_application_jin/data/repositories/category/category_repository.dart';
import 'package:flutter_application_jin/data/repositories/cart/cart_repository.dart'; // Import CartRepository
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user/user_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/category/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart/cart_controller.dart'; // Import CartController
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

Future<void> init() async {
  // SharedPreferences (nếu bạn muốn truy cập nó qua GetX, mặc dù thường không cần thiết nếu chỉ dùng trực tiếp)
  // final sharedPreferences = await SharedPreferences.getInstance();
  // Get.lazyPut(() => sharedPreferences, fenix: true);

  // API Client
  Get.lazyPut(() => ApiClient(jbaseUrl: ApiConstants.BASE_URL), fenix: true);

  // Repositories
  Get.lazyPut(() => AuthRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ProductRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CategoryRepository(apiClient: Get.find()), fenix: true); // Giả sử bạn có CategoryRepository
  Get.lazyPut(() => CartRepository(apiClient: Get.find()), fenix: true);   // Đăng ký CartRepository

  // Controllers
  // Sửa dòng đăng ký AuthController để truyền cả apiClient
  Get.lazyPut(() => AuthController(authRepository: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => UserController(userRepository: Get.find()), fenix: true);
  Get.lazyPut(() => ProductController(productRepository: Get.find()), fenix: true);
  Get.lazyPut(() => CategoryController(categoryRepository: Get.find()), fenix: true); // Giả sử bạn có CategoryController
  Get.lazyPut(() => CartController(cartRepository: Get.find()), fenix: true);     // Đăng ký CartController

  // Khởi tạo các controller khác nếu cần
}
