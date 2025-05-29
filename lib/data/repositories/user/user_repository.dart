import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class UserRepository extends GetxService {
  final ApiClient apiClient;
  UserRepository({required this.apiClient});

  Future<Response> userInfo() async {
    try {
      // Endpoint này là /api/user (đã có trong AuthRepository là fetchUserInfo)
      // Hoặc nếu backend có /api/users/:id để lấy thông tin user thì dùng nó
      // Hoặc /api/auth/me. Bạn cần xác định đúng endpoint lấy thông tin user hiện tại.
      // Tạm thời giả định ApiConstants.USER_INFO là "/user" và nó lấy user hiện tại qua token
      final response = await apiClient.getData(ApiConstants.USER_INFO);
      return response;
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  Future<Response> editUserInfo(User user) async {
    try {
      // ApiConstants.EDIT_INFO_USER đang hardcode ID.
      // API cập nhật user thường là PUT /api/user (cập nhật user hiện tại qua token)
      // hoặc PUT /api/users/:id
      // Bạn cần sửa lại ApiConstants.EDIT_INFO_USER hoặc cách gọi API này.
      // Ví dụ nếu cập nhật user hiện tại qua token:
      // return await apiClient.putData(ApiConstants.USER_INFO, user.toJson()); 
      // Hoặc nếu cần ID:
      return await apiClient.postData('${ApiConstants.USER_INFO}/${user.id}', user.toJson()); // Giả sử USER_INFO là "/users"
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Lỗi cập nhật thông tin người dùng: ${e.toString()}');
    }
  }

  // Sửa phương thức này để nhận userId
  Future<Response> fetchAddressesByUserId(String userId) async {
    try {
      // Gọi đến /api/addresses/user/:userId
      final response = await apiClient.getData('${ApiConstants.ADDRESSES_BY_USER_BASE_URI}/$userId');
      return response;
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Lỗi lấy danh sách địa chỉ: ${e.toString()}');
    }
  }

  Future<Response> addUserAddress(AddressModel addressModel) async {
    try {
      // API backend là POST /api/addresses/ (do router.post('/', ...))
      // Vậy ApiConstants.ADD_ADDRESS_URI nên là "/addresses"
      // Nếu ApiConstants.ADD_ADDRESS_URI = "/addresses/add" thì cần sửa constant hoặc backend route.
      // Giả sử ApiConstants.ADD_ADDRESS_URI = "/addresses"
      return await apiClient.postData(ApiConstants.ADD_ADDRESS_URI, addressModel.toJson());
    } catch (e) {
      return Response(statusCode: 500, statusText: 'Lỗi thêm địa chỉ: ${e.toString()}');
    }
  }
  
  // Thêm các phương thức khác nếu cần: updateAddress, deleteAddress, setDefaultAddress, getDefaultAddress
}
