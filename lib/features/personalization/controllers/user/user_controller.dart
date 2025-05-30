import 'package:flutter_application_jin/data/repositories/user/user_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/utils/constants/api_constants.dart';
import 'package:flutter_application_jin/utils/popups/full_screen_loader.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final UserRepository userRepository;

  var user = Rxn<User>();
  var addresses = <AddressModel>[].obs;
  var selectedAddress = Rxn<AddressModel>(); 
  
  var profileLoading = false.obs; 
  var addressLoading = false.obs; 

  UserController({required this.userRepository});

  // User data and addresses will be fetched by AuthController after login or on app start
  // by calling this setUser method.
  Future<void> setUser(User? newUser) async {
    user.value = newUser;
    if (newUser != null && newUser.id.isNotEmpty) {
      await fetchAddressesForCurrentUser(); // Fetch addresses when user is set
    } else {
      addresses.clear();
      selectedAddress.value = null;
    }
  }

  // --- User Profile ---
  Future<void> updateUserProfile(User userUpdates) async {
    if (user.value == null) {
      Loaders.warningSnackBar(title: 'Chưa đăng nhập', message: 'Vui lòng đăng nhập để cập nhật thông tin.');
      return;
    }
    try {
      profileLoading.value = true;
      // Assuming you have a lottie animation for loading
      FullScreenLoader.openLoadingDialog('Đang cập nhật thông tin...', 'assets/images/animations/loader-animation.json'); 

      // UserRepository.updateUserProfile now takes the user ID and the update payload.
      // We use user.value!.id for the current user.
      // Ensure userUpdates.toUpdateJson() prepares only updatable fields.
      final response = await userRepository.updateUserProfile(userUpdates);

      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.SUCCESS) {
        // Update local user model if backend returns updated user
        // Adjust parsing based on actual API response for PATCH /api/users/info-user/update
        Map<String, dynamic>? updatedUserData;
        if (response.body != null) {
            if (response.body['user'] != null && response.body['user'] is Map<String,dynamic>) {
                updatedUserData = response.body['user'];
            } else if (response.body['data'] != null && response.body['data'] is Map<String,dynamic>) {
                updatedUserData = response.body['data'];
            } else if (response.body is Map<String,dynamic> && (response.body.containsKey('email') || response.body.containsKey('_id'))) {
                updatedUserData = response.body;
            }
        }
        if (updatedUserData != null) {
            user.value = User.fromJson(updatedUserData); // Update the main user observable
        } else {
            // If backend doesn't return the full updated user, refetch or update locally
            // For simplicity, we can refetch, or merge if only partial data is an issue.
            // For now, we assume the API returns the updated user or we update from userUpdates.
            user.value = user.value?.copyWith(
                fullname: userUpdates.fullname,
                phone: userUpdates.phone,
                // etc. for other updatable fields
            );
        }
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Thông tin cá nhân đã được cập nhật.');
        Get.back(); 
      } else {
        Loaders.errorSnackBar(title: 'Lỗi cập nhật', message: response.body?['message'] ?? response.statusText ?? 'Không thể cập nhật thông tin.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi cập nhật thông tin: ${e.toString()}');
    } finally {
      profileLoading.value = false;
    }
  }

  // --- Address Management ---
  Future<void> fetchAddressesForCurrentUser() async {
    if (user.value == null || user.value!.id.isEmpty) {
      return;
    }
    try {
      addressLoading.value = true;
      addresses.clear(); // Clear before fetching
      selectedAddress.value = null; // Clear selected address

      // UserRepository.fetchAddressesForCurrentUser() calls GET /api/addresses/user/all
      final response = await userRepository.fetchAddressesForCurrentUser();

      if (response.statusCode == ApiConstants.SUCCESS) {
        dynamic responseData = response.body;
        List<dynamic> addressDataList;

        if (responseData is Map<String, dynamic> && responseData.containsKey('addresses')  && responseData['addresses'] is List<dynamic>) {
          addressDataList = responseData['addresses'] as List<dynamic>;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data') && responseData['data'] is List<dynamic>) {
          addressDataList = responseData['data'] as List<dynamic>;
        }
         else if (responseData is List<dynamic>) {
          addressDataList = responseData;
        } else {
          // No error if list is empty or format is unexpected, just means no addresses.
          return;
        }
        
        final parsedAddresses = addressDataList
            .map((data) => AddressModel.fromJson(data as Map<String, dynamic>))
            .toList();
        addresses.assignAll(parsedAddresses);

        // After fetching all addresses, find and set the default one
        if (addresses.isNotEmpty) {
            selectedAddress.value = addresses.firstWhereOrNull((addr) => addr.isDefault == true);
            // If no address is marked as default by API, select the first one as a fallback UI default (optional)
            // if (selectedAddress.value == null) {
            //   selectedAddress.value = addresses.first;
            // }
        }

      } else {
        // Loaders.errorSnackBar(title: 'Lỗi', message: response.body?['message'] ?? response.statusText ?? 'Không thể tải danh sách địa chỉ.');
         print("Error fetching addresses: ${response.body?['message'] ?? response.statusText}");
      }
    } catch (e) {
      // Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi tải địa chỉ: ${e.toString()}');
      print("Exception fetching addresses: ${e.toString()}");
    } finally {
      addressLoading.value = false;
    }
  }

  Future<void> addAddress(AddressModel addressModel) async {
    if (user.value == null) {
      Loaders.warningSnackBar(title: 'Chưa đăng nhập', message: 'Vui lòng đăng nhập lại.');
      return;
    }
    try {
      addressLoading.value = true;
      FullScreenLoader.openLoadingDialog('Đang lưu địa chỉ...', 'assets/images/animations/loader-animation.json');

      final response = await userRepository.addAddress(addressModel);
      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.CREATED) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Địa chỉ đã được thêm.');
        
        // API for adding address (POST /api/addresses/add) should return the newly created address with its ID
        AddressModel? newAddress;
        if (response.body != null) {
            if (response.body['address'] != null && response.body['address'] is Map<String,dynamic>) {
                newAddress = AddressModel.fromJson(response.body['address']);
            } else if (response.body['data'] != null && response.body['data'] is Map<String,dynamic>) {
                newAddress = AddressModel.fromJson(response.body['data']);
            } else if (response.body is Map<String,dynamic> && response.body.containsKey('_id')) {
                newAddress = AddressModel.fromJson(response.body);
            }
        }

        await fetchAddressesForCurrentUser(); // Refresh the entire list to be sure

        // If the newly added address was set as default, or if it's the only address, update selectedAddress
        if (newAddress != null && (newAddress.isDefault == true || addresses.length == 1)) {
            await selectAddressAsDefaultApi(newAddress.id); // Call API to set default if needed, or just update local
        } else if (addresses.isNotEmpty && selectedAddress.value == null) {
            // If no default is selected yet, and we have addresses, maybe select the first one.
            // Or wait for explicit default selection.
        }
        Get.back();
      } else {
        Loaders.errorSnackBar(title: 'Lỗi', message: response.body?['message'] ?? response.statusText ?? 'Không thể thêm địa chỉ.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi thêm địa chỉ: ${e.toString()}');
    } finally {
      addressLoading.value = false;
    }
  }

  Future<void> updateSelectedAddress(String addressId, AddressModel addressModel) async {
     if (user.value == null) return;
    try {
      addressLoading.value = true;
      FullScreenLoader.openLoadingDialog('Đang cập nhật địa chỉ...', 'assets/images/animations/loader-animation.json');
      
      final response = await userRepository.updateAddress(addressId, addressModel);
      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.SUCCESS) {
        Loaders.successSnackBar(title: 'Thành công', message: response.body?['message'] ?? 'Địa chỉ đã được cập nhật.');
        await fetchAddressesForCurrentUser(); // Refresh list
        
        // If the updated address was set to default
        if (addressModel.isDefault == true) {
            await selectAddressAsDefaultApi(addressId); // Ensure it's set as default via API if logic requires
        } else {
            // If it was default and now it's not, we might need to fetch the new default or clear it
            if (selectedAddress.value?.id == addressId && addressModel.isDefault != true) {
                selectedAddress.value = null;
                // Optionally, try to find another default or the first address
                if (addresses.isNotEmpty) {
                    selectedAddress.value = addresses.firstWhereOrNull((addr) => addr.isDefault == true);
                }
            }
        }
        Get.back();
      } else {
        Loaders.errorSnackBar(title: 'Lỗi', message: response.body?['message'] ?? response.statusText ?? 'Không thể cập nhật địa chỉ.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi cập nhật địa chỉ: ${e.toString()}');
    } finally {
      addressLoading.value = false;
    }
  }

  Future<void> deleteSelectedAddress(String addressId) async {
    if (user.value == null) return;
    try {
      addressLoading.value = true;
      FullScreenLoader.openLoadingDialog('Đang xóa địa chỉ...', 'assets/images/animations/loader-animation.json');
      
      final response = await userRepository.deleteAddress(addressId);
      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.SUCCESS || response.statusCode == ApiConstants.NO_CONTENT) {
        Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ đã được xóa.');
        addresses.removeWhere((address) => address.id == addressId); // Optimistically update UI
        if (selectedAddress.value?.id == addressId) {
          selectedAddress.value = null; 
          // If there are other addresses, try to set a new default or select the first one
          if (addresses.isNotEmpty) {
            selectedAddress.value = addresses.firstWhereOrNull((addr) => addr.isDefault == true);
            if (selectedAddress.value == null) {
                // selectedAddress.value = addresses.first; // Optionally select first if no default
            }
          }
        }
        // No need to call fetchAddressesForCurrentUser() if we update locally, unless backend logic is complex
      } else {
        Loaders.errorSnackBar(title: 'Lỗi', message: response.body?['message'] ?? response.statusText ?? 'Không thể xóa địa chỉ.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi xóa địa chỉ: ${e.toString()}');
    } finally {
      addressLoading.value = false;
    }
  }
  
  // Call this when user explicitly selects an address as default from the UI
  Future<void> selectAddressAsDefaultApi(String addressId) async {
    if (user.value == null) return;
    try {
      addressLoading.value = true;
      FullScreenLoader.openLoadingDialog('Đang đặt làm mặc định...', 'assets/images/animations/loader-animation.json');

      final response = await userRepository.setDefaultAddress(addressId);
      FullScreenLoader.stopLoading();

      if (response.statusCode == ApiConstants.SUCCESS) {
        // Update local state to reflect the change
        for (var address in addresses) {
          address.isDefault = (address.id == addressId);
        }
        selectedAddress.value = addresses.firstWhereOrNull((addr) => addr.id == addressId);
        addresses.refresh(); // Trigger UI updates
        Loaders.successSnackBar(title: 'Thành công', message: 'Địa chỉ mặc định đã được cập nhật.');
      } else {
        Loaders.errorSnackBar(title: 'Lỗi', message: response.body?['message'] ?? response.statusText ?? 'Không thể đặt địa chỉ mặc định.');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Ôi không!', message: 'Lỗi đặt địa chỉ mặc định: ${e.toString()}');
    } finally {
      addressLoading.value = false;
    }
  }

  // Note: getDefaultAddressByUserId from UserRepository is for admin use as per API list.
  // For current user, default address is identified from the list fetched by fetchAddressesForCurrentUser().
  // The `selectedAddress` observable will hold the default address if found.
}
