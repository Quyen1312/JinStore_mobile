import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class CartRepository extends GetxService {
  final ApiClient apiClient;

  CartRepository({required this.apiClient});

  /// Lấy giỏ hàng của người dùng hiện tại (đã đăng nhập).
  /// Backend xác định người dùng qua JWT token.
  Future<Response> getUserCart() async {
    try {
      // GET /api/carts/
      final response = await apiClient.getData(ApiConstants.CART_GET_USER);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy giỏ hàng: ${e.toString()}');
    }
  }

  /// Thêm một sản phẩm vào giỏ hàng của người dùng hiện tại.
  /// Payload thường chứa productId và quantity.
  Future<Response> addItemToCart(Map<String, dynamic> itemData) async {
    // itemData ví dụ: { "productId": "some_product_id", "quantity": 1 }
    try {
      // POST /api/carts/add
      final response = await apiClient.postData(ApiConstants.CART_ADD_ITEM, itemData);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi thêm vào giỏ hàng: ${e.toString()}');
    }
  }

  /// Cập nhật số lượng của một sản phẩm trong giỏ hàng.
  /// Payload thường chứa cartItemId (hoặc productId nếu backend xác định item qua product) và newQuantity.
  Future<Response> updateCartItem(Map<String, dynamic> itemUpdateData) async {
    // itemUpdateData ví dụ: { "cartItemId": "some_cart_item_id", "quantity": 2 }
    // hoặc { "productId": "some_product_id", "quantity": 2 }
    // Điều này phụ thuộc vào cách API PATCH /api/carts/update của bạn được thiết kế.
    try {
      // PATCH /api/carts/update
      final response = await apiClient.patchData(ApiConstants.CART_UPDATE_ITEM, itemUpdateData);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi cập nhật giỏ hàng: ${e.toString()}');
    }
  }

  /// Xóa một sản phẩm khỏi giỏ hàng dựa trên productId.
  Future<Response> removeItemFromCart(String productId) async {
    try {
      // DELETE /api/carts/remove/:productId
      final response = await apiClient.deleteData(ApiConstants.CART_REMOVE_ITEM_BASE.replaceFirst(':productId', productId));
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi xóa khỏi giỏ hàng: ${e.toString()}');
    }
  }

  /// Xóa tất cả sản phẩm khỏi giỏ hàng của người dùng hiện tại.
  Future<Response> clearUserCart() async {
    try {
      // DELETE /api/carts/clear
      final response = await apiClient.deleteData(ApiConstants.CART_CLEAR);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi xóa toàn bộ giỏ hàng: ${e.toString()}');
    }
  }
}
