import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static const String baseUrl = 'http://localhost:1000/api/address'; // Change this to your actual API URL
  String token;

  AddressService({required this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  // Headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Get all addresses of current user
  Future<List<dynamic>> getAllAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  // Get specific address by ID
  Future<Map<String, dynamic>> getAddressById(String addressId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$addressId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to fetch address details: $e');
    }
  }

  // Add new address
  Future<Map<String, dynamic>> addAddress({
    required String fullName,
    required String phone,
    required String province,
    required String district,
    required String ward,
    required String streetAddress,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: _headers,
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'province': province,
          'district': district,
          'ward': ward,
          'streetAddress': streetAddress,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Update address
  Future<Map<String, dynamic>> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? streetAddress,
    bool? isDefault,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (province != null) 'province': province,
        if (district != null) 'district': district,
        if (ward != null) 'ward': ward,
        if (streetAddress != null) 'streetAddress': streetAddress,
        if (isDefault != null) 'isDefault': isDefault,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/$addressId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$addressId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Set default address
  Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$addressId/set-default'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  // Error handling helper method
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 403) {
      return ForbiddenException('Access forbidden');
    } else if (response.statusCode == 404) {
      return NotFoundException('Address not found');
    } else {
      return Exception('Failed with status code: ${response.statusCode}');
    }
  }
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
} 