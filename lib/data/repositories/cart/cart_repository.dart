import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class CartRepository extends GetxService{
  final ApiClient apiClient;
  CartRepository({required this.apiClient});

  Future<Response> cartList() async {
    return await apiClient.getData(ApiConstants.CART);

  }
  //delete cart clear all item 
  Future<Response> clearCart() async {
    return await apiClient.deleteData(ApiConstants.CLEAR_CART, {});
  }
  

  //post cart
  Future<Response> addToCart(String productId) async {
    return await apiClient.postData(ApiConstants.ADD_CART, {
      'product_id': productId,
    });
  }
  //remove item from cart
  Future<Response> removeFromCart(String cartId) async {
    return await apiClient.deleteData(ApiConstants.REMOVE_CART, {
      'cart_id': cartId,
      'quantity': 0,
    });
  }
}