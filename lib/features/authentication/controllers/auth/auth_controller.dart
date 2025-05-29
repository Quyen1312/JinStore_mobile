import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var user = Rxn<User>();

  AuthController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await authRepository.getUserToken();
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
    }
  }

  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      final response = await authRepository.login(
        identifier: identifier,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoggedIn.value = true;
        Get.snackbar('Success', 'Login successful');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(User userModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.register(userModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Registration successful');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Registration failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await authRepository.logout();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await authRepository.clearToken();
        isLoggedIn.value = false;
        user.value = null;
        Get.snackbar('Success', 'Logout successful');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Logout failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      final response = await authRepository.resetPassword(email);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Password reset email sent');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Password reset failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(User userModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.changePassword(userModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Password changed successfully');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Password change failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.verifyOTP(verifyOTPModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'OTP verified');
      } else {
        Get.snackbar('Error', response.statusText ?? 'OTP verification failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOTP(VerifyOTPModel verifyOTPModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.sendOTP(verifyOTPModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'OTP sent');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
