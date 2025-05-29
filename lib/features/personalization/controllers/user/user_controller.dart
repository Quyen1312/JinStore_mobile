import 'package:flutter_application_jin/data/repositories/user/user_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final UserRepository userRepository;

  // Reactive variables to manage user and address data
  var user = Rxn<User>(); // Reactive user model (null if not fetched)
  var addressList = <AddressModel>[].obs; // Reactive list of addresses
  var isLoading = false.obs; // Loading state for UI updates
  var isUpdating = false.obs; 
  var isAddingAddress = false.obs;

  UserController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo(); // Fetch user info on initialization
    fetchAddresses(); // Fetch addresses on initialization
  }

  // Fetch user information
  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = true;
      final response = await userRepository.userInfo();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        user.value = User.fromJson(response.body['data']);
        Get.snackbar('Success', 'User information loaded');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load user information');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Edit user information
  Future<void> editUserInfo(User updatedUser) async {
    try {
      isUpdating.value = true;
      final response = await userRepository.editUserInfo(updatedUser);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        user.value = User.fromJson(response.body['data']);
        Get.snackbar('Success', 'User information updated successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update user information');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  // Fetch user addresses
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final response = await userRepository.address();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body['data'];
        addressList.value = data.map((item) => AddressModel.fromJson(item)).toList();
        Get.snackbar('Success', 'Addresses loaded successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to load addresses');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new user address
  Future<void> addUserAddress(AddressModel newAddress) async {
    try {
      isAddingAddress.value = true;
      final response = await userRepository.addUserAddress(newAddress);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        addressList.add(AddressModel.fromJson(response.body['data']));
        Get.snackbar('Success', 'Address added successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isAddingAddress.value = false;
    }
  }
}