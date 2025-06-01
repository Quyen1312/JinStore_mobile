import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:flutter_application_jin/features/authentication/screens/signup/signup.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController usernameOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool isPasswordVisible = false.obs;

  @override
  void dispose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
        child: Column(
          children: [
            TextFormField(
              controller: usernameOrEmailController,
              validator: (value) => Validator.validateEmptyText('Username or Email', value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: 'Username or Email',
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwInputFields),
            Obx(() => TextFormField(
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
                )),
            const SizedBox(height: AppSizes.spaceBtwInputFields / 2),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.to(() => ResetPasswordScreen()),
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Obx(() => authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          authController.login(
                            usernameOrEmail: usernameOrEmailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                        }
                      },
                      child: const Text('Đăng nhập'),
                    )),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: const Text('Tạo tài khoản'),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
