// In lib/utils/http/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient extends GetConnect implements GetxService {
  final String jbaseUrl;
  late Map<String, String> _mainHeaders;
  String _actualToken = '';
  bool _isInitialized = false;

  ApiClient({required this.jbaseUrl}) {
    baseUrl = jbaseUrl;
    timeout = const Duration(seconds: 30);
    
    // Cấu hình request/response interceptors
    _setupInterceptors();
    
    // Khởi tạo headers mặc định
    _initializeHeaders();
    
    // Load token bất đồng bộ
    _loadTokenAndUpdateHeader();
  }

  void _setupInterceptors() {
    // Request interceptor để debug
    httpClient.addRequestModifier<void>((request) {
      print('=== REQUEST DEBUG ===');
      print('Method: ${request.method}');
      print('URL: ${request.url}');
      print('Headers: ${request.headers}');
      if (request.bodyBytes != null) {
        // Avoid converting stream directly here, as it can be consumed
        // and String.fromCharCodes expects Iterable<int>, not Stream<List<int>>.
        print('Body: <has body bytes, see actual request for content>'); 
      } else {
        print('Body: <no body bytes>');
      }
      print('========================');
      return request;
    });

    // Response interceptor để debug
    httpClient.addResponseModifier((request, response) {
      print('=== RESPONSE DEBUG ===');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.bodyString}');
      print('=========================');
      return response;
    });
  }

  void _initializeHeaders() {
    _mainHeaders = {
      ApiConstants.HEADER_CONTENT_TYPE: ApiConstants.APPLICATION_JSON,
      'Accept': ApiConstants.APPLICATION_JSON,
      'Accept-Charset': 'utf-8',
    };
  }

  Future<void> _loadTokenAndUpdateHeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _actualToken = prefs.getString(ApiConstants.TOKEN) ?? '';
      updateHeader(_actualToken);
      _isInitialized = true;
      print('Token loaded: ${_actualToken.isNotEmpty ? "Token exists" : "No token"}');
    } catch (e) {
      print('Error loading token: $e');
      _isInitialized = true;
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _loadTokenAndUpdateHeader();
    }
  }

  void updateHeader(String token) {
    _actualToken = token;
    _mainHeaders = {
      ApiConstants.HEADER_CONTENT_TYPE: ApiConstants.APPLICATION_JSON,
      'Accept': ApiConstants.APPLICATION_JSON,
      'Accept-Charset': 'utf-8',
    };
    
    if (_actualToken.isNotEmpty) {
      _mainHeaders['Authorization'] = 'Bearer $_actualToken';
    }
    
    print('Headers updated with token: ${_actualToken.isNotEmpty ? "Token exists" : "No token"}');
  }

  // Method để lưu token mới
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.TOKEN, token);
      updateHeader(token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Method để xóa token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.TOKEN);
      _actualToken = '';
      updateHeader('');
      print('Token cleared successfully');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  Future<Response> getData(String uri) async {
    await ensureInitialized();
    try {
      print('GET Request to: $baseUrl$uri');
      Response response = await get(uri, headers: _mainHeaders);
      return _handleResponse(response);
    } on SocketException {
      return Response(statusCode: 0, statusText: 'No Internet Connection');
    } on TimeoutException {
      return Response(statusCode: 0, statusText: 'Request Timeout');
    } catch (e) {
      print('GET Error: $e');
      return Response(statusCode: 0, statusText: 'Network Error: ${e.toString()}');
    }
  }

  Future<Response> postData(String uri, dynamic body) async {
    await ensureInitialized();
    try {
      // Chuẩn bị request body
      String requestBody;
      if (body == null) {
        requestBody = '{}';
      } else if (body is String) {
        // Nếu body đã là string, kiểm tra xem có phải JSON hợp lệ không
        try {
          jsonDecode(body);
          requestBody = body;
        } catch (e) {
          // Nếu không phải JSON hợp lệ, wrap trong quotes
          requestBody = jsonEncode(body);
        }
      } else {
        // Encode object/map thành JSON
        requestBody = jsonEncode(body);
      }

      // Tạo headers riêng cho request này
      Map<String, String> requestHeaders = Map.from(_mainHeaders);
      
      print('POST Request Details:');
      print('Full URL: $baseUrl$uri');
      print('Headers: $requestHeaders');
      print('Body: $requestBody');
      print('Body Type: ${body.runtimeType}');

      // Thực hiện POST request
      Response response = await post(
        uri,
        requestBody,
        headers: requestHeaders,
      );

      return _handleResponse(response);
      
    } on SocketException {
      print('No Internet Connection');
      return Response(statusCode: 0, statusText: 'No Internet Connection');
    } on TimeoutException {
      print('Request Timeout');
      return Response(statusCode: 0, statusText: 'Request Timeout');
    } on FormatException catch (e) {
      print('JSON Format Error: $e');
      return Response(statusCode: 0, statusText: 'Invalid JSON Format: ${e.toString()}');
    } catch (e) {
      print('POST Error: $e');
      return Response(statusCode: 0, statusText: 'Network Error: ${e.toString()}');
    }
  }

  Future<Response> patchData(String uri, dynamic body) async {
    await ensureInitialized();
    try {
      String requestBody = body is String ? body : jsonEncode(body);
      print('PATCH Request to: $baseUrl$uri');
      print('Body: $requestBody');
      
      Response response = await patch(uri, requestBody, headers: _mainHeaders);
      return _handleResponse(response);
    } on SocketException {
      return Response(statusCode: 0, statusText: 'No Internet Connection');
    } on TimeoutException {
      return Response(statusCode: 0, statusText: 'Request Timeout');
    } catch (e) {
      print('PATCH Error: $e');
      return Response(statusCode: 0, statusText: 'Network Error: ${e.toString()}');
    }
  }

  Future<Response> putData(String uri, dynamic body) async {
    await ensureInitialized();
    try {
      String requestBody = body is String ? body : jsonEncode(body);
      print('PUT Request to: $baseUrl$uri');
      print('Body: $requestBody');
      
      Response response = await put(uri, requestBody, headers: _mainHeaders);
      return _handleResponse(response);
    } on SocketException {
      return Response(statusCode: 0, statusText: 'No Internet Connection');
    } on TimeoutException {
      return Response(statusCode: 0, statusText: 'Request Timeout');
    } catch (e) {
      print('PUT Error: $e');
      return Response(statusCode: 0, statusText: 'Network Error: ${e.toString()}');
    }
  }

  Future<Response> deleteData(String uri) async {
    await ensureInitialized();
    try {
      print('DELETE Request to: $baseUrl$uri');
      Response response = await delete(uri, headers: _mainHeaders);
      return _handleResponse(response);
    } on SocketException {
      return Response(statusCode: 0, statusText: 'No Internet Connection');
    } on TimeoutException {
      return Response(statusCode: 0, statusText: 'Request Timeout');
    } catch (e) {
      print('DELETE Error: $e');
      return Response(statusCode: 0, statusText: 'Network Error: ${e.toString()}');
    }
  }

  // Helper method để xử lý response
  Response _handleResponse(Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    // Log status codes để debug
    switch (response.statusCode) {
      case ApiConstants.SUCCESS:
        print('Request successful');
        break;
      case ApiConstants.CREATED:
        print('Resource created');
        break;
      case ApiConstants.BAD_REQUEST:
        print('Bad Request - Check your data');
        break;
      case ApiConstants.UNAUTHORIZED:
        print('Unauthorized - Check your token');
        break;
      case ApiConstants.NOT_FOUND:
        print('Not Found - Check your endpoint');
        break;
      case ApiConstants.INTERNAL_SERVER_ERROR:
        print('Server Error');
        break;
      default:
        print('Unexpected status code: ${response.statusCode}');
    }
    
    return response;
  }

  // Helper method để tạo URL đầy đủ (useful cho debug)
  String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}