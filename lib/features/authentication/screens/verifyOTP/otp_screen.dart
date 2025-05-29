import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Corrected path
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
// import 'package:flutter_application_jin/features/shop/screens/home/home.dart'; // Keep if needed for navigation after success
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({Key? key, this.userId, this.emailOrPhone}) : super(key: key);

  final String? userId; // To know which user's OTP to verify, passed from previous screen
  final String? emailOrPhone; // For display purposes or if needed by VerifyOTPModel
  final AuthController authController = AuthController.instance; // Use instance
  final RxString otpCode = ''.obs; // To store the entered OTP

  @override
  Widget build(BuildContext context) {
    // Display a more specific subtitle if email/phone is available
    final String subTitle = emailOrPhone != null
        ? "${AppTexts.otpSubTitle.toUpperCase()}\nCHO $emailOrPhone" // Updated for clarity
        : AppTexts.otpSubTitle.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực OTP")), // Added AppBar for context
      body: Container(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.otpTitle, // Should be a short title like "CO\nDE" or "OTP"
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 80.0),
            ),
            Text(subTitle,
                style: Theme.of(context).textTheme.titleMedium, // Adjusted style for better fit
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spaceBtwSections), // Increased spacing
            OtpTextField(
              mainAxisAlignment: MainAxisAlignment.center,
              numberOfFields: 6,
              fillColor: AppColors.buttonPrimary.withOpacity(0.1), // Use your AppColors
              filled: true,
              onSubmit: (code) {
                otpCode.value = code;
                // Optionally, auto-submit if you want
                // if (code.length == 6 && userId != null) {
                //   _verifyOtp();
                // }
              },
              fieldWidth: 50, // Adjust field width
              focusedBorderColor: AppColors.primary, // Use your AppColors
              // styles: List.generate(6, (index) => Theme.of(context).textTheme.headlineMedium), // Style for text in fields
            ),
            const SizedBox(height: AppSizes.spaceBtwSections), // Increased spacing
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _verifyOtp, // Call a separate method
                      child: const Text("XÁC NHẬN"))), // Changed text to "Verify"
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            // Optional: Resend OTP Button
            TextButton(
              onPressed: () {
                if (userId != null) {
                  // Ensure VerifyOTPModel is correctly populated for resend
                  // The backend might only need the 'user' (userId) or 'emailOrPhone' for resend
                  authController.sendOTP(VerifyOTPModel(
                    id: '', // Typically not needed for sending OTP
                    user: userId!,
                    // email: emailOrPhone, // Pass email/phone if your sendOTP API uses it
                  ));
                } else if (emailOrPhone != null) {
                   // If userId is not available but emailOrPhone is (e.g., during password reset before login)
                   // Your sendOTP might need to handle this case, perhaps by taking email/phone directly.
                   // This part depends heavily on your API and AuthController's sendOTP implementation.
                   // For now, assuming sendOTP primarily uses userId.
                   // authController.sendOTP(VerifyOTPModel(id: '', email: emailOrPhone));
                   Get.snackbar('Thông báo', 'Chức năng gửi lại OTP cho $emailOrPhone cần được cấu hình.');
                }
              },
              child: const Text("Gửi lại OTP"),
            )
          ],
        ),
      ),
    );
  }

  void _verifyOtp() {
    if (otpCode.value.length == 6 && userId != null) {
      authController.verifyOTP(VerifyOTPModel(
        id: '', // The backend might not need an ID for VerifyOTPModel itself
        user: userId!,
        otp: otpCode.value,
        // isEmailVerified and isPhoneVerified are typically set by backend
      ));
      // Navigation to HomeScreen or password reset screen should be handled
      // by AuthController based on API response (e.g., via Get.snackbar and Get.to)
    } else if (userId == null) {
      Get.snackbar('Lỗi', 'Thiếu thông tin người dùng. Không thể xác thực OTP.');
    } else {
      Get.snackbar('Lỗi', 'Vui lòng nhập đủ 6 số OTP.');
    }
  }
}
