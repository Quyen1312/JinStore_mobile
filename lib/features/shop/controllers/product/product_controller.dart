import 'package:flutter_application_jin/data/repositories/product/product_repository.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart'; 
import 'package:flutter_application_jin/features/shop/models/discount_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/popups/full_screen_loader.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final ProductRepository productRepository;

  var isLoadingAllProducts = false.obs; 
  var isLoadingFeaturedProducts = false.obs;
  var isLoadingCategoryProducts = false.obs; 
  var isLoadingProductDetail = false.obs; 
  var isLoadingReviews = false.obs; 
  var isSubmittingReview = false.obs; 
  var isPerformingClientSearch = false.obs;
  var isLoadingDiscounts = false.obs;

  var allProducts = <ProductModel>[].obs;
  var featuredProducts = <ProductModel>[].obs; 
  var productsByCategory = <ProductModel>[].obs;
  var currentProduct = Rxn<ProductModel>(); 
  var searchResults = <ProductModel>[].obs; 
  final RxString searchQuery = ''.obs; 

  var discountList = <DiscountModel>[].obs; 
  var productReviews = <ReviewModel>[].obs; 

  ProductController({required this.productRepository});

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts(); 
    fetchAllDiscounts(); 
    debounce(searchQuery, (_) => performClientSideSearch(searchQuery.value), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoadingAllProducts.value = true;
      isLoadingFeaturedProducts.value = true; 
      allProducts.clear(); 
      featuredProducts.clear(); 

      final response = await productRepository.fetchAllProducts(); // GET /api/products/

      if (response.statusCode == ApiConstants.SUCCESS) {
        // Backend getAllProducts trả về trực tiếp một mảng các sản phẩm
        // hoặc một object { message: 'Không có sản phẩm nào.' }
        if (response.body is List) {
          final productDataList = response.body as List<dynamic>;
          final parsedProducts = productDataList
              .map((data) => ProductModel.fromJson(data as Map<String, dynamic>))
              .toList();
          allProducts.assignAll(parsedProducts);
          featuredProducts.assignAll(allProducts.take(4).toList());
        } else if (response.body is Map<String, dynamic> && response.body['message'] != null) {
          // Không có sản phẩm nào, list sẽ rỗng
          allProducts.clear();
          featuredProducts.clear();
          // Loaders.infoSnackBar(title: 'Thông báo', message: response.body['message']);
        } else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Định dạng dữ liệu sản phẩm không đúng từ API.');
        }
      } else {
        Loaders.errorSnackBar(title: 'Lỗi tải sản phẩm', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải danh sách sản phẩm.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Đã xảy ra lỗi khi tải sản phẩm: ${e.toString()}');
    } finally {
      isLoadingAllProducts.value = false;
      isLoadingFeaturedProducts.value = false;
    }
  }

  Future<void> fetchProductsByCategoryId(String categoryId) async {
    try {
      isLoadingCategoryProducts.value = true; 
      productsByCategory.clear(); 
      // GET /api/products/category/:idCategory
      final response = await productRepository.fetchProductsByCategoryId(categoryId);

      if (response.statusCode == ApiConstants.SUCCESS) {
        // Backend getProductByIdCategory trả về trực tiếp một mảng các sản phẩm
        if (response.body is List) {
          final productDataList = response.body as List<dynamic>;
          productsByCategory.assignAll(productDataList
              .map((data) => ProductModel.fromJson(data as Map<String, dynamic>))
              .toList());
        } else if (response.body is Map<String, dynamic> && response.body['message'] != null) {
             productsByCategory.clear();
            // Loaders.infoSnackBar(title: 'Thông báo', message: response.body['message']); // Ví dụ: "Sản phẩm không tồn tại!"
        }
        else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Định dạng dữ liệu sản phẩm theo danh mục không đúng.');
        }
      } else {
         Loaders.errorSnackBar(title: 'Lỗi tải sản phẩm', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải sản phẩm theo danh mục.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải sản phẩm theo danh mục: ${e.toString()}');
    } finally {
      isLoadingCategoryProducts.value = false;
    }
  }
  
  Future<void> fetchProductDetails(String productId) async { 
    try {
      isLoadingProductDetail.value = true;
      currentProduct.value = null; 
      productReviews.clear(); 

      // GET /api/products/:id
      final response = await productRepository.fetchProductById(productId);

      if (response.statusCode == ApiConstants.SUCCESS) {
        // Backend getProductById trả về trực tiếp một object sản phẩm
        if (response.body is Map<String, dynamic>) {
           final singleProductData = response.body as Map<String, dynamic>;
           currentProduct.value = ProductModel.fromJson(singleProductData);
        } else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Định dạng dữ liệu chi tiết sản phẩm không đúng.');
          isLoadingProductDetail.value = false;
          return;
        }
        
        // Sau khi lấy chi tiết sản phẩm, lấy đánh giá cho sản phẩm đó
        // API getProductById không populate review, nên ta cần gọi riêng
        if (currentProduct.value != null) {
          await fetchReviewsForProduct(productId);
        }

      } else {
        Loaders.errorSnackBar(title: 'Lỗi tải sản phẩm', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải chi tiết sản phẩm.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải chi tiết sản phẩm: ${e.toString()}');
    } finally {
      isLoadingProductDetail.value = false;
    }
  }

  void performClientSideSearch(String query) {
    // ... (Giữ nguyên logic tìm kiếm client-side đã có) ...
    if (allProducts.isEmpty && !isLoadingAllProducts.value) {
    }
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      searchResults.clear();
      isPerformingClientSearch.value = false; 
      return;
    }
    isPerformingClientSearch.value = true;
    final lowerCaseQuery = trimmedQuery.toLowerCase();
    if (isLoadingAllProducts.value) {
        return; 
    }
    final results = allProducts.where((product) {
      final productNameLower = product.name.toLowerCase();
      return productNameLower.contains(lowerCaseQuery);
    }).toList();
    searchResults.assignAll(results);
    isPerformingClientSearch.value = false;
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> fetchAllDiscounts() async {
    // ... (Giữ nguyên logic, đảm bảo parse bằng DiscountModel.fromJson) ...
    try {
      isLoadingDiscounts.value = true; 
      discountList.clear();
      final response = await productRepository.fetchAllDiscounts(); // GET /api/discounts/all

      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic responseData = response.body;
        List<dynamic> discountDataList;

        // API /api/discounts/all trả về trực tiếp mảng các discount object
        if (responseData is List<dynamic>) {
          discountDataList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
            discountList.clear(); // Không có discount
            // Loaders.infoSnackBar(title: 'Thông báo', message: responseData['message']);
            isLoadingDiscounts.value = false;
            return;
        }
        else {
          Loaders.errorSnackBar(title: 'Lỗi dữ liệu', message: 'Định dạng dữ liệu khuyến mãi không đúng.');
          isLoadingDiscounts.value = false;
          return;
        }
        discountList.assignAll(discountDataList.map((data) => DiscountModel.fromJson(data as Map<String, dynamic>)).toList());
      } else {
        Loaders.errorSnackBar(title: 'Lỗi tải khuyến mãi', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải danh sách khuyến mãi.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải khuyến mãi: ${e.toString()}');
    } finally {
      isLoadingDiscounts.value = false; 
    }
  }

  Future<void> fetchReviewsForProduct(String productId) async {
    // ... (Giữ nguyên logic) ...
    try {
      isLoadingReviews.value = true;
      productReviews.clear();
      // GET /api/reviews/product/:productId
      final response = await productRepository.fetchReviewsByProductId(productId);
      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic responseData = response.body;
        List<dynamic> reviewDataList;

        // API /api/reviews/product/:productId trả về trực tiếp mảng các review object
        if (responseData is List<dynamic>) {
          reviewDataList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
            productReviews.clear(); // Không có review
            // Loaders.infoSnackBar(title: 'Thông báo', message: responseData['message']);
            isLoadingReviews.value = false;
            return;
        }
         else {
          isLoadingReviews.value = false;
          // Không báo lỗi lớn nếu chỉ là không có review
          print('Định dạng dữ liệu đánh giá không đúng cho sản phẩm $productId.');
          return;
        }
        productReviews.assignAll(reviewDataList.map((data) => ReviewModel.fromJson(data as Map<String, dynamic>)).toList());
      } else {
         print('Lỗi tải đánh giá cho sản phẩm ${productId}: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('Ngoại lệ khi tải đánh giá cho sản phẩm ${productId}: ${e.toString()}');
    } finally {
      isLoadingReviews.value = false;
    }
  }
  
  Future<void> addProductReview({required String productId, required double rating, required String comment}) async {
    // ... (Giữ nguyên logic) ...
     try {
      isSubmittingReview.value = true;
      FullScreenLoader.openLoadingDialog('Đang gửi đánh giá của bạn...', 'assets/images/animations/loader-animation.json');
      
      Map<String, dynamic> reviewData = {
        'productId': productId, // API POST /api/reviews/ cần productId trong body
        'rating': rating,
        'comment': comment,
      };
      final response = await productRepository.addReview(reviewData);
      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.CREATED || response.statusCode == ApiConstants.SUCCESS) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Đánh giá của bạn đã được gửi thành công!');
        await fetchReviewsForProduct(productId); 
      } else {
        Loaders.errorSnackBar(title: 'Lỗi gửi đánh giá', message: response.body?['message'] ?? response.statusText ?? 'Không thể gửi đánh giá của bạn.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Đã xảy ra lỗi khi gửi đánh giá: ${e.toString()}');
    } finally {
      isSubmittingReview.value = false;
    }
  }

  String getProductStockStatus(ProductModel product) {
    // ... (Giữ nguyên logic) ...
    if (product.quantity > 0) {
      return 'Còn hàng (${product.quantity})';
    } else {
      return 'Hết hàng';
    }
  }
}
