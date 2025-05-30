import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxService {
  final ApiClient apiClient;

  ProductRepository({required this.apiClient});

  Future<Response> fetchAllProducts() async {
    try {
      final response = await apiClient.getData(ApiConstants.PRODUCTS_GET_ALL);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy danh sách sản phẩm: ${e.toString()}');
    }
  }

  Future<Response> fetchProductsByCategoryId(String categoryId) async {
    try {
      // API: GET /api/products/category/:idCategory
      final response = await apiClient.getData('${ApiConstants.PRODUCTS_BY_CATEGORY_BASE}/$categoryId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy sản phẩm theo danh mục: ${e.toString()}');
    }
  }
  
  Future<Response> fetchProductById(String productId) async {
    try {
      // API: GET /api/products/:id
      final response = await apiClient.getData('${ApiConstants.PRODUCTS_BASE}/$productId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy chi tiết sản phẩm: ${e.toString()}');
    }
  }

  // PHƯƠNG THỨC searchProducts ĐÃ BỎ VÌ KHÔNG CÓ API TÌM KIẾM RIÊNG

  // --- Discount Methods ---
  Future<Response> fetchAllDiscounts() async { 
    try {
      final response = await apiClient.getData(ApiConstants.DISCOUNTS_GET_ALL); 
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy danh sách khuyến mãi: ${e.toString()}');
    }
  }

  Future<Response> fetchDiscountById(String discountId) async { 
    try {
      final response = await apiClient.getData('${ApiConstants.DISCOUNTS_BASE}/$discountId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy chi tiết khuyến mãi: ${e.toString()}');
    }
  }

  // --- Review Methods ---
  Future<Response> fetchReviewsByProductId(String productId) async {
    try {
      final response = await apiClient.getData('${ApiConstants.REVIEWS_BY_PRODUCT_ID_BASE}/$productId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy đánh giá sản phẩm: ${e.toString()}');
    }
  }
  
  Future<Response> fetchCurrentUserReviews() async {
    try {
      final response = await apiClient.getData(ApiConstants.REVIEWS_GET_CURRENT_USER);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy đánh giá của bạn: ${e.toString()}');
    }
  }

  Future<Response> addReview(Map<String, dynamic> reviewData) async {
    try {
      final response = await apiClient.postData(ApiConstants.REVIEWS_CREATE, reviewData);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi thêm đánh giá: ${e.toString()}');
    }
  }

  Future<Response> updateReview(String reviewId, Map<String, dynamic> reviewData) async {
    try {
      final response = await apiClient.patchData('${ApiConstants.REVIEWS_UPDATE_BASE}/$reviewId', reviewData);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi cập nhật đánh giá: ${e.toString()}');
    }
  }

  Future<Response> deleteReview(String reviewId) async {
    try {
      final response = await apiClient.deleteData('${ApiConstants.REVIEWS_DELETE_BASE}/$reviewId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi xóa đánh giá: ${e.toString()}');
    }
  }
}
