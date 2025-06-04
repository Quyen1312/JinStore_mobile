import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/discount_model.dart';
import 'package:flutter_application_jin/service/discount_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

class DiscountController extends GetxController {
  static DiscountController get instance => Get.find();

  final DiscountService _discountService = Get.find<DiscountService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Danh sách tất cả các mã giảm giá (ví dụ: để admin quản lý hoặc user xem tất cả)
  final RxList<Discount> allDiscounts = <Discount>[].obs;

  // Danh sách các mã giảm giá khả dụng cho người dùng hiện tại
  final RxList<Discount> userAvailableDiscounts = <Discount>[].obs;

  // Mã giảm giá đang được chọn để áp dụng cho giỏ hàng (chỉ lưu local, không call API)
  final Rx<Discount?> selectedDiscountForCart = Rx<Discount?>(null);

  // Số tiền giảm giá đã được tính toán cho giỏ hàng (local calculation)
  final RxDouble calculatedDiscountAmountForCart = 0.0.obs;

  // Mã giảm giá đang được chọn để xem chi tiết (ví dụ: trong màn hình admin)
  final Rx<Discount?> selectedDiscountForDetail = Rx<Discount?>(null);

  @override
  void onInit() {
    super.onInit();
    // Tải tất cả các mã giảm giá công khai khi controller khởi tạo
    fetchAllPublicDiscounts();
    // Lắng nghe trạng thái đăng nhập để tải mã giảm giá của người dùng
    ever(_authController.isLoggedIn, _handleAuthChangeForDiscounts);
    if (_authController.isLoggedIn.value) {
      fetchAvailableDiscountsForCurrentUser();
    }
  }

  void _handleAuthChangeForDiscounts(bool isLoggedIn) {
    if (isLoggedIn) {
      fetchAvailableDiscountsForCurrentUser();
    } else {
      userAvailableDiscounts.clear();
      selectedDiscountForCart.value = null;
      calculatedDiscountAmountForCart.value = 0.0;
    }
  }

  /// Lấy tất cả các mã giảm giá (công khai)
  Future<void> fetchAllPublicDiscounts() async {
    try {
      isLoading.value = true;
      error.value = '';
      final discountList = await _discountService.getAllDiscounts();
      allDiscounts.assignAll(discountList);
    } catch (e) {
      print("[DiscountController] fetchAllPublicDiscounts Error: $e");
      error.value = e.toString();
      // Loaders.errorSnackBar(title: 'Lỗi tải mã giảm giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy mã giảm giá bằng ID (công khai) và cập nhật selectedDiscountForDetail
  Future<void> fetchDiscountByIdForDetail(String discountId) async {
    try {
      isLoading.value = true;
      error.value = '';
      selectedDiscountForDetail.value = null; // Reset trước khi fetch
      final discount = await _discountService.getDiscountById(discountId);
      selectedDiscountForDetail.value = discount;
    } catch (e) {
      print("[DiscountController] fetchDiscountByIdForDetail Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Không tìm thấy mã giảm giá.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy các mã giảm giá khả dụng cho người dùng hiện tại
  Future<void> fetchAvailableDiscountsForCurrentUser() async {
    if (!_authController.isLoggedIn.value || _authController.currentUser.value == null) {
      userAvailableDiscounts.clear();
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      final userId = _authController.currentUser.value!.id;
      final discountList = await _discountService.getAvailableDiscountsForUser(userId);
      userAvailableDiscounts.assignAll(discountList);
    } catch (e) {
      print("[DiscountController] fetchAvailableDiscountsForCurrentUser Error: $e");
      error.value = e.toString();
      // Loaders.errorSnackBar(title: 'Lỗi tải mã giảm giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn mã giảm giá cho giỏ hàng (local selection, không call API)
  void selectDiscountForCart(Discount discount, double originalCartAmount) {
    try {
      // Reset trước
      selectedDiscountForCart.value = null;
      calculatedDiscountAmountForCart.value = 0.0;

      // Kiểm tra điều kiện áp dụng
      if (!discount.isValid) {
        Loaders.warningSnackBar(
            title: 'Mã không hợp lệ',
            message: 'Mã giảm giá đã hết hạn hoặc không còn khả dụng.');
        return;
      }

      if (originalCartAmount < discount.minOrderAmount) {
        Loaders.warningSnackBar(
            title: 'Chưa đủ điều kiện',
            message:
                'Đơn hàng của bạn cần đạt tối thiểu ${formatCurrency(discount.minOrderAmount)} để sử dụng mã này.');
        return;
      }

      // Áp dụng discount local
      selectedDiscountForCart.value = discount;
      calculatedDiscountAmountForCart.value = discount.calculateDiscountAmount(originalCartAmount);
      
      Loaders.successSnackBar(
          title: 'Thành công', 
          message: 'Đã chọn mã giảm giá: ${discount.code}');
    } catch (e) {
      print("[DiscountController] selectDiscountForCart Error: $e");
      selectedDiscountForCart.value = null;
      calculatedDiscountAmountForCart.value = 0.0;
      Loaders.errorSnackBar(title: 'Lỗi chọn mã', message: e.toString());
    }
  }

  /// Gỡ bỏ mã giảm giá khỏi giỏ hàng
  void removeSelectedDiscount() {
    selectedDiscountForCart.value = null;
    calculatedDiscountAmountForCart.value = 0.0;
    Loaders.successSnackBar(title: 'Thông báo', message: 'Đã gỡ bỏ mã giảm giá.');
  }

  /// Tính toán lại discount amount khi cart amount thay đổi
  void recalculateDiscountAmount(double newCartAmount) {
    final selectedDiscount = selectedDiscountForCart.value;
    if (selectedDiscount != null) {
      if (newCartAmount >= selectedDiscount.minOrderAmount) {
        calculatedDiscountAmountForCart.value = selectedDiscount.calculateDiscountAmount(newCartAmount);
      } else {
        // Nếu không đủ điều kiện nữa, gỡ bỏ discount
        removeSelectedDiscount();
      }
    }
  }

  // --- Chức năng cho Admin ---

  /// Admin: Tạo mã giảm giá mới
  Future<void> adminCreateDiscount({
    required String code,
    required String type,
    double? fixedValue,
    double? percentageValue,
    required DateTime activationDate,
    required DateTime expirationDate,
    double? minOrderAmount,
    bool? isActive,
    int? quantityLimit,
  }) async {
    // TODO: Thêm kiểm tra quyền Admin ở client nếu cần
    try {
      isLoading.value = true;
      error.value = '';
      final newDiscount = await _discountService.createDiscount(
        code: code,
        type: type,
        value: fixedValue, // Service sẽ dùng 'value' cho fixed
        maxPercent: percentageValue, // Service sẽ dùng 'maxPercent' cho percentage
        activation: activationDate.toIso8601String(),
        expiration: expirationDate.toIso8601String(),
        minOrderAmount: minOrderAmount,
        isActive: isActive,
        quantityLimit: quantityLimit,
      );
      allDiscounts.add(newDiscount); // Cập nhật danh sách local
      Loaders.successSnackBar(title: 'Thành công', message: 'Mã giảm giá đã được tạo.');
    } catch (e) {
      print("[DiscountController] adminCreateDiscount Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tạo mã giảm giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Cập nhật mã giảm giá
  Future<void> adminUpdateDiscount({
    required String id,
    String? code,
    String? type,
    double? fixedValue,
    double? percentageValue,
    DateTime? activationDate,
    DateTime? expirationDate,
    double? minOrderAmount,
    bool? isActive,
    int? quantityLimit,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final updatedDiscount = await _discountService.updateDiscount(
        id: id,
        code: code,
        type: type,
        value: fixedValue,
        maxPercent: percentageValue,
        activation: activationDate?.toIso8601String(),
        expiration: expirationDate?.toIso8601String(),
        minOrderAmount: minOrderAmount,
        isActive: isActive,
        quantityLimit: quantityLimit,
      );
      int index = allDiscounts.indexWhere((d) => d.id == id);
      if (index != -1) {
        allDiscounts[index] = updatedDiscount;
      }
      if(selectedDiscountForDetail.value?.id == id){
        selectedDiscountForDetail.value = updatedDiscount;
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Mã giảm giá đã được cập nhật.');
    } catch (e) {
      print("[DiscountController] adminUpdateDiscount Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi cập nhật mã giảm giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Xóa mã giảm giá
  Future<void> adminDeleteDiscount(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _discountService.deleteDiscount(id);
      allDiscounts.removeWhere((d) => d.id == id);
      if(selectedDiscountForDetail.value?.id == id){
        selectedDiscountForDetail.value = null;
      }
      if(selectedDiscountForCart.value?.id == id){
        removeSelectedDiscount();
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Mã giảm giá đã được xóa.');
    } catch (e) {
      print("[DiscountController] adminDeleteDiscount Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi xóa mã giảm giá', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Admin: Thay đổi trạng thái active của mã giảm giá
  Future<void> adminToggleDiscountStatus(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      final updatedDiscount = await _discountService.toggleDiscountStatus(id);
      int index = allDiscounts.indexWhere((d) => d.id == id);
      if (index != -1) {
        allDiscounts[index] = updatedDiscount;
      }
       if(selectedDiscountForDetail.value?.id == id){
        selectedDiscountForDetail.value = updatedDiscount;
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Trạng thái mã giảm giá đã được thay đổi.');
    } catch (e) {
      print("[DiscountController] adminToggleDiscountStatus Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi thay đổi trạng thái', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper Methods ---
  String formatDiscountValue(Discount discount) {
    // Sử dụng getter discountDisplayValue từ DiscountModel đã được sửa
    if (discount.type.toLowerCase() == 'percentage') {
      return 'Giảm ${discount.discountDisplayValue.toStringAsFixed(0)}%';
    } else {
      return 'Giảm ${formatCurrency(discount.discountDisplayValue)}';
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}