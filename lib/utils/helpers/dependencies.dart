import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/data/repositories/category/category_repository.dart';
import 'package:flutter_application_jin/data/repositories/product/product_repository.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/category/category_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/product/product_controller.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

Future<void> init() async {
  // API client
  Get.lazyPut(() => ApiClient(jbaseUrl: ApiConstants.BASE_URL));

  // Repositories
  Get.lazyPut(() => ProductRepository(apiClient: Get.find()));
  Get.lazyPut(() => CategoryRepository(apiClient: Get.find()));
  Get.lazyPut(() => AuthRepository(apiClient: Get.find()));

  // Controllers
  Get.lazyPut(() => ProductController(productRepository: Get.find()));
  Get.lazyPut(() => CategoryController(categoryRepository: Get.find()));
  Get.lazyPut(() => AuthController(authRepository: Get.find()));
}