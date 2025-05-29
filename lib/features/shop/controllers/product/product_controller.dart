import 'package:flutter_application_jin/data/repositories/product/product_repository.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository;

  var productList = <ProductModel>[].obs;
  var productByCategoryList = <ProductModel>[].obs;
  var discountList = <ProductModel>[].obs; // Assuming discounts might be products or a specific discount model
  var singleProduct = Rxn<ProductModel>();
  var isLoading = false.obs;

  ProductController({required this.productRepository});

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts();
    fetchAllDiscounts();
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      final response = await productRepository.allProductList();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body['data'];
        productList.value = data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      final response = await productRepository.apiClient.getData('${ApiConstants.PRODUCT_BY_CATEGORY_URI_BASE}/$categoryId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body['data'];
        productByCategoryList.value = data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load products by category');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllDiscounts() async {
    try {
      isLoading.value = true;
      final response = await productRepository.allDiscount();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body['data'];
        // Assuming discountList also uses ProductModel, adjust if you have a separate DiscountModel
        discountList.value = data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load discounts');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductById(String productId) async {
    try {
      isLoading.value = true;
      // This assumes your API for a single product is /product/:id
      // You may need to add a specific method in ProductRepository or adjust ApiConstants
      final response = await productRepository.apiClient.getData('${ApiConstants.ALL_PRODUCT_URI}/$productId'); // Changed to ALL_PRODUCT_URI as placeholder
      if (response.statusCode == 200 || response.statusCode == 201) {
        singleProduct.value = ProductModel.fromJson(response.body['data']);
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load product details');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Example: Fetch a specific discount if needed, assuming it returns a ProductModel
  Future<void> fetchDiscountById(String discountId) async {
    try {
      isLoading.value = true;
      final response = await productRepository.apiClient.getData('${ApiConstants.DISCOUNT}/$discountId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If you have a specific model for a single discount, use that here
        // For now, assuming it might be a ProductModel or you want to display it as such
        // singleProduct.value = ProductModel.fromJson(response.body['data']); 
        Get.snackbar('Success', 'Discount details loaded');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load discount details');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}