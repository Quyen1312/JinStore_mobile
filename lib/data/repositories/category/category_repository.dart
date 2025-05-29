import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class CategoryRepository extends GetxService{
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  Future<Response> allCategoryList() async {
    return await apiClient.getData(ApiConstants.ALL_CATEGORY);
  }

  Future<Response> category() async {
    return await apiClient.getData(ApiConstants.CATEGORY);
  }


}