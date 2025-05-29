import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Đảm bảo đúng đường dẫn
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sử dụng iconsax_flutter
import 'package:flutter_application_jin/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart'; // Giả sử bạn có file validators

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Lấy AuthController đã được khởi tạo trong dependencies
  final AuthController authController = AuthController.instance; // Sử dụng instance

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Thêm GlobalKey cho Form
  final RxBool isPasswordVisible = false.obs;
  final RxBool isRememberMe = false.obs; // Nếu bạn có logic "Remember Me"

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Gán key cho Form
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
        child: Column(
          children: [
            // Username or Email
            TextFormField(
              controller: identifierController,
              validator: (value) => Validator.validateEmptyText('Identifier', value), // Thêm validator
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: 'Tên đăng nhập hoặc Email', // Dịch sang tiếng Việt
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwInputFields),

            // Password
            Obx(
              () => TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible.value,
                validator: (value) => Validator.validatePassword(value), // Thêm validator
                decoration: InputDecoration(
                  labelText: 'Mật khẩu', // Dịch sang tiếng Việt
                  prefixIcon: const Icon(Iconsax.password_check), // Thay đổi icon
                  suffixIcon: IconButton(
                    onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                    icon: Icon(isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        Checkbox(
                          value: isRememberMe.value,
                          onChanged: (value) => isRememberMe.value = value ?? false,
                        ),
                        const Text('Ghi nhớ tôi'), // Dịch
                      ],
                    )),
                TextButton(
                  onPressed: () => Get.to(() => ForgotPassword()), // Đảm bảo ForgotPassword là const nếu có thể
                  child: const Text('Quên mật khẩu?'), // Dịch
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {

                         FocusScope.of(context).unfocus(); 
                        if (_formKey.currentState!.validate()) { // Validate form trước khi submit
                          // Xử lý logic "Remember Me" nếu cần (lưu identifier)
                          authController.login(
                            identifierController.text.trim(),
                            passwordController.text.trim()
                          );
                        }
                      },
                      child: const Text('Đăng nhập'), // Dịch
                    ),
              )
            ),

            const SizedBox(height: AppSizes.spaceBtwItems),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()), // Đổi tên Signup() thành SignupScreen() cho nhất quán
                child: const Text('Tạo tài khoản'), // Dịch
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}