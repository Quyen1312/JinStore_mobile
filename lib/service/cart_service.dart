import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/models/cart_model.dart';

/// Model để hiển thị sản phẩm trong giỏ hàng với thông tin đã được populate
class DisplayCartItem {
  final String productId;
  final String name;
  final double price;
  final double? discount;
  final double discountPrice;
  final String? unit;
  final List<String> images;
  final int quantity;
  final double totalDiscountPrice;
  bool isSelected; // Thêm trường này cho checkbox

  DisplayCartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.discount,
    required this.discountPrice,
    this.unit,
    required this.images,
    required this.quantity,
    required this.totalDiscountPrice,
    this.isSelected = true, // Mặc định được chọn
  });

  factory DisplayCartItem.fromJson(Map<String, dynamic> json) {
    // Parse images: Backend có thể trả về mảng các object {url: String} hoặc mảng string
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in (json['images'] as List)) {
        if (img is Map<String, dynamic> && img.containsKey('url')) {
          parsedImages.add(img['url'] as String);
        } else if (img is String) {
          parsedImages.add(img);
        }
      }
    }

    return DisplayCartItem(
      productId: json['_id'] as String? ?? json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      discountPrice: (json['discountPrice'] as num).toDouble(),
      unit: json['unit'] as String?,
      images: parsedImages,
      quantity: json['quantity'] as int,
      totalDiscountPrice: (json['totalDiscountPrice'] as num).toDouble(),
      isSelected: json['isSelected'] as bool? ?? true, // Mặc định true
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'discount': discount,
      'discountPrice': discountPrice,
      'unit': unit,
      'images': images,
      'quantity': quantity,
      'totalDiscountPrice': totalDiscountPrice,
      'isSelected': isSelected,
    };
  }

  // Thêm method copyWith để dễ dàng cập nhật
  DisplayCartItem copyWith({
    String? productId,
    String? name,
    double? price,
    double? discount,
    double? discountPrice,
    String? unit,
    List<String>? images,
    int? quantity,
    double? totalDiscountPrice,
    bool? isSelected,
  }) {
    return DisplayCartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      discountPrice: discountPrice ?? this.discountPrice,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      quantity: quantity ?? this.quantity,
      totalDiscountPrice: totalDiscountPrice ?? this.totalDiscountPrice,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'DisplayCartItem(productId: $productId, name: $name, quantity: $quantity, totalDiscountPrice: $totalDiscountPrice, isSelected: $isSelected)';
  }
}

class CartService extends GetxService {
  static CartService get instance => Get.find();

  // Sử dụng FlutterSecureStorage cho tất cả token để bảo mật tốt hơn
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _baseUrl = 'http://localhost:1000/api';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  // GetConnect instance cho HTTP requests
  final GetConnect _httpClient = GetConnect();

  @override
  void onInit() {
    super.onInit();
    _initializeHttpClient();
  }

  void _initializeHttpClient() {
    _httpClient.baseUrl = _baseUrl;
    _httpClient.timeout = const Duration(seconds: 30);
    
    // Interceptor để tự động thêm token vào headers
    _httpClient.httpClient.addRequestModifier<void>((request) async {
      final token = await AuthController.instance.getValidToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    // Interceptor để log response
    _httpClient.httpClient.addResponseModifier((request, response) {
      if (kDebugMode) {
        print('📥 Response: ${response.statusCode} ${response.request?.url}');
        print('📥 Body: ${response.bodyString}');
      }
      return response;
    });
  }



  // ============= TOKEN MANAGEMENT =============


  /// Lấy access token (kiểm tra hết hạn)
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) return null;

      // Kiểm tra thời gian hết hạn
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
        if (DateTime.now().isAfter(expiry)) {
          debugPrint('Access token đã hết hạn, cần refresh');
          await _deleteAccessToken();
          return null;
        }
      }

      return token;
    } catch (e) {
      debugPrint('Lỗi khi lấy access token: $e');
      return null;
    }
  }

  /// Kiểm tra access token có hợp lệ không
  Future<bool> isAccessTokenValid() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Xóa access token
  Future<void> _deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }


  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Xóa refresh token
  Future<void> _deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Kiểm tra người dùng đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null || refreshToken != null;
  }

  /// Xóa tất cả dữ liệu đăng nhập
  Future<void> clearAllData() async {
    await _deleteAccessToken();
    await _deleteRefreshToken();
    await _storage.delete(key: _userDataKey);
  }

  // ============= HELPER METHODS =============

  /// Helper để xử lý lỗi chung từ API
  String _handleResponseError(Response response, String defaultMessage) {
    debugPrint('Error Response Status (CartService): ${response.statusCode}');
    debugPrint('Error Response Body (CartService): ${response.bodyString}');
    
    if (response.body != null && response.body is Map<String, dynamic>) {
      final errorData = response.body as Map<String, dynamic>;
      return errorData['message'] as String? ?? defaultMessage;
    }
    
    // Handle specific HTTP status codes
    switch (response.statusCode) {
      case 401:
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện hành động này.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 422:
        return 'Dữ liệu không hợp lệ.';
      case 500:
        return 'Lỗi server, vui lòng thử lại sau.';
      default:
        return defaultMessage;
    }
  }

  /// Helper để kiểm tra authentication trước khi gọi API
  Future<void> _ensureAuthenticated() async {
    try {
      // Kiểm tra AuthController có tồn tại không
      if (!Get.isRegistered<AuthController>()) {
        throw 'AuthController chưa được khởi tạo.';
      }

      final authController = Get.find<AuthController>();
      
      if (!authController.isLoggedIn.value) {
        throw 'Bạn cần đăng nhập để sử dụng giỏ hàng.';
      }
      
      final token = await authController.getValidToken();
      if (token == null) {
        throw 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      }
    } catch (e) {
      debugPrint('Lỗi authentication check trong CartService: $e');
      rethrow;
    }
  }

  // ============= CART API METHODS =============

  /// Lấy giỏ hàng của người dùng (dữ liệu đã populate để hiển thị)
  /// Backend: GET /carts
 Future<List<DisplayCartItem>> getCart() async {
  try {
    // Attempt to get a valid token, refresh if needed
    final authController = Get.find<AuthController>();
    final token = await authController.getValidToken();

    if (token == null) {
      throw 'Không thể lấy token hợp lệ. Vui lòng đăng nhập lại.';
    }

    final response = await _httpClient.get('/carts',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = response.body;

      // Trường hợp API trả về format {success: true, data: [...]}
      if (responseData is Map<String, dynamic>) {
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> itemsJson = responseData['data'];
          return itemsJson
              .map((json) => DisplayCartItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        // Trường hợp trả về {items: [...]}
        if (responseData['items'] is List) {
          final List<dynamic> itemsJson = responseData['items'];
          return itemsJson
              .map((json) => DisplayCartItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      // Nếu trả về trực tiếp là một List
      if (responseData is List) {
        return responseData
            .map((json) => DisplayCartItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Trường hợp giỏ hàng trống hoặc không rõ định dạng
      return [];
    }

    final errorMessage = _handleResponseError(response, 'Không thể lấy giỏ hàng.');
    throw errorMessage;
  } catch (e) {
    debugPrint('Lỗi trong CartService.getCart: $e');
    if (e is String) {
      throw e;
    }
    throw 'Lỗi khi lấy giỏ hàng: ${e.toString()}';
  }
}

  /// Thêm sản phẩm vào giỏ hàng
  /// Backend: POST /carts/add
  Future<CartModel?> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _ensureAuthenticated();
      
      if (quantity <= 0) {
        throw 'Số lượng sản phẩm phải lớn hơn 0.';
      }
      
      final body = {
        'productId': productId,
        'quantity': quantity,
      };
      
      debugPrint("CartService addToCart Body: $body");
      
      final response = await _httpClient.post('/carts/add', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Đơn giản: chỉ return null, để fetchCart() xử lý
        debugPrint("Add to cart thành công, return null để refetch");
        return null;
      }
      
      final errorMessage = _handleResponseError(response, 'Không thể thêm vào giỏ hàng.');
      throw errorMessage;
    } catch (e) {
      debugPrint('Lỗi trong CartService.addToCart: $e');
      if (e is String) {
        throw e;
      }
      throw 'Lỗi khi thêm vào giỏ hàng: ${e.toString()}';
    }
  }

  /// Cập nhật số lượng sản phẩm trong giỏ hàng
  /// Backend: PATCH /carts/update
  Future<CartModel?> updateCartItem({
  required String productId,
  required int quantity,
}) async {
  try {
    await _ensureAuthenticated();
    
    if (quantity < 0) {
      throw 'Số lượng sản phẩm không thể âm.';
    }
    
    final body = {
      'productId': productId,
      'quantity': quantity,
    };
    
    // Debug mobile request
    debugPrint("Mobile UpdateCartItem Request: $body");
    
    final response = await _httpClient.post('/carts/update', body);

    // Debug mobile response  
    debugPrint("Mobile UpdateCartItem Status: ${response.statusCode}");
    debugPrint("Mobile UpdateCartItem Body: ${response.bodyString}");

    if (response.statusCode == 200) {
      // Đơn giản: chỉ return null, để fetchCart() xử lý
      debugPrint("Update thành công, return null để refetch");
      return null;
    }
    
    final errorMessage = _handleResponseError(response, 'Không thể cập nhật giỏ hàng.');
    throw errorMessage;
  } catch (e) {
    debugPrint('Lỗi trong CartService.updateCartItem: $e');
    if (e is String) {
      throw e;
    }
    throw 'Lỗi khi cập nhật giỏ hàng: ${e.toString()}';
  }
}
  /// Xóa sản phẩm khỏi giỏ hàng
  /// Backend: DELETE /carts/remove/:productId
  Future<CartModel?> removeCartItem(String productId) async {
    try {
      await _ensureAuthenticated();
      
      final response = await _httpClient.delete('/carts/remove/$productId');

      if (response.statusCode == 200) {
        final responseData = response.body;
        
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return CartModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      } else if (response.statusCode == 204) {
        // 204 No Content - xóa thành công nhưng không trả về dữ liệu
        debugPrint('Sản phẩm đã được xóa thành công');
        return null;
      }
      
      final errorMessage = _handleResponseError(response, 'Không thể xóa sản phẩm khỏi giỏ hàng.');
      throw errorMessage;
    } catch (e) {
      debugPrint('Lỗi trong CartService.removeCartItem: $e');
      if (e is String) {
        throw e;
      }
      throw 'Lỗi khi xóa sản phẩm: ${e.toString()}';
    }
  }

  /// Xóa toàn bộ giỏ hàng
  /// Backend: DELETE /carts/clear
  Future<CartModel?> clearCart() async {
    try {
      await _ensureAuthenticated();
      
      final response = await _httpClient.delete('/carts/clear');

      if (response.statusCode == 200) {
        final responseData = response.body;
        
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          return CartModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      } else if (response.statusCode == 204) {
        // 204 No Content - xóa thành công
        debugPrint('Giỏ hàng đã được xóa thành công');
        return null;
      }
      
      final errorMessage = _handleResponseError(response, 'Không thể xóa toàn bộ giỏ hàng.');
      throw errorMessage;
    } catch (e) {
      debugPrint('Lỗi trong CartService.clearCart: $e');
      if (e is String) {
        throw e;
      }
      throw 'Lỗi khi xóa toàn bộ giỏ hàng: ${e.toString()}';
    }
  }

  // ============= UTILITY METHODS =============

  /// Đếm số lượng item trong giỏ hàng
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCart();
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      debugPrint('Lỗi khi đếm số lượng item trong giỏ hàng: $e');
      return 0;
    }
  }

  /// Đếm số lượng sản phẩm khác nhau trong giỏ hàng
  Future<int> getUniqueItemCount() async {
    try {
      final cartItems = await getCart();
      return cartItems.length;
    } catch (e) {
      debugPrint('Lỗi khi đếm số lượng sản phẩm khác nhau: $e');
      return 0;
    }
  }

  /// Tính tổng tiền giỏ hàng
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCart();
      return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalDiscountPrice);
    } catch (e) {
      debugPrint('Lỗi khi tính tổng giá trị giỏ hàng: $e');
      return 0.0;
    }
  }

  /// Tính tổng tiền trước khi giảm giá
  Future<double> getCartSubtotal() async {
    try {
      final cartItems = await getCart();
      return cartItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    } catch (e) {
      debugPrint('Lỗi khi tính subtotal giỏ hàng: $e');
      return 0.0;
    }
  }

  /// Tính tổng số tiền tiết kiệm được
  Future<double> getCartSavings() async {
    try {
      final subtotal = await getCartSubtotal();
      final total = await getCartTotal();
      return subtotal - total;
    } catch (e) {
      debugPrint('Lỗi khi tính số tiền tiết kiệm: $e');
      return 0.0;
    }
  }

  /// Kiểm tra sản phẩm có trong giỏ hàng không
  Future<bool> isProductInCart(String productId) async {
    try {
      final cartItems = await getCart();
      return cartItems.any((item) => item.productId == productId);
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra sản phẩm trong giỏ hàng: $e');
      return false;
    }
  }

  /// Lấy số lượng của một sản phẩm cụ thể trong giỏ hàng
  Future<int> getProductQuantityInCart(String productId) async {
    try {
      final cartItems = await getCart();
      final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
      return item?.quantity ?? 0;
    } catch (e) {
      debugPrint('Lỗi khi lấy số lượng sản phẩm trong giỏ hàng: $e');
      return 0;
    }
  }

  /// Kiểm tra giỏ hàng có trống không
  Future<bool> isCartEmpty() async {
    try {
      final count = await getUniqueItemCount();
      return count == 0;
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra giỏ hàng trống: $e');
      return true;
    }
  }
}