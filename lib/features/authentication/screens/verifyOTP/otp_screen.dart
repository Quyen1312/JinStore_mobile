import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/models/verify_otp_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({
    Key? key,
    required this.email,
    this.onVerified,
    this.flow = 'emailVerification',
  }) : super(key: key);

  final String email;
  final VoidCallback? onVerified;
  final String flow;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController.instance;
    final RxString otpCode = ''.obs;

    void handleVerifyOTP() {
      if (otpCode.value.length != 6) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập đủ 6 số OTP',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final verifyOTP = VerifyOTP(
        email: email,
        otp: otpCode.value,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      authController.verifyOTP(verifyOTP, flow: flow);
      if (onVerified != null) onVerified!();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác thực OTP"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.spaceBtwSections),
              // Title
              Text(
                "XÁC THỰC\nEMAIL",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              // Subtitle
              Text(
                "Nhập mã OTP đã được gửi đến\n$email",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              // OTP Fields
              OtpTextField(
                numberOfFields: 6,
                fillColor: AppColors.grey.withOpacity(0.1),
                filled: true,
                onSubmit: (code) => otpCode.value = code,
                fieldWidth: 50,
                showFieldAsBox: true,
                borderWidth: 1.0,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : handleVerifyOTP,
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text("XÁC NHẬN"),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              // Resend OTP Button
              TextButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () => authController.sendOTP(email),
                child: const Text("Gửi lại OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
