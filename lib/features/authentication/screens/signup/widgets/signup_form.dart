import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Đảm bảo đường dẫn đúng
import 'package:flutter_application_jin/features/authentication/models/user_model.dart';
// import 'package:flutter_application_jin/features/authentication/screens/verifyOTP/otp_screen.dart'; // Bỏ nếu không dùng OTP sau đăng ký
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final RxBool _hidePassword = true.obs;
  final RxBool _hideConfirmPassword = true.obs;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus(); // Bỏ focus trước
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    // Tạo đối tượng User từ form
    // ID sẽ được backend tự tạo, avatar có thể là mặc định hoặc null ban đầu
    final newUser = User(
      id: '', // Backend sẽ tạo
      fullname: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      avatar: Avatar(url: ''), // Avatar mặc định hoặc rỗng
      // Các trường khác có thể có giá trị mặc định hoặc được backend xử lý
    );

    authController.register(newUser);
  }

  @override
  Widget build(BuildContext context) {
    // final dark = HelperFunctions.isDarkMode(context); // Không dùng trong form này
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          // Full Name
          TextFormField(
            controller: _fullNameController,
            expands: false,
            decoration: const InputDecoration(
                labelText: "Họ và tên", prefixIcon: Icon(Iconsax.user)),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Username
          TextFormField(
            controller: _usernameController,
            expands: false,
            decoration: const InputDecoration(
                labelText: "Tên đăng nhập",
                prefixIcon: Icon(Iconsax.user_edit)),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: "Email", prefixIcon: Icon(Iconsax.direct)),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),


          // Password
          Obx(
            () => TextFormField(
              controller: _passwordController,
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
            child: Obx(() => authController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text(AppTexts.createAccount))),
          ),
        ],
      ),
    );
  }
}
