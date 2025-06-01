// File: lib/features/shop/controllers/product_controller.dart
import 'dart:async';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/service/product/product_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  // Khởi tạo ProductService
  final ProductService _productService = Get.find<ProductService>();

  // Các biến isLoading cho từng tác vụ
  var isLoadingAllProducts = false.obs;
  var isLoadingFeaturedProducts = false.obs;
  var isLoadingCategoryProducts = false.obs;
  var isLoadingProductDetail = false.obs;
  var isPerformingClientSearch = false.obs;

  var error = ''.obs;

  // Danh sách sản phẩm
  var allProducts = <ProductModel>[].obs;
  var featuredProducts = <ProductModel>[].obs;
  var productsByCategory = <ProductModel>[].obs;
  var currentProduct = Rxn<ProductModel>();
  var searchResults = <ProductModel>[].obs;
  
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoadingAllProducts.value = true;
      isLoadingFeaturedProducts.value = true;
      allProducts.clear();
      featuredProducts.clear();
      error.value = '';

      print('[ProductController] Starting fetchAllProducts...');
      
      final List<dynamic> productDataList = await _productService.getAllProducts();
      
      print('[ProductController] Received ${productDataList.length} products from service');

      if (productDataList.isNotEmpty) {
        final List<ProductModel> parsedProducts = [];
        
        for (int i = 0; i < productDataList.length; i++) {
          try {
            var data = productDataList[i];
            print('[ProductController] Parsing product $i: ${data['name'] ?? 'No name'}');
            
            if (data is Map<String, dynamic>) {
              // Log các field quan trọng để debug
              print('[ProductController] Product data structure:');
              print('  - _id: ${data['_id']}');
              print('  - name: ${data['name']}');
              print('  - price: ${data['price']} (type: ${data['price'].runtimeType})');
              print('  - quantity: ${data['quantity']} (type: ${data['quantity'].runtimeType})');
              print('  - discount: ${data['discount']} (type: ${data['discount'].runtimeType})');
              print('  - countBuy: ${data['countBuy']} (type: ${data['countBuy'].runtimeType})');
              print('  - averageRating: ${data['averageRating']} (type: ${data['averageRating'].runtimeType})');
              print('  - isActive: ${data['isActive']} (type: ${data['isActive'].runtimeType})');
              print('  - images: ${data['images']?.runtimeType}');
              print('  - information: ${data['information']?.runtimeType}');
              
              final product = ProductModel.fromJson(data);
              parsedProducts.add(product);
              print('[ProductController] Successfully parsed product: ${product.name}');
            } else {
              print('[ProductController] Warning: Product data at index $i is not a Map: ${data.runtimeType}');
            }
          } catch (parseError, stackTrace) {
            print('[ProductController] Error parsing product at index $i:');
            print('  Error: $parseError');
            print('  Data: ${productDataList[i]}');
            print('  Stack trace: $stackTrace');
          }
        }
        
        print('[ProductController] Successfully parsed ${parsedProducts.length} out of ${productDataList.length} products');
        
        allProducts.assignAll(parsedProducts);

        // Lấy featured products (các sản phẩm có rating cao hoặc bán chạy)
        final featured = parsedProducts.where((p) => p.isFeatured).take(6).toList();
        if (featured.isEmpty && parsedProducts.isNotEmpty) {
          // Fallback: lấy 4 sản phẩm đầu tiên
          featuredProducts.assignAll(parsedProducts.take(4).toList());
        } else {
          featuredProducts.assignAll(featured);
        }

        if (parsedProducts.isEmpty && productDataList.isNotEmpty) {
          throw Exception('Không thể parse bất kỳ sản phẩm nào. Vui lòng kiểm tra định dạng dữ liệu từ API.');
        }
      } else {
        print('[ProductController] No products received from API');
      }
    } catch (e, stackTrace) {
      error.value = "Lỗi tải sản phẩm: ${e.toString()}";
      print('[ProductController] Error in fetchAllProducts: $e');
      print('[ProductController] Stack trace: $stackTrace');
      Loaders.errorSnackBar(
        title: 'Lỗi!', 
        message: 'Không thể tải sản phẩm. Vui lòng thử lại.'
      );
    } finally {
      isLoadingAllProducts.value = false;
      isLoadingFeaturedProducts.value = false;
    }
  }

  Future<void> fetchProductsByCategoryId(String categoryId) async {
    try {
      isLoadingCategoryProducts.value = true;
      productsByCategory.clear();
      error.value = '';

      print('[ProductController] Fetching products for category: $categoryId');
      
      final List<dynamic> productDataList = await _productService.getProductsByCategory(categoryId);
      
      print('[ProductController] Received ${productDataList.length} products for category');

      if (productDataList.isNotEmpty) {
        final List<ProductModel> parsedProducts = [];
        
        for (var data in productDataList) {
          try {
            if (data is Map<String, dynamic>) {
              parsedProducts.add(ProductModel.fromJson(data));
            }
          } catch (parseError) {
            print('[ProductController] Error parsing category product: $parseError');
          }
        }
        
        productsByCategory.assignAll(parsedProducts);
        print('[ProductController] Successfully loaded ${parsedProducts.length} products for category');
      }
    } catch (e) {
      error.value = "Lỗi tải sản phẩm theo danh mục: ${e.toString()}";
      print('[ProductController] Error in fetchProductsByCategoryId: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi', 
        message: 'Không thể tải sản phẩm theo danh mục'
      );
    } finally {
      isLoadingCategoryProducts.value = false;
    }
  }

  Future<void> fetchProductById(String productId) async {
    try {
      isLoadingProductDetail.value = true;
      currentProduct.value = null;
      error.value = '';

      print('[ProductController] Fetching product detail for ID: $productId');
      
      final Map<String, dynamic> productData = await _productService.getProductById(productId);

      if (productData.isNotEmpty) {
        currentProduct.value = ProductModel.fromJson(productData);
        print('[ProductController] Successfully loaded product: ${currentProduct.value?.name}');
      } else {
        throw Exception('Không tìm thấy thông tin sản phẩm');
      }
    } catch (e) {
      error.value = "Lỗi tải chi tiết sản phẩm: ${e.toString()}";
      print('[ProductController] Error in fetchProductById: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi', 
        message: 'Không thể tải thông tin sản phẩm'
      );
      currentProduct.value = null;
    } finally {
      isLoadingProductDetail.value = false;
    }
  }

  // Client-side search
  void performClientSideSearch(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    
    if (trimmedQuery.isEmpty) {
      searchResults.clear();
      isPerformingClientSearch.value = false;
      return;
    }

    isPerformingClientSearch.value = true;
    
    if (isLoadingAllProducts.value || allProducts.isEmpty) {
      searchResults.clear();
      isPerformingClientSearch.value = false;
      return;
    }

    final results = allProducts.where((product) {
      final productNameLower = product.name.toLowerCase();
      final productDescriptionLower = product.description.toLowerCase();
      
      return productNameLower.contains(trimmedQuery) || 
             productDescriptionLower.contains(trimmedQuery);
    }).toList();

    searchResults.assignAll(results);
    isPerformingClientSearch.value = false;
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    performClientSideSearch(query);
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchAllProducts();
  }

  // Get products by filter
  Future<void> fetchProductsWithFilter({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      isLoadingAllProducts.value = true;
      error.value = '';

      final List<dynamic> productDataList = await _productService.searchProducts(
        keyword: keyword,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final List<ProductModel> parsedProducts = [];
      for (var data in productDataList) {
        try {
          if (data is Map<String, dynamic>) {
            parsedProducts.add(ProductModel.fromJson(data));
          }
        } catch (e) {
          print('[ProductController] Error parsing filtered product: $e');
        }
      }

      allProducts.assignAll(parsedProducts);
    } catch (e) {
      error.value = "Lỗi tìm kiếm sản phẩm: ${e.toString()}";
      Loaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      isLoadingAllProducts.value = false;
    }
  }
}