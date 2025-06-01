import 'package:get/get.dart';
import 'package:flutter_application_jin/service/cart/cart_service.dart';
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  final CartService _cartService = Get.find<CartService>();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap cart = {}.obs;
  final RxDouble total = 0.0.obs;
  final RxInt cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final cartData = await _cartService.getCart();
      cart.value = cartData;
      _calculateTotal();
      _updateCartCount();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final cartData = await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );
      cart.value = cartData;
      _calculateTotal();
      _updateCartCount();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final cartData = await _cartService.updateCartItem(
        productId: productId,
        quantity: quantity,
      );
      cart.value = cartData;
      _calculateTotal();
      _updateCartCount();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeCartItem(String productId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _cartService.removeCartItem(productId);
      await fetchCart(); // Refresh cart after removal
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _cartService.clearCart();
      cart.value = {};
      total.value = 0;
      cartItemCount.value = 0;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotal() {
    if (cart.isEmpty || !cart.containsKey('items')) {
      total.value = 0;
      return;
    }

    double sum = 0;
    final items = cart['items'] as List;
    for (var item in items) {
      final price = item['price'] as double;
      final quantity = item['quantity'] as int;
      sum += price * quantity;
    }
    total.value = sum;
  }

  void _updateCartCount() {
    if (cart.isEmpty || !cart.containsKey('items')) {
      cartItemCount.value = 0;
      return;
    }
    final items = cart['items'] as List;
    cartItemCount.value = items.length;
  }
} 