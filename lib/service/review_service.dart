import 'dart:convert'; // Cho jsonEncode
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart'; // Đảm bảo bạn đã có Review model đã được cập nhật
import 'package:get/get.dart';

class ReviewService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://localhost:1000/api'; // Base URL chung

    // Interceptor để tự động thêm token vào headers
    httpClient.addRequestModifier<void>((request) async {
      try {
        final authController = Get.find<AuthController>();
        
        // Lấy token hợp lệ (tự động refresh nếu cần)
        final token = await authController.getValidToken();
        
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        print("ReviewService Request: ${request.method} ${request.url}");
        print("ReviewService Headers: ${request.headers}");
        // Chỉ thêm token nếu request không phải là GET /reviews/product/:id (vì route này public)
        // Tuy nhiên, việc luôn thêm token nếu có cũng không gây hại cho các route public.
      } catch (e) {
        print('Lỗi khi thêm token vào ReviewService request: $e');
        // Không throw error ở đây để request vẫn tiếp tục
      }
      
      return request;
    });

    // Interceptor để xử lý response và lỗi token
    httpClient.addResponseModifier((request, response) async {
      print('ReviewService Response Status: ${response.statusCode}');
      
      // Xử lý lỗi 401 (Unauthorized)
      if (response.statusCode == 401) {
        try {
          final authController = Get.find<AuthController>();
          
          // Thử refresh token
          final refreshSuccess = await authController.tryRefreshToken();
          
          if (!refreshSuccess) {
            // Nếu refresh thất bại, logout user
            print('Token hết hạn và không thể refresh, đang logout...');
            await authController.logout();
          }
        } catch (e) {
          print('Lỗi khi xử lý 401 response trong ReviewService: $e');
        }
      }
      
      return response;
    });

    super.onInit();
  }

  // Helper để xử lý lỗi chung từ API
  void _handleResponseError(Response response, String defaultMessage) {
    print('Error Response Status (ReviewService): ${response.statusCode}');
    print('Error Response Body (ReviewService): ${response.bodyString}');
    if (response.body != null && response.body is Map<String, dynamic>) {
      final errorData = response.body as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? defaultMessage;
      throw message;
    }
    throw defaultMessage;
  }

  // Helper để kiểm tra authentication cho các endpoint cần token
  Future<void> _ensureAuthenticated() async {
    try {
      final authController = Get.find<AuthController>();
      
      if (!authController.isLoggedIn.value) {
        throw 'Bạn cần đăng nhập để thực hiện chức năng này.';
      }
      
      final token = await authController.getValidToken();
      if (token == null) {
        throw 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      }
    } catch (e) {
      print('Lỗi authentication check trong ReviewService: $e');
      throw e is String ? e : 'Lỗi xác thực: ${e.toString()}';
    }
  }

  // Helper để kiểm tra quyền admin
  Future<void> _ensureAdminRights() async {
    await _ensureAuthenticated();
    
    final authController = Get.find<AuthController>();
    if (!authController.isAdmin) {
      throw 'Bạn không có quyền admin để thực hiện chức năng này.';
    }
  }

  /// Lấy tất cả các đánh giá (Admin only)
  /// Backend: GET /reviews
  Future<List<Review>> getAllReviewsAdmin() async {
    try {
      await _ensureAdminRights();
      
      final response = await get('/reviews'); // Endpoint là /reviews

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> reviewsJson = responseData['data'] as List<dynamic>;
          return reviewsJson
              .map((json) => Review.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        _handleResponseError(response, 'Lỗi khi lấy danh sách tất cả đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể lấy danh sách tất cả đánh giá.');
      return []; // Sẽ không bao giờ đạt đến đây nếu throw ở trên
    } catch (e) {
      print('Lỗi trong ReviewService.getAllReviewsAdmin: $e');
      throw e is String ? e : 'Lỗi khi lấy danh sách tất cả đánh giá: ${e.toString()}';
    }
  }

  /// Lấy một đánh giá cụ thể bằng ID (User - verifyToken)
  /// Backend: GET /reviews/:id
  Future<Review> getReviewById(String reviewId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await get('/reviews/$reviewId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return Review.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Định dạng dữ liệu đánh giá không đúng.');
      }
      _handleResponseError(response, 'Không thể lấy thông tin đánh giá.');
      throw 'Lỗi không xác định khi lấy thông tin đánh giá'; // Fallback
    } catch (e) {
      print('Lỗi trong ReviewService.getReviewById: $e');
      throw e is String ? e : 'Lỗi khi lấy thông tin đánh giá: ${e.toString()}';
    }
  }

  /// Tạo một đánh giá mới (User - verifyToken)
  /// Backend: POST /reviews/create
  /// Body: productId, rating, comment
  Future<Review> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _ensureAuthenticated();
      
      // Validation client-side
      if (rating < 1 || rating > 5) {
        throw 'Đánh giá phải từ 1 đến 5 sao.';
      }
      
      if (comment.trim().isEmpty) {
        throw 'Vui lòng nhập nội dung đánh giá.';
      }
      
      if (comment.length > 500) {
        throw 'Nội dung đánh giá không được quá 500 ký tự.';
      }
      
      final body = {
        'productId': productId,
        'rating': rating,
        'comment': comment.trim(),
      };
      
      print("ReviewService createReview Body: ${jsonEncode(body)}");
      final response = await post('/reviews/create', body);

      if (response.statusCode == 201) { // Backend trả về 201 khi tạo thành công
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return Review.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Lỗi khi tạo đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể tạo đánh giá.');
      throw 'Lỗi không xác định khi tạo đánh giá'; // Fallback
    } catch (e) {
      print('Lỗi trong ReviewService.createReview: $e');
      throw e is String ? e : 'Lỗi khi tạo đánh giá: ${e.toString()}';
    }
  }

  /// Lấy tất cả đánh giá cho một sản phẩm (Public)
  /// Backend: GET /reviews/product/:id
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      // Route này public, không nhất thiết cần token, nhưng interceptor sẽ tự thêm nếu có.
      final response = await get('/reviews/product/$productId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> reviewsJson = responseData['data'] as List<dynamic>;
          return reviewsJson
              .map((json) => Review.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        _handleResponseError(response, 'Lỗi khi lấy đánh giá sản phẩm từ server.');
      }
      _handleResponseError(response, 'Không thể lấy đánh giá sản phẩm.');
      return [];
    } catch (e) {
      print('Lỗi trong ReviewService.getProductReviews: $e');
      throw e is String ? e : 'Lỗi khi lấy đánh giá sản phẩm: ${e.toString()}';
    }
  }

  /// Xóa một đánh giá (Admin hoặc chủ sở hữu review)
  /// Backend: DELETE /reviews/delete/:reviewId
  /// Lưu ý: Route backend hiện tại là verifyTokenAndAdmin, controller có logic cho cả user.
  /// Nếu muốn user tự xóa, route backend cần đổi thành verifyToken.
  Future<void> deleteReview(String reviewId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await delete('/reviews/delete/$reviewId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          return; // Thành công
        }
        _handleResponseError(response, 'Lỗi không xác định khi xóa đánh giá.');
      }
      _handleResponseError(response, 'Lỗi khi xóa đánh giá.');
    } catch (e) {
      print('Lỗi trong ReviewService.deleteReview: $e');
      throw e is String ? e : 'Lỗi khi xóa đánh giá: ${e.toString()}';
    }
  }

  /// Cập nhật một đánh giá (User - verifyToken, chỉ chủ sở hữu)
  /// Backend: PATCH /reviews/update/:reviewId
  /// Body: rating, comment
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _ensureAuthenticated();
      
      // Validation client-side
      if (rating < 1 || rating > 5) {
        throw 'Đánh giá phải từ 1 đến 5 sao.';
      }
      
      if (comment.trim().isEmpty) {
        throw 'Vui lòng nhập nội dung đánh giá.';
      }
      
      if (comment.length > 500) {
        throw 'Nội dung đánh giá không được quá 500 ký tự.';
      }
      
      final body = {
        'rating': rating,
        'comment': comment.trim(),
      };
      
      print("ReviewService updateReview Body: ${jsonEncode(body)} for ReviewID: $reviewId");
      final response = await patch('/reviews/update/$reviewId', body);

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return Review.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Lỗi khi cập nhật đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể cập nhật đánh giá.');
      throw 'Lỗi không xác định khi cập nhật đánh giá'; // Fallback
    } catch (e) {
      print('Lỗi trong ReviewService.updateReview: $e');
      throw e is String ? e : 'Lỗi khi cập nhật đánh giá: ${e.toString()}';
    }
  }

  /// Thay đổi trạng thái publish/report của đánh giá (Admin only)
  /// Backend: PATCH /reviews/publish/:reviewId
  Future<Review> togglePublishStatusAdmin(String reviewId) async {
    try {
      await _ensureAdminRights();
      
      // Route này không cần body theo controller backend (chỉ toggle isReport)
      final response = await patch('/reviews/publish/$reviewId', {});

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return Review.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        _handleResponseError(response, 'Lỗi khi thay đổi trạng thái đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể thay đổi trạng thái đánh giá.');
      throw 'Lỗi không xác định khi thay đổi trạng thái đánh giá'; // Fallback
    } catch (e) {
      print('Lỗi trong ReviewService.togglePublishStatusAdmin: $e');
      throw e is String ? e : 'Lỗi khi thay đổi trạng thái đánh giá: ${e.toString()}';
    }
  }

  /// Report đánh giá (User)
  /// Backend: POST /reviews/report/:reviewId
  Future<void> reportReview(String reviewId, {String? reason}) async {
    try {
      await _ensureAuthenticated();
      
      final body = {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };
      
      final response = await post('/reviews/report/$reviewId', body);

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          return; // Thành công
        }
        _handleResponseError(response, 'Lỗi không xác định khi báo cáo đánh giá.');
      }
      _handleResponseError(response, 'Lỗi khi báo cáo đánh giá.');
    } catch (e) {
      print('Lỗi trong ReviewService.reportReview: $e');
      throw e is String ? e : 'Lỗi khi báo cáo đánh giá: ${e.toString()}';
    }
  }

  /// Lấy đánh giá của người dùng hiện tại
  /// Backend: GET /reviews/my-reviews
  Future<List<Review>> getMyReviews() async {
    try {
      await _ensureAuthenticated();
      
      final response = await get('/reviews/my-reviews');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> reviewsJson = responseData['data'] as List<dynamic>;
          return reviewsJson
              .map((json) => Review.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        _handleResponseError(response, 'Lỗi khi lấy đánh giá của bạn từ server.');
      }
      _handleResponseError(response, 'Không thể lấy đánh giá của bạn.');
      return [];
    } catch (e) {
      print('Lỗi trong ReviewService.getMyReviews: $e');
      throw e is String ? e : 'Lỗi khi lấy đánh giá của bạn: ${e.toString()}';
    }
  }

  /// Kiểm tra người dùng đã đánh giá sản phẩm chưa
  /// Backend: GET /reviews/check/:productId
  Future<bool> hasUserReviewedProduct(String productId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await get('/reviews/check/$productId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          return responseData['hasReviewed'] == true;
        }
      }
      return false;
    } catch (e) {
      print('Lỗi khi kiểm tra đánh giá sản phẩm: $e');
      return false;
    }
  }

  /// Lấy thống kê đánh giá của sản phẩm
  /// Backend: GET /reviews/stats/:productId
  Future<Map<String, dynamic>> getProductReviewStats(String productId) async {
    try {
      final response = await get('/reviews/stats/$productId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['stats'] != null) {
          return responseData['stats'] as Map<String, dynamic>;
        }
        _handleResponseError(response, 'Lỗi khi lấy thống kê đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể lấy thống kê đánh giá.');
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': {
          '5': 0,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        }
      };
    } catch (e) {
      print('Lỗi trong ReviewService.getProductReviewStats: $e');
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': {
          '5': 0,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        }
      };
    }
  }

  /// Like một đánh giá
  /// Backend: POST /reviews/like/:reviewId
  Future<void> likeReview(String reviewId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await post('/reviews/like/$reviewId', {});

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          return; // Thành công
        }
        _handleResponseError(response, 'Lỗi không xác định khi like đánh giá.');
      }
      _handleResponseError(response, 'Lỗi khi like đánh giá.');
    } catch (e) {
      print('Lỗi trong ReviewService.likeReview: $e');
      throw e is String ? e : 'Lỗi khi like đánh giá: ${e.toString()}';
    }
  }

  /// Unlike một đánh giá
  /// Backend: DELETE /reviews/like/:reviewId
  Future<void> unlikeReview(String reviewId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await delete('/reviews/like/$reviewId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          return; // Thành công
        }
        _handleResponseError(response, 'Lỗi không xác định khi unlike đánh giá.');
      }
      _handleResponseError(response, 'Lỗi khi unlike đánh giá.');
    } catch (e) {
      print('Lỗi trong ReviewService.unlikeReview: $e');
      throw e is String ? e : 'Lỗi khi unlike đánh giá: ${e.toString()}';
    }
  }

  /// Lấy đánh giá có phân trang và filter
  /// Backend: GET /reviews/product/:productId/paginated
  Future<Map<String, dynamic>> getProductReviewsPaginated({
    required String productId,
    int page = 1,
    int limit = 10,
    int? rating, // Filter theo rating cụ thể
    String? sortBy = 'createdAt', // Sort by: createdAt, rating, helpful
    String? sortOrder = 'desc', // asc hoặc desc
  }) async {
    try {
      String endpoint = '/reviews/product/$productId/paginated?page=$page&limit=$limit';
      
      if (rating != null && rating >= 1 && rating <= 5) {
        endpoint += '&rating=$rating';
      }
      
      if (sortBy != null) {
        endpoint += '&sortBy=$sortBy';
      }
      
      if (sortOrder != null) {
        endpoint += '&sortOrder=$sortOrder';
      }
      
      final response = await get(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final reviews = (responseData['data'] as List)
              .map((json) => Review.fromJson(json as Map<String, dynamic>))
              .toList();
          
          return {
            'reviews': reviews,
            'totalCount': responseData['totalCount'] ?? 0,
            'currentPage': responseData['currentPage'] ?? page,
            'totalPages': responseData['totalPages'] ?? 0,
            'hasNextPage': responseData['hasNextPage'] ?? false,
            'hasPreviousPage': responseData['hasPreviousPage'] ?? false,
          };
        }
        _handleResponseError(response, 'Lỗi khi lấy danh sách đánh giá từ server.');
      }
      _handleResponseError(response, 'Không thể lấy danh sách đánh giá.');
      return {'reviews': <Review>[], 'totalCount': 0};
    } catch (e) {
      print('Lỗi trong ReviewService.getProductReviewsPaginated: $e');
      return {'reviews': <Review>[], 'totalCount': 0};
    }
  }
}