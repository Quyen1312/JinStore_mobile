import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class CategoryRepository extends GetxService{
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  Future<Response> fetchAllCategory() async {
    try {
      final response = await apiClient.getData(ApiConstants.CATEGORIES_BASE);
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy danh sách danh mục: ${e.toString()}');
    }
  }
  Future<Response> fetchCategoryById(String categoryId) async {
    try {
      final response = await apiClient.getData('${ApiConstants.CATEGORIES_BASE}/$categoryId');
      return response;
    } catch (e) {
      return Response(statusCode: ApiConstants.INTERNAL_SERVER_ERROR, statusText: 'Lỗi lấy danh sách danh mục: ${e.toString()}');
    }
  }


}