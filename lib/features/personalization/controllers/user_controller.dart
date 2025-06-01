import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter_application_jin/service/user/user_service.dart';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isProfileComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final userData = await _userService.getUserInfo();
      currentUser.value = userData;
      
      checkProfileCompletion();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    String? fullname,
    String? phone,
    File? avatar,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final updatedUser = await _userService.updateProfile(
        fullname: fullname,
        phone: phone,
        avatar: avatar,
      );
      
      currentUser.value = updatedUser;
      checkProfileCompletion();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      Get.snackbar(
        'Thành công',
        'Đổi mật khẩu thành công',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _userService.deleteUser(userId);
      
      Get.snackbar(
        'Thành công',
        'Xóa tài khoản thành công',
        snackPosition: SnackPosition.TOP,
      );
      
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to check profile completion
  void checkProfileCompletion() {
    if (currentUser.value == null) {
      isProfileComplete.value = false;
      return;
    }

    final user = currentUser.value!;
    isProfileComplete.value = user.fullname?.isNotEmpty == true && 
                            user.phone?.isNotEmpty == true;
  }

  // Helper method to format user name
  String getFormattedName() {
    return currentUser.value?.fullname ?? '';
  }

  // Helper method to get user avatar URL
  String getAvatarUrl() {
    return currentUser.value?.avatar ?? '';
  }

  // Helper method to get user phone
  String getPhone() {
    return currentUser.value?.phone ?? '';
  }

  // Helper method to check if user is active
  bool isActive() {
    return currentUser.value?.isActive ?? false;
  }
} 