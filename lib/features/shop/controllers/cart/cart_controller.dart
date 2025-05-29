import 'package:flutter_application_jin/data/repositories/cart/cart_repository.dart';
import 'package:flutter_application_jin/features/shop/models/cart_model.dart'; 
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartRepository cartRepository;

  var cart = Rxn<CartModel>(); 
  var isLoading = false.obs;
  var isUpdating = false.obs; 

  CartController({required this.cartRepository});

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final response = await cartRepository.cartList();
      if (response.statusCode == 200 || response.statusCode == 201) {
        cart.value = CartModel.fromJson(response.body['data']);
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      isUpdating.value = true;
      final response = await cartRepository.clearCart();
      if (response.statusCode == 200 || response.statusCode == 201) {
        cart.value = null; // Or re-fetch cart if API returns updated cart
        Get.snackbar('Success', 'Cart cleared successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      isUpdating.value = true;
      final response = await cartRepository.addToCart(productId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchCart(); // Re-fetch cart to update UI
        Get.snackbar('Success', 'Product added to cart');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to add product to cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      isUpdating.value = true;
      final response = await cartRepository.removeFromCart(cartItemId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchCart(); // Re-fetch cart to update UI
        Get.snackbar('Success', 'Product removed from cart');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to remove product from cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isUpdating.value = false;
    }
  }
} 