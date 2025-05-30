import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class UserRepository extends GetxService {
  final ApiClient apiClient;
  UserRepository({required this.apiClient});

  // Lưu ý: Việc lấy thông tin người dùng hiện tại (đã đăng nhập) 
  // được xử lý chính bởi AuthRepository.fetchCurrentUserInfo()

  /// Cập nhật thông tin hồ sơ người dùng hiện tại.
  /// Backend xác định người dùng thông qua JWT token.
  Future<Response> updateUserProfile(User userUpdates) async {
    try {
      // Sử dụng PATCH /api/users/info-user/update
      // Đảm bảo userUpdates.toJson() chỉ chuẩn bị các trường có thể cập nhật.
      final response = await apiClient.patchData(ApiConstants.USERS_UPDATE_CURRENT_INFO, userUpdates.toJson());
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi cập nhật thông tin người dùng: ${e.toString()}');
    }
  }
  
  // --- Quản lý Địa chỉ ---

  /// Lấy tất cả địa chỉ của một người dùng cụ thể bằng userId của họ.
  /// Backend API: GET /api/addresses/user/all (cho user hiện tại)
  /// hoặc GET /api/addresses/user/all/:id (cho admin lấy của user khác)
  /// Vì đây là UserRepository cho user, ta giả định nó lấy địa chỉ của user hiện tại (backend sẽ dùng token)
  /// Hoặc nếu backend yêu cầu userId ngay cả cho user hiện tại, thì cần truyền vào.
  /// Dựa trên ApiConstants.GET_ALL_ADDRESSES_BY_USER_ID_BASE = "/addresses/user",
  /// và API list GET /api/addresses/user/all (Get all addresses for the logged-in user)
  /// thì có thể endpoint là cố định và backend tự lấy userId từ token.
  /// Nếu backend của bạn là GET /api/addresses/user/all/:userId thì cần truyền userId.
  /// Hiện tại, ApiConstants.GET_ALL_ADDRESSES_BY_USER_ID_BASE là "/addresses/user"
  /// và danh sách API của bạn có GET /api/addresses/user/all (cho user hiện tại)
  /// và GET /api/addresses/user/all/:id (cho admin).
  /// Vậy, endpoint cho user hiện tại là ApiConstants.ADDRESSES_GET_ALL_CURRENT_USER
  Future<Response> fetchAddressesForCurrentUser() async {
    try {
      final response = await apiClient.getData(ApiConstants.ADDRESSES_GET_ALL_CURRENT_USER);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy danh sách địa chỉ: ${e.toString()}');
    }
  }

  /// Thêm một địa chỉ mới cho người dùng hiện tại.
  /// Backend nên liên kết nó với người dùng dựa trên JWT token.
  Future<Response> addAddress(AddressModel addressModel) async { 
    try {
      // Sử dụng POST /api/addresses/add
      return await apiClient.postData(ApiConstants.ADDRESSES_ADD, addressModel.toJson());
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi thêm địa chỉ: ${e.toString()}');
    }
  }

  /// Cập nhật một địa chỉ đã có bằng ID của nó.
  Future<Response> updateAddress(String addressId, AddressModel addressModel) async {
    try {
      // Sử dụng PUT /api/addresses/:addressId
      final response = await apiClient.putData('${ApiConstants.ADDRESSES_BASE}/$addressId', addressModel.toJson());
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi cập nhật địa chỉ: ${e.toString()}');
    }
  }

  /// Xóa một địa chỉ bằng ID của nó.
  Future<Response> deleteAddress(String addressId) async {
    try {
      // Sử dụng DELETE /api/addresses/:addressId
      final response = await apiClient.deleteData('${ApiConstants.ADDRESSES_BASE}/$addressId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi xóa địa chỉ: ${e.toString()}');
    }
  }

  /// Đặt một địa chỉ cụ thể làm địa chỉ mặc định cho người dùng.
  /// Backend nên xác định người dùng qua JWT token.
  Future<Response> setDefaultAddress(String addressId) async { 
    try {
      // Sử dụng PUT /api/addresses/:addressId/set-default
      final response = await apiClient.putData('${ApiConstants.ADDRESSES_SET_DEFAULT_BASE}/$addressId${ApiConstants.ADDRESSES_ACTION_SET_DEFAULT}', {});
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi đặt địa chỉ mặc định: ${e.toString()}');
    }
  }
  
  /// Lấy địa chỉ mặc định của người dùng hiện tại.
  /// Backend API: GET /api/addresses/default/user/:userId (Admin get default address for a specific user by user ID)
  /// Danh sách API không có endpoint riêng cho user lấy địa chỉ mặc định của chính mình.
  /// Giả sử rằng địa chỉ mặc định sẽ có flag isDefault=true trong danh sách địa chỉ lấy từ fetchAddressesForCurrentUser()
  /// Nếu có endpoint riêng, bạn cần thêm vào ApiConstants và gọi ở đây.
  // Future<Response> getDefaultAddressForCurrentUser() async { 
  //   try {
  //     // Ví dụ nếu có endpoint GET /api/addresses/default
  //     // final response = await apiClient.getData("/addresses/default"); 
  //     // return response;
  //     throw UnimplementedError("API endpoint for getting current user's default address is not defined in the provided list.");
  //   } catch (e) {
  //     return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy địa chỉ mặc định: ${e.toString()}');
  //   }
  // }

  /// Lấy một địa chỉ cụ thể bằng ID của nó (user chỉ nên lấy được địa chỉ của chính mình).
   Future<Response> getSpecificAddress(String addressId) async {
    try {
      // Sử dụng GET /api/addresses/:addressId
      final response = await apiClient.getData('${ApiConstants.ADDRESSES_BASE}/$addressId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy chi tiết địa chỉ: ${e.toString()}');
    }
  }
}
