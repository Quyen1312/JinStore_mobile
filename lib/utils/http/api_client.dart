// In lib/utils/http/api_client.dart
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class ApiClient extends GetConnect implements GetxService {
  final String jbaseUrl; // Renamed from appBaseUrl to avoid conflict with GetConnect's baseUrl
  late Map<String, String> _mainHeaders;
  String _actualToken = ''; // Use this to store the actual token string

  ApiClient({required this.jbaseUrl}) {
    baseUrl = jbaseUrl; // Set GetConnect's baseUrl
    timeout = const Duration(seconds: 30);
    // Initialize headers. The token will be loaded asynchronously and headers updated.
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ', // Start with an empty or placeholder token
    };
    _loadTokenAndUpdateHeader(); // Method to load token from SharedPreferences
  }

  Future<void> _loadTokenAndUpdateHeader() async {
    final prefs = await SharedPreferences.getInstance();
    // Load the stored token using the correct key from ApiConstants
    _actualToken = prefs.getString(ApiConstants.TOKEN) ?? '';
    updateHeader(_actualToken); // Update headers with the loaded token
  }

  void updateHeader(String token) {
    _actualToken = token; // Store the current token
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_actualToken', // Use the actual token value
    };
    // If using defaultSendPort or similar global GetConnect configurations,
    // you might need to update those as well if they don't pick up _mainHeaders automatically.
    // For instance, if GetConnect uses a default httpClient instance:
    // httpClient.addRequestModifier<void>((request) {
    //   request.headers['Authorization'] = 'Bearer $_actualToken';
    //   return request;
    // });
  }

  Future<Response> getData(String uri) async { // Removed trailing comma
    try {
      // Pass headers explicitly to ensure they are used.
      Response response = await get(uri, headers: _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, dynamic body) async {
    try {
      Response response = await post(uri, body, headers: _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> patchData(String uri, dynamic body) async {
    try {
      Response response = await patch(uri, body, headers: _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  // New putData method
  Future<Response> putData(String uri, dynamic body) async {
    try {
      Response response = await put(uri, body, headers: _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> deleteData(String uri, {dynamic body}) async { // Made body optional for delete
    try {
      // For DELETE requests, GetConnect's delete method might not always expect a body.
      // If your backend requires a body for DELETE, ensure it's handled correctly.
      // If no body is needed, you can call: await delete(uri, headers: _mainHeaders);
      Response response = await delete(uri, headers: _mainHeaders); // Removed body if not standard for your DELETE
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}
