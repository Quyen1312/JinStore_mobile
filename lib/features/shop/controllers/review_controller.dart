import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Để kiểm tra quyền admin
import 'package:flutter_application_jin/features/shop/models/review_model.dart';
import 'package:flutter_application_jin/service/review_service.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart'; // Cho formatDate
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
// Import ProductController nếu cần cập nhật rating sản phẩm sau khi review thay đổi.
// Tuy nhiên, việc này có thể tạo phụ thuộc vòng nếu ProductController cũng gọi ReviewController.
// Cách tốt hơn là ProductController tự fetch lại product khi cần.
// import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  final ReviewService _reviewService = Get.find<ReviewService>();
  final AuthController _authController = Get.find<AuthController>();
  // final ProductController _productController = ProductController.instance; // Cân nhắc nếu cần

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Danh sách các đánh giá cho một sản phẩm cụ thể đang xem
  final RxList<Review> productReviews = <Review>[].obs;
  // Danh sách tất cả đánh giá (cho admin)
  final RxList<Review> allReviewsAdminList = <Review>[].obs;
  // Đánh giá đang được xem chi tiết (ví dụ: bởi admin)
  final Rx<Review?> selectedReviewDetail = Rx<Review?>(null);


  // State cho việc tạo/cập nhật review
  final RxDouble currentRating = 0.0.obs; // Rating người dùng chọn (1.0 đến 5.0)
  final commentController = TextEditingController();

  /// Lấy tất cả đánh giá cho một sản phẩm (Public)
  Future<void> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;
      error.value = '';
      productReviews.clear();
      final reviewList = await _reviewService.getProductReviews(productId);
      productReviews.assignAll(reviewList);
    } catch (e) {
      print("[ReviewController] fetchProductReviews Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải đánh giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Tạo một đánh giá mới cho sản phẩm
  Future<bool> submitNewReview({required String productId}) async {
    if (!_authController.isLoggedIn.value) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập để gửi đánh giá.');
      return false;
    }
    if (currentRating.value < 1.0 || currentRating.value > 5.0) {
      Loaders.warningSnackBar(title: 'Chưa chọn sao', message: 'Vui lòng chọn từ 1 đến 5 sao.');
      return false;
    }
    if (commentController.text.trim().isEmpty) {
      Loaders.warningSnackBar(title: 'Thiếu bình luận', message: 'Vui lòng nhập bình luận của bạn.');
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';
      await _reviewService.createReview(
        productId: productId,
        rating: currentRating.value.toInt(),
        comment: commentController.text.trim(),
      );
      Loaders.successSnackBar(title: 'Thành công', message: 'Đánh giá của bạn đã được gửi.');
      await fetchProductReviews(productId); // Tải lại danh sách review cho sản phẩm
      // TODO: Cân nhắc cập nhật rating trung bình của sản phẩm ở ProductController
      // await _productController.fetchProductDetails(productId); // Ví dụ
      resetReviewForm();
      Get.back(); // Đóng dialog/modal nếu có
      return true;
    } catch (e) {
      print("[ReviewController] submitNewReview Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi gửi đánh giá', message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật một đánh giá hiện có (chỉ chủ sở hữu)
  Future<bool> updateExistingReview({
    required String reviewId,
    required String productIdToRefresh, // Cần để fetch lại reviews cho sản phẩm đó
    // rating và comment sẽ lấy từ currentRating.value và commentController.text
    // khi người dùng chỉnh sửa
  }) async {
     if (!_authController.isLoggedIn.value) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập.');
      return false;
    }
    if (currentRating.value < 1.0 || currentRating.value > 5.0) {
      Loaders.warningSnackBar(title: 'Chưa chọn sao', message: 'Vui lòng chọn từ 1 đến 5 sao.');
      return false;
    }
    if (commentController.text.trim().isEmpty) {
      Loaders.warningSnackBar(title: 'Thiếu bình luận', message: 'Vui lòng nhập bình luận của bạn.');
      return false;
    }
    try {
      isLoading.value = true;
      error.value = '';
      await _reviewService.updateReview(
        reviewId: reviewId,
        rating: currentRating.value.toInt(),
        comment: commentController.text.trim(),
      );
      Loaders.successSnackBar(title: 'Thành công', message: 'Đánh giá của bạn đã được cập nhật.');
      await fetchProductReviews(productIdToRefresh);
      // TODO: Cân nhắc cập nhật rating trung bình của sản phẩm
      resetReviewForm();
      Get.back();
      return true;
    } catch (e) {
      print("[ReviewController] updateExistingReview Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi cập nhật đánh giá', message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  /// Xóa một đánh giá (Admin hoặc chủ sở hữu - phụ thuộc vào backend và quyền của user)
  Future<void> deleteUserReview(String reviewId, String productIdToRefresh) async {
     if (!_authController.isLoggedIn.value) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập.');
      return;
    }
    // Logic kiểm tra quyền (ví dụ: review.userId == _authController.currentUser.value?.id || _authController.currentUser.value?.isAdmin == true)
    // nên được thực hiện ở UI trước khi gọi hàm này, hoặc dựa vào lỗi từ backend.
    try {
      isLoading.value = true;
      error.value = '';
      await _reviewService.deleteReview(reviewId);
      Loaders.successSnackBar(title: 'Thành công', message: 'Đánh giá đã được xóa.');
      await fetchProductReviews(productIdToRefresh); // Tải lại danh sách
      // TODO: Cân nhắc cập nhật rating trung bình của sản phẩm
    } catch (e) {
      print("[ReviewController] deleteUserReview Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi xóa đánh giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// Reset form nhập review
  void resetReviewForm() {
    currentRating.value = 0.0;
    commentController.clear();
  }

  // --- Chức năng cho Admin ---

  /// Admin: Lấy tất cả đánh giá trong hệ thống
  Future<void> fetchAllReviewsForAdmin() async {
    // TODO: Kiểm tra quyền admin
    // if(!_authController.currentUser.value?.isAdmin == true) {
    //   Loaders.errorSnackBar(title: 'Lỗi', message: 'Bạn không có quyền truy cập.');
    //   return;
    // }
    try {
      isLoading.value = true;
      error.value = '';
      allReviewsAdminList.clear();
      final reviewList = await _reviewService.getAllReviewsAdmin();
      allReviewsAdminList.assignAll(reviewList);
    } catch (e) {
      print("[ReviewController] fetchAllReviewsForAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải tất cả đánh giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Lấy chi tiết một đánh giá bằng ID
  Future<void> fetchReviewDetailsForAdmin(String reviewId) async {
    // TODO: Kiểm tra quyền admin
    try {
      isLoading.value = true;
      error.value = '';
      selectedReviewDetail.value = null;
      final review = await _reviewService.getReviewById(reviewId);
      selectedReviewDetail.value = review;
    } catch (e) {
      print("[ReviewController] fetchReviewDetailsForAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải chi tiết đánh giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Thay đổi trạng thái publish/report của một đánh giá
  Future<void> toggleReviewPublishStatusAdmin(String reviewId) async {
    // TODO: Kiểm tra quyền admin
    try {
      isLoading.value = true;
      error.value = '';
      final updatedReview = await _reviewService.togglePublishStatusAdmin(reviewId);
      // Cập nhật trong danh sách allReviewsAdminList
      int index = allReviewsAdminList.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        allReviewsAdminList[index] = updatedReview;
      }
      // Cập nhật trong selectedReviewDetail nếu đang xem
      if (selectedReviewDetail.value?.id == reviewId) {
        selectedReviewDetail.value = updatedReview;
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Trạng thái đánh giá đã được thay đổi.');
    } catch (e) {
      print("[ReviewController] toggleReviewPublishStatusAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi thay đổi trạng thái', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper Methods ---
  double calculateAverageRatingFromList(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  String formatReviewDate(DateTime date) {
    return HelperFunctions.getFormattedDate(date);
  }
}
