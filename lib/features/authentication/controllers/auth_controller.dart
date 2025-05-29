import 'package:flutter_application_jin/data/repositories/authentication/auth_repository.dart';
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  var isLoading = false.obs;
  var isAuthenticated = false.obs; // To track authentication status

  AuthController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await authRepository.getUserToken();
    isAuthenticated.value = token != null && token.isNotEmpty;
  }

  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      final response = await authRepository.login(identifier: identifier, password: password);
      if (response.statusCode == 200 || response.statusCode == 201) {
        isAuthenticated.value = true;
        Get.snackbar('Success', response.body['message'] ?? 'Login successful');
        // Navigate to home or dashboard screen
        Get.offAllNamed('/home'); // Example navigation
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(User user) async {
    try {
      isLoading.value = true;
      final response = await authRepository.register(user);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', response.body['message'] ?? 'Registration successful');
        // Navigate to login or OTP screen
        Get.toNamed('/login'); // Example navigation
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Registration failed');
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
      await authRepository.logout();
      await authRepository.clearToken();
      isAuthenticated.value = false;
      Get.snackbar('Success', 'Logout successful');
      // Navigate to login screen
      Get.offAllNamed('/login'); // Example navigation
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
        Get.snackbar('Success', response.body['message'] ?? 'Password reset email sent');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to send password reset email');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(User userWithNewPassword) async {
    try {
      isLoading.value = true;
      final response = await authRepository.changePassword(userWithNewPassword);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', response.body['message'] ?? 'Password changed successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(VerifyOTPModel otpModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.verifyOTP(otpModel);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', response.body['message'] ?? 'OTP verified successfully');
        // Navigate to a relevant screen, e.g., home or set new password
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOTP(VerifyOTPModel otpModel) async {
    try {
      isLoading.value = true;
      final response = await authRepository.sendOTP(otpModel);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', response.body['message'] ?? 'OTP sent successfully');
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
} 