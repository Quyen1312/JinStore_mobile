import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class UserRepository extends GetxService{
  final ApiClient apiClient;
  UserRepository({required this.apiClient});

  Future<Response> userInfo() async {
    return await apiClient.getData(ApiConstants.USER_INFO);
  }

  Future<Response> editUserInfo(User user) async {
    try {
      return await apiClient.patchData(ApiConstants.EDIT_INFO_USER, user.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

   Future<Response> address() async {
    return await apiClient.getData(ApiConstants.ADDRESS);
  }

  Future<Response> addUserAddress(AddressModel addressModel) async {
    try {
      return await apiClient.postData(ApiConstants.ADD_ADDRESS, addressModel.toJson());
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }


}