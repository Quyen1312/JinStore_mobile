import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/models/category_model.dart';
import 'package:flutter_application_jin/service/category_service.dart';
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
    // ✅ Sử dụng addPostFrameCallback để tránh setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllCategories();
    });
  }

  Future<void> fetchAllCategories() async {
    try {
      // ✅ Prevent multiple simultaneous calls
      if (isLoading.value) {
        print('[CategoryController] ⚠️ Already loading categories, skipping...');
        return;
      }

      isLoading.value = true;
      categoryList.clear();
      error.value = '';

      print('[CategoryController] 🔍 Fetching all categories...');

      // ✅ Giữ nguyên logic gọi service như cũ
      final data = await categoryService.getAllCategories();
      print('[CategoryController] 📦 Received ${data.length} categories from service');

      // ✅ Giữ nguyên logic parse như cũ
      final categories = data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      // ✅ Sử dụng addPostFrameCallback để assign data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        categoryList.assignAll(categories);
      });

      print('[CategoryController] ✅ Successfully loaded ${categories.length} categories');

    } catch (e, stackTrace) {
      error.value = 'Lỗi tải danh mục: ${e.toString()}';
      print('[CategoryController] ❌ Error in fetchAllCategories: $e');
      
      // ✅ Sử dụng addPostFrameCallback cho error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Loaders.errorSnackBar(
          title: 'Ôi không!',
          message: 'Lỗi tải danh mục: ${e.toString()}',
        );
      });
    } finally {
      // ✅ Sử dụng addPostFrameCallback để set loading = false
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchCategoryById(String categoryId) async {
    try {
      // ✅ Prevent multiple simultaneous calls
      if (isLoadingSingleCategory.value) {
        print('[CategoryController] ⚠️ Already loading single category, skipping...');
        return;
      }

      isLoadingSingleCategory.value = true;
      singleCategory.value = null;
      error.value = '';

      print('[CategoryController] 🔍 Fetching category by ID: $categoryId');

      // ✅ Giữ nguyên logic gọi service như cũ
      final data = await categoryService.getCategoryById(categoryId);

      if (data.containsKey('_id')) {
        final category = Category.fromJson(data);
        
        // ✅ Sử dụng addPostFrameCallback để assign data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          singleCategory.value = category;
        });

        print('[CategoryController] ✅ Successfully loaded category: ${category.name}');
      } else {
        throw Exception('Không tìm thấy hoặc định dạng dữ liệu chi tiết danh mục không đúng.');
      }

    } catch (e, stackTrace) {
      error.value = 'Lỗi tải chi tiết danh mục: ${e.toString()}';
      print('[CategoryController] ❌ Error in fetchCategoryById: $e');
      
      // ✅ Sử dụng addPostFrameCallback cho error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Loaders.errorSnackBar(
          title: 'Ôi không!',
          message: 'Lỗi tải chi tiết danh mục: ${e.toString()}',
        );
      });
    } finally {
      // ✅ Sử dụng addPostFrameCallback để set loading = false
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoadingSingleCategory.value = false;
      });
    }
  }

  /// ✅ Thêm helper methods mà không thay đổi core logic
  void refreshCategories() {
    fetchAllCategories();
  }

  void clearError() {
    error.value = '';
  }

  Category? getCategoryFromCache(String categoryId) {
    try {
      return categoryList.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}