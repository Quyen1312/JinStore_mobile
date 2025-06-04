import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Cần cho hàm addItemToCart
// Cần import DisplayCartItem từ cart_service.dart hoặc file model riêng nếu bạn đã tách ra
import 'package:flutter_application_jin/service/cart_service.dart' show DisplayCartItem;
import 'package:flutter_application_jin/service/cart_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For currency formatting

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final CartService _cartService = Get.find<CartService>();
  // Khởi tạo AuthController ngay khi CartController được tạo
  // Điều này giả định AuthController đã được `Get.put()` ở đâu đó trước đó (ví dụ trong `main.dart` hoặc `DependencyInjection`)
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Danh sách các item trong giỏ hàng đã được populate thông tin để hiển thị
  final RxList<DisplayCartItem> displayCartItems = <DisplayCartItem>[].obs;

  // Tổng tiền của giỏ hàng (chỉ tính items được chọn)
  final RxDouble cartTotalAmount = 0.0.obs;

  // Tổng số lượng các sản phẩm trong giỏ hàng (tính theo từng đơn vị sản phẩm)
  final RxInt cartItemsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe thay đổi trạng thái đăng nhập từ AuthController
    ever(_authController.isLoggedIn, _handleAuthChange);
    // Gọi lần đầu nếu đã đăng nhập (ví dụ khi app khởi động và user đã có session)
    if (_authController.isLoggedIn.value) {
      fetchCart();
    }
  }

  void _handleAuthChange(bool isLoggedIn) {
    if (isLoggedIn) {
      fetchCart(); // Tải giỏ hàng khi người dùng đăng nhập
    } else {
      // Xóa giỏ hàng hiển thị khi người dùng đăng xuất
      displayCartItems.clear();
      _calculateTotalAndCount(); // Cập nhật tổng tiền và số lượng về 0
    }
  }

  /// Lấy giỏ hàng từ server và cập nhật UI
  Future<void> fetchCart() async {
    // Chỉ fetch nếu đã đăng nhập
    if (!_authController.isLoggedIn.value) {
      displayCartItems.clear();
      _calculateTotalAndCount();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      final cartData = await _cartService.getCart(); // CartService trả về List<DisplayCartItem>
      displayCartItems.assignAll(cartData);
      _calculateTotalAndCount(); // Tính toán lại tổng tiền và số lượng
    } catch (e) {
      print('[CartController] Error fetching cart: $e');
      error.value = 'Không thể tải giỏ hàng: ${e.toString()}';
      displayCartItems.clear(); // Xóa giỏ hàng nếu có lỗi
      _calculateTotalAndCount();
      // Không hiển thị snackbar lỗi ở đây, để UI tự quyết định cách hiển thị lỗi (ví dụ: widget báo lỗi)
      // Loaders.errorSnackBar(title: 'Lỗi giỏ hàng', message: error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addItemToCart(ProductModel product, {int quantity = 1}) async {
    if (!_authController.isLoggedIn.value) {
      Loaders.warningSnackBar(
          title: 'Chưa đăng nhập',
          message: 'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.');
      // Cân nhắc điều hướng đến màn hình đăng nhập
      // Get.to(() => LoginScreen());
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      // CartService.addToCart trả về CartModel (trạng thái DB), không trực tiếp dùng
      // Thay vào đó, fetch lại toàn bộ giỏ hàng để cập nhật UI
      await _cartService.addToCart(
        productId: product.id,
        quantity: quantity,
      );
      await fetchCart(); // Tải lại giỏ hàng để cập nhật displayCartItems
      Loaders.successSnackBar(
          title: 'Thành công!',
          message: 'Đã thêm ${product.name} vào giỏ hàng.');
    } catch (e) {
      print('[CartController] Error adding item to cart: $e');
      error.value = 'Không thể thêm vào giỏ hàng: ${e.toString()}';
      Loaders.errorSnackBar(title: 'Lỗi thêm vào giỏ hàng', message: error.value);
      if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        _authController.logout();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    if (!_authController.isLoggedIn.value) {
      Loaders.warningSnackBar(title: 'Chưa đăng nhập', message: 'Vui lòng đăng nhập.');
      return;
    }
    // Nếu số lượng mới < 1, coi như xóa sản phẩm
    if (newQuantity < 1) {
      await removeItemFromCart(productId);
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      await _cartService.updateCartItem(
        productId: productId,
        quantity: newQuantity,
      );
      await fetchCart(); // Tải lại giỏ hàng để cập nhật displayCartItems
      Loaders.successSnackBar(title: 'Thành công', message: 'Giỏ hàng đã được cập nhật.');
    } catch (e) {
      print('[CartController] Error updating cart item: $e');
      error.value = 'Không thể cập nhật giỏ hàng: ${e.toString()}';
      Loaders.errorSnackBar(title: 'Lỗi cập nhật giỏ hàng', message: error.value);
      if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        _authController.logout();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeItemFromCart(String productId) async {
    if (!_authController.isLoggedIn.value) {
      Loaders.warningSnackBar(title: 'Chưa đăng nhập', message: 'Vui lòng đăng nhập.');
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      await _cartService.removeCartItem(productId);
      await fetchCart(); // Tải lại giỏ hàng để cập nhật displayCartItems
      Loaders.successSnackBar(
          title: 'Đã xóa', message: 'Sản phẩm đã được xóa khỏi giỏ hàng.');
    } catch (e) {
      print('[CartController] Error removing cart item: $e');
      error.value = 'Không thể xóa sản phẩm: ${e.toString()}';
      Loaders.errorSnackBar(title: 'Lỗi xóa sản phẩm', message: error.value);
      if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        _authController.logout();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa toàn bộ giỏ hàng của người dùng hiện tại
  Future<void> clearUserCart() async {
    if (!_authController.isLoggedIn.value) {
      Loaders.warningSnackBar(title: 'Chưa đăng nhập', message: 'Vui lòng đăng nhập.');
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      await _cartService.clearCart();
      await fetchCart(); // Tải lại giỏ hàng, kết quả sẽ là giỏ hàng rỗng
      Loaders.successSnackBar(
          title: 'Đã xóa', message: 'Giỏ hàng đã được làm trống.');
    } catch (e) {
      print('[CartController] Error clearing cart: $e');
      error.value = 'Không thể xóa giỏ hàng: ${e.toString()}';
      Loaders.errorSnackBar(title: 'Lỗi xóa giỏ hàng', message: error.value);
      if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        _authController.logout();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============= CHECKBOX SELECTION METHODS =============

  /// Toggle trạng thái chọn của một sản phẩm
  void toggleItemSelection(String productId) {
    final index = displayCartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      displayCartItems[index].isSelected = !displayCartItems[index].isSelected;
      displayCartItems.refresh(); // Trigger UI update
      _calculateTotalAndCount(); // Tính lại tổng tiền chỉ cho items được chọn
    }
  }

  /// Toggle chọn tất cả sản phẩm
  void toggleSelectAll() {
    final bool shouldSelectAll = !displayCartItems.every((item) => item.isSelected);
    for (var item in displayCartItems) {
      item.isSelected = shouldSelectAll;
    }
    displayCartItems.refresh();
    _calculateTotalAndCount();
  }

  /// Chọn tất cả sản phẩm
  void selectAllItems() {
    for (var item in displayCartItems) {
      item.isSelected = true;
    }
    displayCartItems.refresh();
    _calculateTotalAndCount();
  }

  /// Bỏ chọn tất cả sản phẩm
  void deselectAllItems() {
    for (var item in displayCartItems) {
      item.isSelected = false;
    }
    displayCartItems.refresh();
    _calculateTotalAndCount();
  }

  // ============= CALCULATION METHODS =============

  /// Tính toán tổng tiền và tổng số lượng item từ displayCartItems (chỉ items được chọn)
  void _calculateTotalAndCount() {
    if (displayCartItems.isEmpty) {
      cartTotalAmount.value = 0.0;
      cartItemsCount.value = 0;
      return;
    }

    double sum = 0;
    int totalQuantity = 0;
    for (var item in displayCartItems) {
      if (item.isSelected) { // Chỉ tính items được chọn
        // DisplayCartItem đã có totalDiscountPrice là giá cuối cùng của item * quantity của nó
        sum += item.totalDiscountPrice;
        totalQuantity += item.quantity;
      }
    }
    cartTotalAmount.value = sum;
    cartItemsCount.value = totalQuantity; // Tổng số lượng các sản phẩm được chọn
  }

  // ============= GETTER METHODS =============

  /// Lấy danh sách sản phẩm được chọn
  List<DisplayCartItem> get selectedItems => 
      displayCartItems.where((item) => item.isSelected).toList();

  /// Lấy số lượng sản phẩm được chọn
  int get selectedItemsCount => selectedItems.length;

  /// Kiểm tra có sản phẩm nào được chọn không
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  /// Kiểm tra tất cả sản phẩm có được chọn không
  bool get isAllSelected => displayCartItems.isNotEmpty && displayCartItems.every((item) => item.isSelected);

  /// Kiểm tra một số sản phẩm được chọn (để hiển thị indeterminate state cho checkbox chọn tất cả)
  bool get isSomeSelected => selectedItems.isNotEmpty && !isAllSelected;

  /// Tính tổng tiền gốc của items được chọn (trước khi giảm giá)
  double get selectedItemsOriginalTotal {
    return selectedItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Tính tổng tiền tiết kiệm được từ items được chọn
  double get selectedItemsSavings {
    return selectedItemsOriginalTotal - cartTotalAmount.value;
  }

  // ============= UTILITY METHODS =============

  /// Kiểm tra sản phẩm có trong giỏ hàng hiển thị không
  bool isProductInCart(String productId) {
    return displayCartItems.any((item) => item.productId == productId);
  }

  /// Lấy số lượng của một sản phẩm trong giỏ hàng hiển thị
  int getProductQuantityInDisplayCart(String productId) {
    final item = displayCartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  /// Lấy tổng số loại sản phẩm khác nhau trong giỏ hàng
  int get distinctItemCount => displayCartItems.length;

  /// Kiểm tra sản phẩm có được chọn không
  bool isProductSelected(String productId) {
    final item = displayCartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.isSelected ?? false;
  }

  // ============= FORMATTING METHODS =============

  /// Format tiền tệ theo định dạng Việt Nam
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format số với dấu phẩy phân cách hàng nghìn
  String formatNumber(double number) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(number);
  }

  /// Lấy chuỗi hiển thị tổng tiền đã format
  String get formattedCartTotal => formatCurrency(cartTotalAmount.value);

  /// Lấy chuỗi hiển thị tổng tiền gốc đã format
  String get formattedOriginalTotal => formatCurrency(selectedItemsOriginalTotal);

  /// Lấy chuỗi hiển thị số tiền tiết kiệm đã format
  String get formattedSavings => formatCurrency(selectedItemsSavings);
}