import 'package:get/get.dart';
import 'package:flutter_application_jin/service/address/address_service.dart';

class AddressController extends GetxController {
  final AddressService _addressService = Get.find<AddressService>();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> currentAddress = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> defaultAddress = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAddresses();
  }

  Future<void> fetchUserAddresses() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final addressList = await _addressService.getAllAddresses();
      addresses.value = List<Map<String, dynamic>>.from(addressList);
      
      // Set default address if exists
      final defaultAddr = addresses.firstWhere(
        (addr) => addr['isDefault'] == true,
        orElse: () => <String, dynamic>{},
      );
      if (defaultAddr.isNotEmpty) {
        defaultAddress.value = defaultAddr;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAddress({
    required String fullName,
    required String phone,
    required String province,
    required String district,
    required String ward,
    required String streetAddress,
    bool isDefault = false,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final newAddress = await _addressService.addAddress(
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        streetAddress: streetAddress,
        isDefault: isDefault,
      );
      
      // If this is set as default, update the default address
      if (isDefault) {
        defaultAddress.value = newAddress;
      }
      
      // Refresh address list
      await fetchUserAddresses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress({
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
      isLoading.value = true;
      error.value = '';
      
      final updatedAddress = await _addressService.updateAddress(
        addressId: addressId,
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        streetAddress: streetAddress,
        isDefault: isDefault,
      );
      
      // Update current address if it matches
      if (currentAddress.value['id'] == addressId) {
        currentAddress.value = updatedAddress;
      }
      
      // Update default address if this is the new default
      if (isDefault == true) {
        defaultAddress.value = updatedAddress;
      }
      
      // Refresh address list
      await fetchUserAddresses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _addressService.deleteAddress(addressId);
      
      // Clear current address if it matches
      if (currentAddress.value['id'] == addressId) {
        currentAddress.value = {};
      }
      
      // Clear default address if it matches
      if (defaultAddress.value['id'] == addressId) {
        defaultAddress.value = {};
      }
      
      // Refresh address list
      await fetchUserAddresses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final updatedAddress = await _addressService.setDefaultAddress(addressId);
      defaultAddress.value = updatedAddress;
      
      // Refresh address list to update isDefault status for all addresses
      await fetchUserAddresses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAddressById(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final address = await _addressService.getAddressById(addressId);
      currentAddress.value = address;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to format full address
  String getFullAddress(Map<String, dynamic> address) {
    return '${address['streetAddress']}, ${address['ward']}, ${address['district']}, ${address['province']}';
  }

  // Helper method to check if address is complete
  bool isAddressComplete(Map<String, dynamic> address) {
    return address['fullName']?.isNotEmpty == true &&
           address['phone']?.isNotEmpty == true &&
           address['province']?.isNotEmpty == true &&
           address['district']?.isNotEmpty == true &&
           address['ward']?.isNotEmpty == true &&
           address['streetAddress']?.isNotEmpty == true;
  }
} 