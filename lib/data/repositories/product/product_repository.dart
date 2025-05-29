import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/http/api_client.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxService{
  final ApiClient apiClient;
  ProductRepository({required this.apiClient});

  Future<Response> allProductList() async {
    return await apiClient.getData(ApiConstants.ALL_PRODUCT_URI);
  }

  Future<Response> productByCategoryList() async {
    return await apiClient.getData(ApiConstants.PRODUCT_BY_CATEGORY_URI_BASE);
  }

  Future<Response> allDiscount() async {
    return await apiClient.getData(ApiConstants.DISCOUNT);
  }

   Future<Response> discount() async {
    return await apiClient.getData(ApiConstants.SINGLE_DISCOUNT_URI_BASE);
  }


}