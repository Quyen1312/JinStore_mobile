import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/service/address_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final AddressService _addressService = Get.find<AddressService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Address> addresses = <Address>[].obs;
  final Rx<Address?> selectedAddress = Rx<Address?>(null);
  final Rx<Address?> defaultAddress = Rx<Address?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(_authController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchAddressesOfCurrentUser();
      } else {
        addresses.clear();
        selectedAddress.value = null;
        defaultAddress.value = null;
      }
    });
    if (_authController.isLoggedIn.value) {
      fetchAddressesOfCurrentUser();
    }
  }

  Future<void> fetchAddressesOfCurrentUser() async {
    try {
      isLoading.value = true;
      error.value = '';
      final addressList = await _addressService.getAddressesOfCurrentUser();
      addresses.assignAll(addressList);

      if (addresses.isNotEmpty) {
        // Tìm địa chỉ được đánh dấu là isDefault
        final Address? foundDefault = addresses.firstWhereOrNull((addr) => addr.isDefault);
        if (foundDefault != null) {
          defaultAddress.value = foundDefault;
        } else {
          // Nếu không có địa chỉ nào isDefault, chọn địa chỉ đầu tiên làm mặc định (nếu danh sách không rỗng)
          defaultAddress.value = addresses.first;
        }

        // Nếu selectedAddress chưa được set và đã có defaultAddress, gán selectedAddress bằng defaultAddress
        if (selectedAddress.value == null && defaultAddress.value != null) {
          selectedAddress.value = defaultAddress.value;
        }
      } else {
        // Nếu không có địa chỉ nào, đặt cả default và selected là null
        defaultAddress.value = null;
        selectedAddress.value = null;
      }
    } catch (e) {
      print("AddressController fetchAddressesOfCurrentUser Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải địa chỉ', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Address>> fetchAddressesByUserIdAdmin(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final addressList = await _addressService.getAddressesByUserIdAdmin(userId);
      return addressList;
    } catch (e) {
      print("AddressController fetchAddressesByUserIdAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải địa chỉ người dùng', message: e.toString());
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewAddress({
    required String detailed,
    required String district,
    required String city,
    required String province,
    bool isDefaultAddress = false,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Gọi API thêm address và dùng response data trực tiếp
      final newAddress = await _addressService.addAddress(
        detailed: detailed,
        district: district,
        city: city,
        province: province,
        isDefault: isDefaultAddress,
      );

      print("Address created successfully: ${newAddress.id}");

      // Thêm address mới vào list
      addresses.add(newAddress);

      // Cập nhật default và selected address
      if (newAddress.isDefault) {
        // Cập nhật các address khác thành không default
        for (int i = 0; i < addresses.length - 1; i++) {
          if (addresses[i].isDefault) {
            addresses[i] = addresses[i].copyWith(isDefault: false);
          }
        }
        defaultAddress.value = newAddress;
        selectedAddress.value = newAddress;
      } else if (addresses.length == 1) {
        // Nếu đây là address đầu tiên, set làm default
        defaultAddress.value = newAddress;
        selectedAddress.value = newAddress;
      }

      Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ mới đã được thêm.');
    } catch (e) {
      print("AddressController addNewAddress Error: $e");
      error.value = e.toString();
      
      // Fallback: refresh list nếu có lỗi
      try {
        print("Error occurred, refreshing list to check if address was created...");
        await fetchAddressesOfCurrentUser();
        Loaders.warningSnackBar(
          title: 'Cảnh báo', 
          message: 'Có lỗi xảy ra nhưng địa chỉ có thể đã được thêm. Vui lòng kiểm tra.'
        );
      } catch (refreshError) {
        Loaders.errorSnackBar(title: 'Lỗi thêm địa chỉ', message: e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editAddress({
    required String addressId,
    String? detailed,
    String? district,
    String? city,
    String? province,
    bool? isDefaultAddress,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Gọi API update address và dùng response data trực tiếp
      final updatedAddress = await _addressService.updateAddress(
        addressId: addressId,
        detailed: detailed,
        district: district,
        city: city,
        province: province,
        isDefault: isDefaultAddress,
      );

      print("Address updated successfully: ${updatedAddress.id}");

      // Cập nhật address trong list
      final index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        addresses[index] = updatedAddress;

        // Cập nhật default và selected address
        if (updatedAddress.isDefault) {
          // Cập nhật các address khác thành không default
          for (int i = 0; i < addresses.length; i++) {
            if (i != index && addresses[i].isDefault) {
              addresses[i] = addresses[i].copyWith(isDefault: false);
            }
          }
          defaultAddress.value = updatedAddress;
        }

        // Cập nhật selectedAddress nếu đó là address đang được chọn
        if (selectedAddress.value?.id == addressId) {
          selectedAddress.value = updatedAddress;
        }
      }

      Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ đã được cập nhật.');
    } catch (e) {
      print("AddressController editAddress Error: $e");
      error.value = e.toString();
      
      // Fallback: refresh list nếu có lỗi
      try {
        await fetchAddressesOfCurrentUser();
        Loaders.warningSnackBar(
          title: 'Cảnh báo', 
          message: 'Có lỗi xảy ra nhưng địa chỉ có thể đã được cập nhật.'
        );
      } catch (refreshError) {
        Loaders.errorSnackBar(title: 'Lỗi cập nhật địa chỉ', message: e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeAddress(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Gọi API xóa address
      await _addressService.deleteAddress(addressId);

      print("Address deleted successfully: $addressId");

      // Xóa address khỏi list
      final removedAddress = addresses.firstWhereOrNull((addr) => addr.id == addressId);
      addresses.removeWhere((addr) => addr.id == addressId);

      // Cập nhật default và selected address
      if (removedAddress?.isDefault == true && addresses.isNotEmpty) {
        // Nếu xóa default address, set address đầu tiên làm default
        addresses[0] = addresses[0].copyWith(isDefault: true);
        defaultAddress.value = addresses[0];
      } else if (addresses.isEmpty) {
        defaultAddress.value = null;
      }

      // Reset selectedAddress nếu địa chỉ đã xóa đang được chọn
      if (selectedAddress.value?.id == addressId) {
        selectedAddress.value = defaultAddress.value;
      }

      Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ đã được xóa.');
    } catch (e) {
      print("AddressController removeAddress Error: $e");
      error.value = e.toString();
      
      // Fallback: refresh list nếu có lỗi
      try {
        await fetchAddressesOfCurrentUser();
        Loaders.warningSnackBar(
          title: 'Cảnh báo', 
          message: 'Có lỗi xảy ra nhưng địa chỉ có thể đã được xóa.'
        );
      } catch (refreshError) {
        Loaders.errorSnackBar(title: 'Lỗi xóa địa chỉ', message: e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDefaultAddress(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Gọi API set default
      await _addressService.setDefaultAddress(addressId);

      print("Default address set successfully: $addressId");

      // Cập nhật trạng thái isDefault trong list
      for (int i = 0; i < addresses.length; i++) {
        if (addresses[i].id == addressId) {
          addresses[i] = addresses[i].copyWith(isDefault: true);
          defaultAddress.value = addresses[i];
        } else if (addresses[i].isDefault) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }

      Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ mặc định đã được cập nhật.');
    } catch (e) {
      print("AddressController selectDefaultAddress Error: $e");
      error.value = e.toString();
      
      // Fallback: refresh list nếu có lỗi
      try {
        await fetchAddressesOfCurrentUser();
        Loaders.warningSnackBar(
          title: 'Cảnh báo', 
          message: 'Có lỗi xảy ra nhưng địa chỉ mặc định có thể đã được cập nhật.'
        );
      } catch (refreshError) {
        Loaders.errorSnackBar(title: 'Lỗi đặt địa chỉ mặc định', message: e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAddress(String addressId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final address = addresses.firstWhereOrNull((addr) => addr.id == addressId);
      if (address != null) {
        selectedAddress.value = address;
      } else {
        final fetchedAddress = await _addressService.getAddressById(addressId);
        selectedAddress.value = fetchedAddress;
        // Cân nhắc thêm hoặc cập nhật địa chỉ này vào list addresses nếu nó chưa có
        if (!addresses.any((a) => a.id == fetchedAddress.id)) {
            addresses.add(fetchedAddress);
        } else {
            int index = addresses.indexWhere((a) => a.id == fetchedAddress.id);
            addresses[index] = fetchedAddress;
        }
      }
    } catch (e) {
      print("AddressController selectAddress Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi chọn địa chỉ', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Address?> fetchDefaultAddressByUserIdAdmin(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final address = await _addressService.getDefaultAddressByUserIdAdmin(userId);
      return address;
    } catch (e) {
      print("AddressController fetchDefaultAddressByUserIdAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải địa chỉ mặc định', message: e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedAddress(Address? address) {
    if (address == null) return '';
    return address.formattedAddress;
  }
}