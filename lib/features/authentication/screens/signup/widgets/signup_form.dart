import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final AuthController authController = AuthController.instance;
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final RxBool _hidePassword = true.obs;
  final RxBool _hideConfirmPassword = true.obs;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_signupFormKey.currentState!.validate()) return;

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Lỗi',
        'Mật khẩu không khớp',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    authController.register(
      fullname: _fullNameController.text.trim(),
      username: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          // Full Name
          TextFormField(
            controller: _fullNameController,
            validator: (value) => Validators.validateFullName(value),
            decoration: const InputDecoration(
              labelText: "Họ và tên",
              prefixIcon: Icon(Iconsax.user),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Email
          TextFormField(
            controller: _emailController,
            validator: (value) => Validators.validateEmail(value),
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Password
          Obx(
            () => TextFormField(
              controller: _passwordController,
              validator: (value) => Validators.validatePassword(value),
              obscureText: _hidePassword.value,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => _hidePassword.value = !_hidePassword.value,
                  icon: Icon(_hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Confirm Password
          Obx(
            () => TextFormField(
              controller: _confirmPasswordController,
              validator: (value) => Validators.validatePassword(value),
              obscureText: _hideConfirmPassword.value,
              decoration: InputDecoration(
                labelText: "Nhập lại mật khẩu",
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => _hideConfirmPassword.value = !_hideConfirmPassword.value,
                  icon: Icon(_hideConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwSections),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                onPressed: authController.isLoading.value ? null : _handleRegister,
                child: authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text(AppTexts.createAccount),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
