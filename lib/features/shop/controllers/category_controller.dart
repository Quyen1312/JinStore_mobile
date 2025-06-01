import 'package:flutter_application_jin/features/shop/models/category_model.dart';
import 'package:flutter_application_jin/service/category/category_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final CategoryService categoryService;

  var categoryList = <Category>[].obs;
  var singleCategory = Rxn<Category>();
  var isLoading = false.obs;
  var isLoadingSingleCategory = false.obs;
  var error = ''.obs; 

  CategoryController({required this.categoryService});

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
  try {
    isLoading.value = true;
    categoryList.clear();

    final data = await categoryService.getAllCategories(); // Không còn statusCode

    final categories = data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    categoryList.assignAll(categories);
    } catch (e) {
    Loaders.errorSnackBar(
      title: 'Ôi không!',
      message: 'Lỗi tải danh mục: ${e.toString()}',
    );
  } finally {
    isLoading.value = false;
  }
}


  Future<void> fetchCategoryById(String categoryId) async {
  try {
    isLoadingSingleCategory.value = true;
    singleCategory.value = null;

    final data = await categoryService.getCategoryById(categoryId);

    if (data.containsKey('_id')) {
      singleCategory.value = Category.fromJson(data);
    } else {
      Loaders.errorSnackBar(
        title: 'Lỗi dữ liệu',
        message: 'Không tìm thấy hoặc định dạng dữ liệu chi tiết danh mục không đúng.',
      );
    }
  } catch (e) {
    Loaders.errorSnackBar(
      title: 'Ôi không!',
      message: 'Lỗi tải chi tiết danh mục: ${e.toString()}',
    );
  } finally {
    isLoadingSingleCategory.value = false;
  }
}
}