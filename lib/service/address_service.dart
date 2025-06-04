import 'dart:convert';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:get/get.dart';

class AddressService extends GetConnect {
  @override
  void onInit() {
    // KHÔNG set httpClient.baseUrl ở đây vì sẽ conflict với URL đầy đủ
    httpClient.timeout = const Duration(seconds: 30);

    // Request interceptor - tự động thêm token và xử lý auth
    httpClient.addRequestModifier<void>((request) async {
      try {
        final authController = Get.find<AuthController>();
        
        // Lấy token hợp lệ (tự động refresh nếu cần)
        final token = await authController.getValidToken();
        
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        // XÓA duplicate Content-Type - GetConnect tự động set
        // request.headers['Content-Type'] = 'application/json';
        
        print("AddressService Request: ${request.method} ${request.url}");
        print("AddressService Headers: ${request.headers}");
        print("AddressService Body: ${request.bodyBytes}");
        
      } catch (e) {
        print('Error getting token in request interceptor: $e');
      }
      
      return request;
    });

    // Response interceptor - xử lý lỗi authentication
    httpClient.addResponseModifier((request, response) async {
      print("AddressService Response: ${response.statusCode} for ${request.url}");
      
      // Xử lý 401 Unauthorized
      if (response.statusCode == 401) {
        print('Received 401, attempting token refresh...');
        
        try {
          final authController = Get.find<AuthController>();
          final refreshSuccess = await authController.tryRefreshToken();
          
          if (refreshSuccess) {
            print('Token refreshed successfully, retrying request...');
            
            // Lấy token mới và retry request
            final newToken = await authController.getValidToken();
            if (newToken != null) {
              request.headers['Authorization'] = 'Bearer $newToken';
              
              // Retry request với token mới
              final retryResponse = await httpClient.request(
                request.url.toString(),
                request.method,
                headers: request.headers,
                body: request.bodyBytes,
              );
              
              return retryResponse;
            }
          }
        } catch (e) {
          print('Error during token refresh: $e');
        }
      }
      
      return response;
    });

    super.onInit();
  }

  /// Helper để xử lý lỗi chung từ API
  void _handleResponseError(Response response, String defaultMessage) {
    print('Error Response Status (AddressService): ${response.statusCode}');
    print('Error Response Body (AddressService): ${response.bodyString}');
    
    try {
      if (response.body != null && response.body is Map<String, dynamic>) {
        final errorData = response.body as Map<String, dynamic>;
        final message = errorData['message'] as String? ?? 
                       errorData['error'] as String? ?? 
                       defaultMessage;
        throw message;
      }
    } catch (e) {
      if (e is String) throw e;
    }
    
    // Xử lý các status code cụ thể
    switch (response.statusCode) {
      case 400:
        throw 'Dữ liệu không hợp lệ: $defaultMessage';
      case 401:
        throw 'Không có quyền truy cập. Vui lòng đăng nhập lại.';
      case 403:
        throw 'Bạn không có quyền thực hiện hành động này.';
      case 404:
        throw 'Không tìm thấy dữ liệu yêu cầu.';
      case 500:
        throw 'Lỗi máy chủ. Vui lòng thử lại sau.';
      default:
        throw defaultMessage;
    }
  }

  /// Kiểm tra kết nối mạng và authentication
  Future<void> _checkConnectionAndAuth() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value) {
        throw 'Vui lòng đăng nhập để tiếp tục.';
      }
    } catch (e) {
      throw 'Lỗi authentication: ${e.toString()}';
    }
  }

  /// Lấy tất cả địa chỉ của người dùng hiện tại
  /// Backend: GET /addresses/user/all
  Future<List<Address>> getAddressesOfCurrentUser() async {
    try {
      await _checkConnectionAndAuth();
      
      // Sử dụng URL đầy đủ
      final response = await get('http://localhost:1000/api/addresses/user/all');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] is List) {
          final List<dynamic> addressesJson = data['data'] as List<dynamic>;
          
          // Parse từng address một cách an toàn
          final List<Address> addresses = [];
          for (int i = 0; i < addressesJson.length; i++) {
            try {
              final addressData = addressesJson[i] as Map<String, dynamic>;
              print("Parsing address $i: $addressData");
              final address = Address.fromJson(addressData);
              addresses.add(address);
            } catch (e) {
              print("Error parsing address at index $i: $e");
              print("Address data: ${addressesJson[i]}");
              // Tiếp tục parse các address khác thay vì throw error
            }
          }
          
          return addresses;
        }
        _handleResponseError(response, 'Lỗi khi lấy danh sách địa chỉ từ server.');
      }
      _handleResponseError(response, 'Lỗi khi lấy danh sách địa chỉ.');
      return [];
    } catch (e) {
      print('Lỗi trong AddressService.getAddressesOfCurrentUser: $e');
      throw e is String ? e : 'Không thể lấy danh sách địa chỉ: ${e.toString()}';
    }
  }

  /// Lấy tất cả địa chỉ của một người dùng cụ thể (Admin only)
  /// Backend: GET /addresses/user/all/:id
  Future<List<Address>> getAddressesByUserIdAdmin(String userId) async {
    try {
      await _checkConnectionAndAuth();
      
      if (userId.isEmpty) {
        throw 'ID người dùng không hợp lệ.';
      }
      
      final response = await get('http://localhost:1000/api/addresses/user/all/$userId');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] is List) {
          final List<dynamic> addressesJson = data['data'] as List<dynamic>;
          
          // Parse từng address một cách an toàn
          final List<Address> addresses = [];
          for (int i = 0; i < addressesJson.length; i++) {
            try {
              final addressData = addressesJson[i] as Map<String, dynamic>;
              print("Parsing address $i: $addressData");
              final address = Address.fromJson(addressData);
              addresses.add(address);
            } catch (e) {
              print("Error parsing address at index $i: $e");
              print("Address data: ${addressesJson[i]}");
              // Tiếp tục parse các address khác thay vì throw error
            }
          }
          
          return addresses;
        }
        _handleResponseError(response, 'Lỗi khi lấy danh sách địa chỉ của người dùng từ server.');
      }
      _handleResponseError(response, 'Lỗi khi lấy danh sách địa chỉ của người dùng.');
      return [];
    } catch (e) {
      print('Lỗi trong AddressService.getAddressesByUserIdAdmin: $e');
      throw e is String ? e : 'Không thể lấy danh sách địa chỉ của người dùng: ${e.toString()}';
    }
  }

  /// Lấy một địa chỉ cụ thể bằng ID
  /// Backend: GET /addresses/:addressId
  Future<Address> getAddressById(String addressId) async {
    try {
      await _checkConnectionAndAuth();
      
      if (addressId.isEmpty) {
        throw 'ID địa chỉ không hợp lệ.';
      }
      
      final response = await get('http://localhost:1000/api/addresses/$addressId');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['data'] != null) {
          try {
            return Address.fromJson(data['data'] as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing single address: $e');
            print('Address data: ${data['data']}');
            throw 'Lỗi parse dữ liệu địa chỉ: $e';
          }
        }
        _handleResponseError(response, 'Định dạng dữ liệu địa chỉ không đúng từ server.');
      }
      _handleResponseError(response, 'Không thể lấy thông tin địa chỉ.');
      throw 'Lỗi không xác định khi lấy thông tin địa chỉ';
    } catch (e) {
      print('Lỗi trong AddressService.getAddressById: $e');
      throw e is String ? e : 'Lỗi khi lấy thông tin địa chỉ: ${e.toString()}';
    }
  }

  /// Thêm địa chỉ mới
  /// Backend: POST /addresses/add
  Future<Address> addAddress({
    required String detailed,
    required String district,
    required String city,
    required String province,
    bool isDefault = false,
  }) async {
    try {
      await _checkConnectionAndAuth();
      
      // Validate input
      if (detailed.trim().isEmpty) {
        throw 'Địa chỉ chi tiết không được để trống.';
      }
      if (district.trim().isEmpty) {
        throw 'Phường/Xã không được để trống.';
      }
      if (city.trim().isEmpty) {
        throw 'Quận/Huyện không được để trống.';
      }
      if (province.trim().isEmpty) {
        throw 'Tỉnh/Thành phố không được để trống.';
      }

      final body = {
        'detailed': detailed.trim(),
        'district': district.trim(),
        'city': city.trim(),
        'province': province.trim(),
        'isDefault': isDefault,
      };
      
      print("AddressService addAddress Body: $body");
      print("AddressService addAddress Body JSON: ${json.encode(body)}");
      
      // KHÔNG set headers - để GetConnect tự động handle
      final response = await post(
        'http://localhost:1000/api/addresses/add',
        body,
      );

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['data'] != null) {
          try {
            return Address.fromJson(data['data'] as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing new address: $e');
            print('Address data: ${data['data']}');
            throw 'Lỗi parse dữ liệu địa chỉ mới: $e';
          }
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server sau khi thêm địa chỉ.');
      }
      _handleResponseError(response, 'Lỗi khi thêm địa chỉ.');
      throw 'Lỗi không xác định khi thêm địa chỉ';
    } catch (e) {
      print('Lỗi trong AddressService.addAddress: $e');
      throw e is String ? e : 'Lỗi khi thêm địa chỉ: ${e.toString()}';
    }
  }

  /// Cập nhật địa chỉ
  /// Backend: PUT /addresses/:addressId
  Future<Address> updateAddress({
    required String addressId,
    String? detailed,
    String? district,
    String? city,
    String? province,
    bool? isDefault,
  }) async {
    try {
      await _checkConnectionAndAuth();
      
      if (addressId.isEmpty) {
        throw 'ID địa chỉ không hợp lệ.';
      }

      final Map<String, dynamic> updateData = {};
      if (detailed != null && detailed.trim().isNotEmpty) {
        updateData['detailed'] = detailed.trim();
      }
      if (district != null && district.trim().isNotEmpty) {
        updateData['district'] = district.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        updateData['city'] = city.trim();
      }
      if (province != null && province.trim().isNotEmpty) {
        updateData['province'] = province.trim();
      }
      if (isDefault != null) {
        updateData['isDefault'] = isDefault;
      }

      if (updateData.isEmpty) {
        throw 'Không có thông tin nào để cập nhật cho địa chỉ.';
      }

      print("AddressService updateAddress Body: $updateData");
      
      // KHÔNG set headers - để GetConnect tự động handle
      final response = await put(
        'http://localhost:1000/api/addresses/$addressId',
        updateData,
      );

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['data'] != null) {
          try {
            return Address.fromJson(data['data'] as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing updated address: $e');
            print('Address data: ${data['data']}');
            throw 'Lỗi parse dữ liệu địa chỉ đã cập nhật: $e';
          }
        }
        _handleResponseError(response, 'Định dạng dữ liệu không đúng từ server sau khi cập nhật địa chỉ.');
      }
      _handleResponseError(response, 'Lỗi khi cập nhật địa chỉ.');
      throw 'Lỗi không xác định khi cập nhật địa chỉ';
    } catch (e) {
      print('Lỗi trong AddressService.updateAddress: $e');
      throw e is String ? e : 'Lỗi khi cập nhật địa chỉ: ${e.toString()}';
    }
  }

  /// Xóa địa chỉ
  /// Backend: DELETE /addresses/:addressId
  Future<void> deleteAddress(String addressId) async {
    try {
      await _checkConnectionAndAuth();
      
      if (addressId.isEmpty) {
        throw 'ID địa chỉ không hợp lệ.';
      }
      
      final response = await delete('http://localhost:1000/api/addresses/$addressId');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
        _handleResponseError(response, 'Lỗi không xác định khi xóa địa chỉ.');
      }
      _handleResponseError(response, 'Lỗi khi xóa địa chỉ.');
    } catch (e) {
      print('Lỗi trong AddressService.deleteAddress: $e');
      throw e is String ? e : 'Lỗi khi xóa địa chỉ: ${e.toString()}';
    }
  }

  /// Đặt địa chỉ mặc định
  /// Backend: PUT /addresses/:addressId/set-default
  Future<void> setDefaultAddress(String addressId) async {
    try {
      await _checkConnectionAndAuth();
      
      if (addressId.isEmpty) {
        throw 'ID địa chỉ không hợp lệ.';
      }
      
      // KHÔNG set headers - để GetConnect tự động handle
      final response = await put(
        'http://localhost:1000/api/addresses/$addressId/set-default',
        {},
      );

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
        _handleResponseError(response, 'Lỗi không xác định khi đặt địa chỉ mặc định.');
      }
      _handleResponseError(response, 'Lỗi khi đặt địa chỉ mặc định.');
    } catch (e) {
      print('Lỗi trong AddressService.setDefaultAddress: $e');
      throw e is String ? e : 'Lỗi khi đặt địa chỉ mặc định: ${e.toString()}';
    }
  }

  /// Lấy địa chỉ mặc định của người dùng hiện tại
  /// Backend: GET /addresses/default/user
  Future<Address?> getDefaultAddress() async {
    try {
      await _checkConnectionAndAuth();
      
      final response = await get('http://localhost:1000/api/addresses/default/user');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['data'] != null) {
          try {
            return Address.fromJson(data['data'] as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing default address: $e');
            print('Address data: ${data['data']}');
            throw 'Lỗi parse dữ liệu địa chỉ mặc định: $e';
          }
        }
      }
      
      if (response.statusCode == 404) {
        print('Không có địa chỉ mặc định');
        return null;
      }
      
      _handleResponseError(response, 'Lỗi khi lấy địa chỉ mặc định.');
      return null;
    } catch (e) {
      print('Lỗi trong AddressService.getDefaultAddress: $e');
      throw e is String ? e : 'Không thể lấy địa chỉ mặc định: ${e.toString()}';
    }
  }

  /// Lấy địa chỉ mặc định của một người dùng cụ thể (Admin only)
  /// Backend: GET /addresses/default/user/:userId
  Future<Address?> getDefaultAddressByUserIdAdmin(String userId) async {
    try {
      await _checkConnectionAndAuth();
      
      if (userId.isEmpty) {
        throw 'ID người dùng không hợp lệ.';
      }
      
      final response = await get('http://localhost:1000/api/addresses/default/user/$userId');

      print("AddressService Response Status: ${response.statusCode}");
      print("AddressService Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic> && 
            data['success'] == true && 
            data['data'] != null) {
          try {
            return Address.fromJson(data['data'] as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing default address by user ID: $e');
            print('Address data: ${data['data']}');
            throw 'Lỗi parse dữ liệu địa chỉ mặc định: $e';
          }
        }
      }
      
      if (response.statusCode == 404) {
        print('Không tìm thấy địa chỉ mặc định cho người dùng $userId');
        return null;
      }
      
      _handleResponseError(response, 'Lỗi khi lấy địa chỉ mặc định của người dùng.');
      return null;
    } catch (e) {
      print('Lỗi trong AddressService.getDefaultAddressByUserIdAdmin: $e');
      throw e is String ? e : 'Không thể lấy địa chỉ mặc định của người dùng: ${e.toString()}';
    }
  }

  /// Kiểm tra địa chỉ có hợp lệ không
  bool validateAddressData({
    required String detailed,
    required String district,
    required String city,
    required String province,
  }) {
    return detailed.trim().isNotEmpty &&
           district.trim().isNotEmpty &&
           city.trim().isNotEmpty &&
           province.trim().isNotEmpty;
  }

  /// Format địa chỉ đầy đủ
  String formatFullAddress(Address address) {
    return '${address.detailed}, ${address.district}, ${address.city}, ${address.province}';
  }
}