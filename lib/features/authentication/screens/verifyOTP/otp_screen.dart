import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
// import 'package:flutter_application_jin/features/shop/screens/home/home.dart'; // Keep if needed for navigation after success
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({Key? key, this.userId, this.emailOrPhone}) : super(key: key); // Removed const, added parameters

  final String? userId; // To know which user's OTP to verify, passed from previous screen
  final String? emailOrPhone; // For display purposes or if needed by VerifyOTPModel
  final AuthController authController = Get.find<AuthController>();
  final RxString otpCode = ''.obs; // To store the entered OTP

  @override
  Widget build(BuildContext context) {
    // Display a more specific subtitle if email/phone is available
    final String subTitle = emailOrPhone != null 
        ? "${AppTexts.otpSubTitle.toUpperCase()}\nFor $emailOrPhone"
        : AppTexts.otpSubTitle.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")), // Added AppBar for context
      body: Container(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.otpTitle,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 80.0),
            ),
            Text(subTitle, 
                 style: Theme.of(context).textTheme.headlineSmall, // Adjusted style
                 textAlign: TextAlign.center),
            const SizedBox(height: 40.0),
            OtpTextField(
              mainAxisAlignment: MainAxisAlignment.center,
              numberOfFields: 6,
              fillColor: AppColors.buttonPrimary.withOpacity(0.1),
              filled: true,
              onSubmit: (code) {
                otpCode.value = code;
              },
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
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
                          Get.snackbar('Error', 'User information is missing. Cannot verify OTP.');
                        } else {
                          Get.snackbar('Error', 'Please enter the 6-digit OTP.');
                        }
                      },
                      child: const Text("Verify"))), // Changed text to "Verify"
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            // Optional: Resend OTP Button
            TextButton(
              onPressed: () {
                if (userId != null) {
                  // Assuming your AuthController has a method like sendOTPForExistingUser
                  // Or you use the existing sendOTP if it can handle resends
                  authController.sendOTP(VerifyOTPModel(id: '', user: userId!));
                }
              },
              child: const Text("Resend OTP"),
            )
          ],
        ),
      ),
    );
  }
}