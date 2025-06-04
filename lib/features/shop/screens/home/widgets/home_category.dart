import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/category_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/category_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/all_products/all_products.dart';
import 'package:flutter_application_jin/service/category_service.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  CategoryController? categoryController;

  @override
  void initState() {
    super.initState();
    // ✅ Safely initialize controller
    _initializeController();
  }

  void _initializeController() {
    try {
      // ✅ Check if CategoryController exists, if not create it
      if (Get.isRegistered<CategoryController>()) {
        categoryController = Get.find<CategoryController>();
        print('✅ Found existing CategoryController');
      } else {
        // ✅ Create CategoryController nếu chưa có (fallback)
        print('⚠️ CategoryController not found, creating new one...');
        
        // Get CategoryService (should be available)
        if (Get.isRegistered<CategoryService>()) {
          final categoryService = Get.find<CategoryService>();
          categoryController = Get.put(CategoryController(categoryService: categoryService));
          print('✅ Created new CategoryController');
        } else {
          print('❌ CategoryService not found!');
          // Retry after delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _initializeController();
          });
          return;
        }
      }
      
      // ✅ Update UI after controller is ready
      if (mounted) {
        setState(() {});
      }
      
    } catch (e) {
      print('❌ Error initializing CategoryController: $e');
      
      // ✅ Retry after delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _initializeController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading if controller not ready
    if (categoryController == null) {
      return _buildInitializingWidget();
    }

    return Obx(() {
      final isLoading = categoryController!.isLoading.value;
      final categories = categoryController!.categoryList;
      final error = categoryController!.error.value;

      // ✅ Loading state
      if (isLoading && categories.isEmpty) {
        return const CategoryShimmer();
      }

      // ✅ Error state
      if (error.isNotEmpty && categories.isEmpty) {
        return _buildErrorWidget(error);
      }

      // ✅ Empty state
      if (categories.isEmpty) {
        return _buildEmptyWidget();
      }

      // ✅ Categories list
      return SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: categories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = categories[index];
            
            return VerticalImageText(
              // ✅ Handle image according to your current Category model
              image: _getCategoryImageUrl(category),
              title: category.name ?? '',
              isNetworkImage: _isNetworkImage(category),
              textColor: AppColors.textWhite,
              backgroundColor: Colors.transparent,
              onTap: () {
                // ✅ Navigate to AllProductScreen với categoryId
                print('🔍 Navigating to category: ${category.name}');
                Get.to(() => AllProductScreen(
                  title: category.name ?? 'Category',
                  categoryId: category.id,
                ));
              },
            );
          },
        ),
      );
    });
  }

  /// ✅ Extract image URL based on your current Category model structure
  String _getCategoryImageUrl(dynamic category) {
    try {
      // Adapt this to your current Category model structure
      if (category.image != null) {
        // If image is an object with url property
        if (category.image is Map) {
          return category.image['url'] ?? '';
        }
        // If image has url property directly
        else if (category.image.url != null) {
          return category.image.url;
        }
        // If image is just a string
        else if (category.image is String) {
          return category.image;
        }
      }
      return '';
    } catch (e) {
      print('❌ Error getting category image: $e');
      return '';
    }
  }

  /// ✅ Check if image is network image
  bool _isNetworkImage(dynamic category) {
    final imageUrl = _getCategoryImageUrl(category);
    return imageUrl.isNotEmpty && 
           (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
  }

  /// ✅ Build initializing widget
  Widget _buildInitializingWidget() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Đang khởi tạo danh mục...',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Build error widget
  Widget _buildErrorWidget(String error) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceBtwItems,
        horizontal: AppSizes.defaultSpace,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Lỗi tải danh mục',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                print('🔄 Retrying to fetch categories...');
                categoryController?.fetchAllCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withOpacity(0.1),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                minimumSize: const Size(60, 30),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Build empty widget
  Widget _buildEmptyWidget() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceBtwItems,
        horizontal: AppSizes.defaultSpace,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              color: AppColors.textWhite.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Không có danh mục nào',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textWhite.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}