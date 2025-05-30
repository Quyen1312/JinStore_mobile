import 'package:flutter_application_jin/data/repositories/category/category_repository.dart';
import 'package:flutter_application_jin/features/shop/models/category_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final CategoryRepository categoryRepository;
  
  var categoryList = <CategoryModel>[].obs;
  var singleCategory = Rxn<CategoryModel>();
  var isLoading = false.obs;
  var isLoadingSingleCategory = false.obs;

  CategoryController({required this.categoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories(); 
  }

  Future<void> fetchAllCategories() async {
    try {
      isLoading.value = true;
      categoryList.clear();
      final response = await categoryRepository.fetchAllCategory(); 
      
      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic responseData = response.body;
        List<dynamic> categoryDataList;

        // Backend API GET /api/categories/ trả về trực tiếp mảng categories
        if (responseData is List<dynamic>) {
          categoryDataList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
            categoryList.clear(); // Không có danh mục
            // Loaders.infoSnackBar(title: 'Thông báo', message: responseData['message']);
            isLoading.value = false;
            return;
        }
        else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Định dạng dữ liệu danh mục không đúng từ API.');
          isLoading.value = false;
          return;
        }
        categoryList.assignAll(categoryDataList.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList());
      } else {
        Loaders.errorSnackBar(title: 'Lỗi tải danh mục', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải danh sách danh mục.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải danh mục: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategoryById(String categoryId) async {
    try {
      isLoadingSingleCategory.value = true; 
      singleCategory.value = null;
      final response = await categoryRepository.fetchCategoryById(categoryId); 
      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic categoryDataResponse = response.body;
        Map<String, dynamic>? singleCategoryData;

        // Backend API GET /api/categories/:id trả về trực tiếp object category
        if (categoryDataResponse is Map<String, dynamic> && categoryDataResponse.containsKey('_id')) { 
            singleCategoryData = categoryDataResponse;
        }
        
        if (singleCategoryData != null) {
           singleCategory.value = CategoryModel.fromJson(singleCategoryData);
        } else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Không tìm thấy hoặc định dạng dữ liệu chi tiết danh mục không đúng.');
        }
      } else {
        Loaders.errorSnackBar(title: 'Lỗi tải danh mục', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải chi tiết danh mục.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải chi tiết danh mục: ${e.toString()}');
    } finally {
      isLoadingSingleCategory.value = false;
    }
  }
}
