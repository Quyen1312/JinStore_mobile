import 'package:flutter_application_jin/data/repositories/category/category_repository.dart';
import 'package:flutter_application_jin/features/shop/models/category_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final CategoryRepository categoryRepository;
  
  // Reactive variables to store category data and loading state
  var categoryList = <CategoryModel>[].obs;
  var singleCategory = Rxn<CategoryModel>();
  var isLoading = false.obs;

  CategoryController({required this.categoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories(); // Automatically fetch categories when controller is initialized
  }

  // Fetch all categories
  Future<void> fetchAllCategories() async {
    try {
      isLoading.value = true;
      final response = await categoryRepository.allCategoryList();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body['data'];
        categoryList.value = data.map((item) => CategoryModel.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch single category (if needed)
  Future<void> fetchCategoryById(String categoryId) async {
    try {
      isLoading.value = true;
      // Assuming your API for single category is something like /category/:id
      // You might need to adjust the API constant or method in repository if it's different
      final response = await categoryRepository.apiClient.getData('${ApiConstants.CATEGORY}/$categoryId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        singleCategory.value = CategoryModel.fromJson(response.body['data']);
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load category');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}