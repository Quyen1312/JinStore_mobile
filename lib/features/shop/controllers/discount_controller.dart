// File: lib/features/shop/controllers/discount_controller.dart
import 'package:get/get.dart';
import 'package:flutter_application_jin/service/discount/discount_service.dart';
import 'package:flutter_application_jin/features/shop/models/discount_model.dart'; // Import DiscountModel
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_application_jin/utils/popups/loaders.dart'; // For JLoaders

class DiscountController extends GetxController {
  final DiscountService _discountService = Get.find<DiscountService>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  // Sử dụng RxList<Discount>
  final RxList<Discount> discounts = <Discount>[].obs;
  // Sử dụng Rx<Discount?>
  final Rx<Discount?> currentDiscount = Rx<Discount?>(null);
  final Rx<Discount?> appliedDiscount = Rx<Discount?>(null);

  final RxDouble calculatedDiscountAmount = 0.0.obs; // Thêm biến này để lưu số tiền giảm giá

  @override
  void onInit() {
    super.onInit();
    fetchActiveDiscounts();
  }

  Future<void> fetchActiveDiscounts() async {
    try {
      isLoading.value = true;
      error.value = '';

      final discountListJson = await _discountService.getActiveDiscounts();
      // Chuyển đổi danh sách JSON sang List<Discount>
      discounts.value = discountListJson
          .map((item) => Discount.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDiscountByCode(String code) async {
    try {
      isLoading.value = true;
      error.value = '';

      final discountJson = await _discountService.getDiscountByCode(code);
      // Chuyển đổi JSON sang Discount
      currentDiscount.value = Discount.fromJson(discountJson);
    } catch (e) {
      error.value = e.toString();
      currentDiscount.value = null; // Đặt lại nếu có lỗi
      Loaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyDiscountToCart(String code, double originalAmount) async {
    try {
      isLoading.value = true;
      error.value = '';
      // Gọi service để lấy thông tin coupon và kiểm tra tính hợp lệ từ backend nếu cần,
      // Hoặc lấy từ currentDiscount nếu đã getDiscountByCode trước đó.
      // Ở đây, giả sử getDiscountByCode đã được gọi hoặc chúng ta tìm trong list.
      // Tốt nhất là gọi API để xác thực coupon với giỏ hàng hiện tại.

      final discountToApply = await _discountService.getDiscountByCode(code); // Lấy thông tin coupon từ service
      final discount = Discount.fromJson(discountToApply);

      if (discount.isValid) {
        if (originalAmount < discount.minOrderAmount) {
          Loaders.warningSnackBar(title: 'Thông báo', message: 'Đơn hàng chưa đạt giá trị tối thiểu ${formatCurrency(discount.minOrderAmount)} để áp dụng mã này.');
          appliedDiscount.value = null; // Xóa mã nếu không hợp lệ
          calculatedDiscountAmount.value = 0.0;
          return;
        }
        appliedDiscount.value = discount;
        calculateDiscountForCart(originalAmount); // Tính toán lại tiền giảm giá
        Loaders.successSnackBar(title: 'Thành công', message: 'Áp dụng mã giảm giá thành công!');
      } else {
        appliedDiscount.value = null;
        calculatedDiscountAmount.value = 0.0;
        Loaders.errorSnackBar(title: 'Thất bại', message: 'Mã giảm giá không hợp lệ hoặc đã hết hạn.');
      }
    } catch (e) {
      appliedDiscount.value = null;
      calculatedDiscountAmount.value = 0.0;
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void removeDiscountFromCart() {
    appliedDiscount.value = null;
    calculatedDiscountAmount.value = 0.0;
    Loaders.warningSnackBar(title: 'Thông báo', message: 'Đã xóa mã giảm giá.');
  }

  // Tính toán số tiền giảm giá thực tế cho giỏ hàng
  void calculateDiscountForCart(double originalAmount) {
    if (appliedDiscount.value == null) {
      calculatedDiscountAmount.value = 0;
      return;
    }
    final discount = appliedDiscount.value!;
    if (originalAmount < discount.minOrderAmount) {
        calculatedDiscountAmount.value = 0; // Không đủ điều kiện
        // Có thể hiển thị thông báo ở đây nếu muốn
        return;
    }

    double amountToDiscount = 0;
    if (discount.type.toLowerCase() == 'percentage') {
      amountToDiscount = (originalAmount * discount.value / 100);
    } else { // fixed_amount
      amountToDiscount = discount.value;
    }
    // Đảm bảo số tiền giảm không vượt quá tổng tiền
    calculatedDiscountAmount.value = (amountToDiscount > originalAmount) ? originalAmount : amountToDiscount;
  }


  // Helper method to format discount value for display
  String formatDiscountValue(Discount discount) {
    if (discount.type.toLowerCase() == 'percentage') {
      return 'Giảm ${discount.value.toStringAsFixed(0)}%';
    } else { // fixed_amount
      return 'Giảm ${formatCurrency(discount.value)}';
    }
  }

  // Helper method to format currency
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  // Helper method to format date
  String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  // CÁC PHƯƠNG THỨC CRUD (ADMIN) GIỮ NGUYÊN NHƯ TRƯỚC
  // Future<void> createDiscount(Map<String, dynamic> discountData) async { ... }
  // Future<void> updateDiscount(String id, Map<String, dynamic> discountData) async { ... }
  // Future<void> deleteDiscount(String id) async { ... }
}