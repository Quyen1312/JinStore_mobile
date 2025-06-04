// File: lib/features/shop/controllers/product_controller.dart
import 'dart:async';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/service/product_service.dart';
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
  var isPerformingServerSearch = false.obs; // ✅ Thêm loading cho server search

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
    // ✅ Test connection first, then fetch products
    _initializeController();
  }

  /// ✅ Initialize controller with connection test
  Future<void> _initializeController() async {
    try {
      print('[ProductController] 🚀 Initializing controller...');
      
      // Test connection
      final isConnected = await _productService.testConnection();
      if (!isConnected) {
        error.value = 'Không thể kết nối đến server';
        Loaders.errorSnackBar(
          title: 'Lỗi kết nối', 
          message: 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.'
        );
        return;
      }
      
      // Fetch products if connected
      await fetchAllProducts();
    } catch (e) {
      print('[ProductController] ❌ Error initializing: $e');
      error.value = 'Lỗi khởi tạo: ${e.toString()}';
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoadingAllProducts.value = true;
      isLoadingFeaturedProducts.value = true;
      allProducts.clear();
      featuredProducts.clear();
      error.value = '';

      print('[ProductController] 🚀 Starting fetchAllProducts...');
      
      final List<dynamic> productDataList = await _productService.getAllProducts();
      
      print('[ProductController] 📦 Received ${productDataList.length} products from service');

      if (productDataList.isNotEmpty) {
        final List<ProductModel> parsedProducts = [];
        
        for (int i = 0; i < productDataList.length; i++) {
          try {
            var data = productDataList[i];
            print('[ProductController] 🔄 Parsing product $i: ${data['name'] ?? 'No name'}');
            
            if (data is Map<String, dynamic>) {
              // ✅ Validate required fields before parsing
              if (!_validateProductData(data)) {
                print('[ProductController] ❌ Product $i failed validation, skipping');
                continue;
              }
              
              final product = ProductModel.fromJson(data);
              parsedProducts.add(product);
              print('[ProductController] ✅ Successfully parsed: ${product.name}');
            } else {
              print('[ProductController] ⚠️ Product data at index $i is not a Map: ${data.runtimeType}');
            }
          } catch (parseError, stackTrace) {
            print('[ProductController] ❌ Error parsing product at index $i:');
            print('  Error: $parseError');
            print('  Data: ${productDataList[i]}');
          }
        }
        
        print('[ProductController] ✅ Successfully parsed ${parsedProducts.length} out of ${productDataList.length} products');
        
        allProducts.assignAll(parsedProducts);

        // Lấy featured products
        final featured = parsedProducts.where((p) => p.isFeatured).take(6).toList();
        if (featured.isEmpty && parsedProducts.isNotEmpty) {
          featuredProducts.assignAll(parsedProducts.take(4).toList());
        } else {
          featuredProducts.assignAll(featured);
        }

        if (parsedProducts.isEmpty && productDataList.isNotEmpty) {
          throw Exception('Không thể parse bất kỳ sản phẩm nào. Vui lòng kiểm tra định dạng dữ liệu từ API.');
        }
      } else {
        print('[ProductController] 📭 No products received from API');
      }
    } catch (e, stackTrace) {
      error.value = "Lỗi tải sản phẩm: ${e.toString()}";
      print('[ProductController] ❌ Error in fetchAllProducts: $e');
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

  /// ✅ Improved fetchProductById with better error handling
  Future<ProductModel?> fetchProductById(String productId) async {
    try {
      isLoadingProductDetail.value = true;
      currentProduct.value = null;
      error.value = '';

      print('[ProductController] 🔍 Fetching product detail for ID: $productId');
      
      // ✅ Validate productId
      if (productId.trim().isEmpty) {
        throw Exception('Product ID không hợp lệ');
      }
      
      final dynamic response = await _productService.getProductById(productId);
      print('[ProductController] 📥 Raw response type: ${response.runtimeType}');
      print('[ProductController] 📥 Raw response: $response');

      Map<String, dynamic> productData;
      
      // ✅ Handle different response formats
      if (response is Map<String, dynamic>) {
        // Direct product data
        productData = response;
      } else if (response is List && response.isNotEmpty) {
        // Array with single product
        productData = response.first as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format: ${response.runtimeType}');
      }

      // ✅ Validate product data
      if (productData.isEmpty) {
        throw Exception('Không tìm thấy thông tin sản phẩm');
      }

      if (!_validateProductData(productData)) {
        throw Exception('Dữ liệu sản phẩm không hợp lệ');
      }

      final product = ProductModel.fromJson(productData);
      currentProduct.value = product;
      
      print('[ProductController] ✅ Successfully loaded product: ${product.name}');
      print('[ProductController] 🖼️ Product images count: ${product.images?.length ?? 0}');
      
      return product;
      
    } catch (e, stackTrace) {
      error.value = "Lỗi tải chi tiết sản phẩm: ${e.toString()}";
      print('[ProductController] ❌ Error in fetchProductById: $e');
      print('[ProductController] Stack trace: $stackTrace');
      
      Loaders.errorSnackBar(
        title: 'Lỗi', 
        message: 'Không thể tải thông tin sản phẩm: ${e.toString()}'
      );
      currentProduct.value = null;
      return null;
    } finally {
      isLoadingProductDetail.value = false;
    }
  }

  /// ✅ Improved search with server-side search
  Future<void> performServerSearch(String query, {
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      isPerformingServerSearch.value = true;
      searchResults.clear();
      error.value = '';

      final trimmedQuery = query.trim();
      print('[ProductController] 🔍 Performing server search: "$trimmedQuery"');

      if (trimmedQuery.isEmpty) {
        print('[ProductController] ⚠️ Empty search query, clearing results');
        return;
      }

      final List<dynamic> productDataList = await _productService.searchProducts(
        keyword: trimmedQuery,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('[ProductController] 📦 Search returned ${productDataList.length} products');

      final List<ProductModel> parsedProducts = [];
      for (int i = 0; i < productDataList.length; i++) {
        try {
          var data = productDataList[i];
          if (data is Map<String, dynamic> && _validateProductData(data)) {
            final product = ProductModel.fromJson(data);
            parsedProducts.add(product);
          }
        } catch (e) {
          print('[ProductController] ❌ Error parsing search result $i: $e');
        }
      }

      searchResults.assignAll(parsedProducts);
      searchQuery.value = trimmedQuery;
      
      print('[ProductController] ✅ Search completed: ${parsedProducts.length} valid products');

    } catch (e, stackTrace) {
      error.value = "Lỗi tìm kiếm: ${e.toString()}";
      print('[ProductController] ❌ Error in performServerSearch: $e');
      print('[ProductController] Stack trace: $stackTrace');
      
      Loaders.errorSnackBar(
        title: 'Lỗi tìm kiếm', 
        message: 'Không thể tìm kiếm sản phẩm: ${e.toString()}'
      );
    } finally {
      isPerformingServerSearch.value = false;
    }
  }

  // ✅ Improved client-side search
  void performClientSideSearch(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    
    print('[ProductController] 🔍 Client search: "$trimmedQuery"');
    
    if (trimmedQuery.isEmpty) {
      searchResults.clear();
      searchQuery.value = '';
      isPerformingClientSearch.value = false;
      return;
    }

    isPerformingClientSearch.value = true;
    
    if (isLoadingAllProducts.value || allProducts.isEmpty) {
      print('[ProductController] ⚠️ Products not loaded yet, clearing search results');
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
    searchQuery.value = query;
    isPerformingClientSearch.value = false;
    
    print('[ProductController] ✅ Client search completed: ${results.length} results');
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    
    // ✅ Choose search method based on preference
    if (query.trim().length >= 2) {
      // Use server search for better results
      performServerSearch(query);
    } else if (query.trim().isEmpty) {
      // Clear results for empty query
      searchResults.clear();
    }
  }

  /// ✅ Validate product data before parsing
  bool _validateProductData(Map<String, dynamic> data) {
    final requiredFields = ['_id', 'name', 'price'];
    
    for (String field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        print('[ProductController] ❌ Missing required field: $field');
        return false;
      }
    }
    
    // Additional validations
    if (data['name'].toString().trim().isEmpty) {
      print('[ProductController] ❌ Empty product name');
      return false;
    }
    
    return true;
  }

  Future<void> fetchProductsByCategoryId(String categoryId) async {
    try {
      isLoadingCategoryProducts.value = true;
      productsByCategory.clear();
      error.value = '';

      print('[ProductController] 📂 Fetching products for category: $categoryId');
      
      if (categoryId.trim().isEmpty) {
        throw Exception('Category ID không hợp lệ');
      }
      
      final List<dynamic> productDataList = await _productService.getProductsByCategory(categoryId);
      
      print('[ProductController] 📦 Received ${productDataList.length} products for category');

      if (productDataList.isNotEmpty) {
        final List<ProductModel> parsedProducts = [];
        
        for (int i = 0; i < productDataList.length; i++) {
          try {
            var data = productDataList[i];
            if (data is Map<String, dynamic> && _validateProductData(data)) {
              parsedProducts.add(ProductModel.fromJson(data));
            }
          } catch (parseError) {
            print('[ProductController] ❌ Error parsing category product $i: $parseError');
          }
        }
        
        productsByCategory.assignAll(parsedProducts);
        print('[ProductController] ✅ Successfully loaded ${parsedProducts.length} products for category');
      }
    } catch (e, stackTrace) {
      error.value = "Lỗi tải sản phẩm theo danh mục: ${e.toString()}";
      print('[ProductController] ❌ Error in fetchProductsByCategoryId: $e');
      print('[ProductController] Stack trace: $stackTrace');
      
      Loaders.errorSnackBar(
        title: 'Lỗi', 
        message: 'Không thể tải sản phẩm theo danh mục: ${e.toString()}'
      );
    } finally {
      isLoadingCategoryProducts.value = false;
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchAllProducts();
  }

  /// ✅ Clear search results
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
    isPerformingClientSearch.value = false;
    isPerformingServerSearch.value = false;
  }

  /// ✅ Get product from cache by ID (faster than API call)
  ProductModel? getProductFromCache(String productId) {
    try {
      return allProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      print('[ProductController] Product $productId not found in cache');
      return null;
    }
  }
}