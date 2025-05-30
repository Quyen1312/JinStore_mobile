import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:flutter_application_jin/features/authentication/screens/password_configuration/forget_password.dart'; // Không cần nữa
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
        child: Column(
          children: [
            TextFormField(
              controller: identifierController,
              validator: (value) => Validator.validateEmptyText('Tên đăng nhập hoặc Email', value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: 'Tên đăng nhập hoặc Email',
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwInputFields),
            Obx(
              () => TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible.value,
                validator: (value) => Validator.validatePassword(value),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                    icon: Icon(isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwInputFields / 2),
                // --- NÚT "QUÊN MẬT KHẨU?" ĐÃ ĐƯỢC BỎ ---
                // TextButton(
                //   onPressed: () => Get.to(() => const ForgotPasswordScreen()), // Đảm bảo tên class đúng
                //   child: const Text('Quên mật khẩu?'),
                // ),
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          authController.login(
                            identifierController.text.trim(),
                            passwordController.text.trim()
                          );
                        }
                      },
                      child: const Text('Đăng nhập'),
                    ),
              )
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()), // Đảm bảo SignupScreen là tên đúng
                child: const Text('Tạo tài khoản'),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ]
        ),
      )
    );
  }
}
