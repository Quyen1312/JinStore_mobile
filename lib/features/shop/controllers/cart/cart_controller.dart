import 'package:flutter_application_jin/data/repositories/cart/cart_repository.dart';
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart';
import 'package:flutter_application_jin/features/shop/models/cart_model.dart'; // Giả sử bạn có CartModel để chứa toàn bộ giỏ hàng
import 'package:flutter_application_jin/features/shop/models/product_model.dart'; // Cần để lấy thông tin sản phẩm khi thêm vào giỏ
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final CartRepository cartRepository;

  // --- Trạng thái Tải ---
  var isLoading = false.obs; // Dùng cho các thao tác chính với giỏ hàng
  var cartItemCount = 0.obs; // Số lượng tổng các mặt hàng (không phải số loại sản phẩm)
  var cartSubtotal = 0.0.obs; // Tổng tiền hàng trước khi có khuyến mãi, phí vận chuyển

  // --- Dữ liệu Giỏ hàng ---
  var cart = Rxn<CartModel>(); // Chứa toàn bộ thông tin giỏ hàng từ API (items, total, etc.)
  var cartItems = <CartItemModel>[].obs; // Danh sách các CartItemModel

  CartController({required this.cartRepository});

  @override
  void onInit() {
    super.onInit();
    // Tải giỏ hàng khi controller khởi tạo nếu người dùng đã đăng nhập
    // Logic này có thể được gọi từ AuthController sau khi đăng nhập thành công
    // hoặc khi UserController.setUser được gọi.
    // fetchUserCart(); // Tạm thời comment, sẽ gọi khi user được set
  }

  // Được gọi bởi UserController.setUser hoặc AuthController
  Future<void> initializeCartForUser() async {
    await fetchUserCart();
  }
  
  void clearCartOnLogout() {
    cart.value = null;
    cartItems.clear();
    _updateCartTotals();
  }

  Future<void> fetchUserCart() async {
    try {
      isLoading.value = true;
      final response = await cartRepository.getUserCart();

      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic responseData = response.body;
        // API /api/carts/ có thể trả về:
        // 1. Trực tiếp một CartModel (chứa items, subtotal, etc.)
        // 2. Hoặc một object chứa CartModel, ví dụ: { "cart": {...} } hoặc { "data": {...} }
        Map<String, dynamic>? cartData;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('cart') && responseData['cart'] is Map<String, dynamic>) {
            cartData = responseData['cart'];
          } else if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
            cartData = responseData['data'];
          } else if (responseData.containsKey('items') && responseData.containsKey('userId')) { // Nếu API trả về trực tiếp các trường của CartModel
            cartData = responseData;
          }
        }
        
        if (cartData != null) {
          cart.value = CartModel.fromJson(cartData);
          cartItems.assignAll(cart.value?.items ?? []);
        } else {
          // Nếu không có giỏ hàng hoặc định dạng sai, coi như giỏ hàng rỗng
          cart.value = CartModel.empty(); // Tạo cart rỗng
          cartItems.clear();
          // Loaders.warningSnackBar(title: 'Thông báo', message: 'Giỏ hàng trống hoặc không thể tải.');
        }
      } else {
        cart.value = CartModel.empty(); // Tạo cart rỗng khi lỗi
        cartItems.clear();
        Loaders.errorSnackBar(title: 'Lỗi tải giỏ hàng', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải giỏ hàng.');
      }
    } catch (e) {
      cart.value = CartModel.empty(); // Tạo cart rỗng khi lỗi
      cartItems.clear();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải giỏ hàng: ${e.toString()}');
    } finally {
      _updateCartTotals();
      isLoading.value = false;
    }
  }

  Future<void> addItemToCart(ProductModel product, {int quantity = 1}) async {
    if (quantity <= 0) return;
    try {
      isLoading.value = true; // Hoặc một biến loading riêng cho việc thêm sản phẩm
      // Payload cho API /api/carts/add
      final itemData = {
        "productId": product.id,
        "quantity": quantity,
        // API có thể cần thêm thông tin như price tại thời điểm thêm, hoặc tự lấy từ product.id
      };
      final response = await cartRepository.addItemToCart(itemData);

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? '${product.name} đã được thêm vào giỏ hàng.');
        await fetchUserCart(); // Tải lại toàn bộ giỏ hàng để cập nhật
      } else {
        Loaders.errorSnackBar(title: 'Lỗi thêm vào giỏ', message: response.body?['message'] ?? response.statusText ?? 'Không thể thêm sản phẩm vào giỏ.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi thêm vào giỏ: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCartItemQuantity(String productId, int newQuantity) async {
    if (newQuantity < 0) return; // Số lượng không thể âm

    try {
      isLoading.value = true; // Hoặc một biến loading riêng
      
      // Payload cho API /api/carts/update
      // API của bạn cần productId hay cartItemId?
      // Danh sách API ghi: PATCH /api/carts/update (không có tham số ID trong URL)
      // Vậy payload phải chứa thông tin để xác định item và số lượng mới.
      final itemUpdateData = {
        "productId": productId, // Hoặc "cartItemId" nếu backend dùng ID của cart item
        "quantity": newQuantity,
      };
      
      if (newQuantity == 0) { // Nếu số lượng mới là 0, thực hiện xóa sản phẩm
        await removeItemFromCart(productId);
        return; // Thoát khỏi hàm sau khi xóa
      }

      final response = await cartRepository.updateCartItem(itemUpdateData);

      if (response.statusCode == ApiConstants.SUCCESS) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Số lượng sản phẩm đã được cập nhật.');
        await fetchUserCart(); // Tải lại giỏ hàng
      } else {
        Loaders.errorSnackBar(title: 'Lỗi cập nhật', message: response.body?['message'] ?? response.statusText ?? 'Không thể cập nhật số lượng.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi cập nhật giỏ hàng: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItemFromCart(String productId) async {
    try {
      isLoading.value = true; // Hoặc một biến loading riêng
      // API: DELETE /api/carts/remove/:productId
      final response = await cartRepository.removeItemFromCart(productId);

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.NO_CONTENT) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Sản phẩm đã được xóa khỏi giỏ hàng.');
        // Cập nhật UI cục bộ hoặc tải lại toàn bộ giỏ hàng
        cartItems.removeWhere((item) => item.productId == productId);
        _updateCartTotals(); // Cập nhật lại tổng tiền và số lượng
        // Hoặc: await fetchUserCart();
      } else {
        Loaders.errorSnackBar(title: 'Lỗi xóa', message: response.body?['message'] ?? response.statusText ?? 'Không thể xóa sản phẩm.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi xóa khỏi giỏ hàng: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearUserCart() async {
    try {
      isLoading.value = true;
      // API: DELETE /api/carts/clear
      final response = await cartRepository.clearUserCart();

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.NO_CONTENT) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Giỏ hàng đã được xóa sạch.');
        cartItems.clear();
        cart.value = CartModel.empty(); // Reset cart
        _updateCartTotals();
      } else {
        Loaders.errorSnackBar(title: 'Lỗi xóa giỏ hàng', message: response.body?['message'] ?? response.statusText ?? 'Không thể xóa toàn bộ giỏ hàng.');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi xóa toàn bộ giỏ hàng: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Tính toán Giỏ hàng ---
  void _updateCartTotals() {
    // if (cart.value != null) {
    //   cartSubtotal.value = cart.value!.totalPrice; // Giả sử API trả về totalPrice là subtotal
    //   cartItemCount.value = cart.value!.totalQuantity; // Giả sử API trả về totalQuantity
    // } else {
    //   cartSubtotal.value = 0.0;
    //   cartItemCount.value = 0;
    // }
    // Nếu API không trả về tổng tiền và số lượng, bạn cần tính toán từ cartItems:
    double calculatedSubtotal = 0;
    int calculatedItemCount = 0;
    for (var item in cartItems) {
      // FIXME: item.price is not available in CartItemModel. Price needed for subtotal.
      // calculatedSubtotal += (item.price * item.quantity);
      calculatedItemCount += item.quantity;
    }
    cartSubtotal.value = calculatedSubtotal; // This will be 0.0 for now
    cartItemCount.value = calculatedItemCount;
  }

  // Lấy số lượng của một sản phẩm cụ thể trong giỏ hàng
  int getProductQuantityInCart(String productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  // Tăng số lượng sản phẩm (gọi từ UI)
  void incrementQuantity(CartItemModel item) {
    updateCartItemQuantity(item.productId, item.quantity + 1);
  }

  // Giảm số lượng sản phẩm (gọi từ UI)
  void decrementQuantity(CartItemModel item) {
    if (item.quantity > 0) { // Nếu là 1 thì khi giảm sẽ thành 0, updateCartItemQuantity sẽ xử lý xóa
      updateCartItemQuantity(item.productId, item.quantity - 1);
    }
  }
}
