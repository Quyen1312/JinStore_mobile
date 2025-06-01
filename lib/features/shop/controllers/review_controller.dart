// File: lib/features/shop/controllers/review_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/service/review/review_service.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart'; // Import ReviewModel
// Import ProductController để có thể cập nhật rating của sản phẩm sau khi có review mới
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';


class ReviewController extends GetxController {
  static ReviewController get instance => Get.find(); // Thêm instance getter

  final ReviewService _reviewService = Get.find<ReviewService>();
  final productController = ProductController.instance; // Get ProductController instance

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  // Sử dụng RxList<Review>
  final RxList<Review> productReviews = <Review>[].obs;
  final RxList<Review> userReviewsList = <Review>[].obs; // Để lưu review của user

  // Biến theo dõi rating người dùng chọn và comment khi viết review
  final RxDouble currentRating = 0.0.obs;
  final commentController = TextEditingController();

  // Lấy đánh giá cho một sản phẩm cụ thể
  Future<void> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;
      error.value = '';
      productReviews.clear(); // Xóa list cũ trước khi fetch

      final reviewListJson = await _reviewService.getProductReviews(productId);
      productReviews.value = reviewListJson
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: "Không thể tải đánh giá: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy các đánh giá của người dùng hiện tại
  Future<void> fetchUserReviews() async {
    try {
      isLoading.value = true;
      error.value = '';
      userReviewsList.clear();

      final reviewListJson = await _reviewService.getUserReviews();
      userReviewsList.value = reviewListJson
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: "Không thể tải đánh giá của bạn: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Tạo một đánh giá mới
  Future<void> createReview({
    required String productId,
    // rating và comment sẽ lấy từ currentRating.value và commentController.text
  }) async {
    if (currentRating.value == 0.0) {
      Loaders.warningSnackBar(title: 'Chưa chọn sao', message: 'Vui lòng chọn số sao đánh giá.');
      return;
    }
    if (commentController.text.isEmpty) {
      Loaders.warningSnackBar(title: 'Chưa nhập bình luận', message: 'Vui lòng nhập bình luận của bạn.');
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final reviewData = await _reviewService.createReview(
        productId: productId,
        rating: currentRating.value.toInt(),
        comment: commentController.text,
      );
      // final newReview = Review.fromJson(reviewData['data'] as Map<String, dynamic>);
      // productReviews.insert(0, newReview); // Thêm review mới vào đầu danh sách để hiển thị ngay

      // Sau khi tạo review thành công:
      Loaders.successSnackBar(title: 'Thành công', message: 'Đánh giá của bạn đã được gửi.');
      await fetchProductReviews(productId); // Tải lại danh sách review cho sản phẩm
      // Cập nhật lại thông tin rating trung bình và số lượng review của sản phẩm đó
      // Điều này quan trọng nếu ProductModel không tự cập nhật từ server ngay lập tức
      await productController.fetchProductsByCategoryId(productId); // Fetch lại product để cập nhật rating, numReviews

      // Reset form
      resetReviewForm();
      Get.back(); // Đóng dialog/modal sau khi gửi
    } catch (e) {
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: "Không thể gửi đánh giá: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void resetReviewForm() {
      currentRating.value = 0.0;
      commentController.clear();
  }

  // TODO: Implement updateReview and deleteReview methods
  // Future<void> updateReview(String reviewId, {int? rating, String? comment}) async { ... }
  // Future<void> deleteReview(String reviewId) async { ... }

  // Tính toán rating trung bình từ danh sách ReviewModel
  double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  // Helper method để format ngày tháng (ví dụ)
  String formatReviewDate(DateTime date) {
    return HelperFunctions.getFormattedDate(date); // Cần import 'package:intl/intl.dart';
  }
}