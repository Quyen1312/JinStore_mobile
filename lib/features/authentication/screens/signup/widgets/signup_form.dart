import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/screens/home/home.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Username
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Iconsax.user),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Full Name
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Email
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Phone Number
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Iconsax.call),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Gender Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Iconsax.profile_circle),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            value: "",
            onChanged: (value) {
            },
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          // Password
          Obx(
            () => TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Iconsax.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    
                  },
                  icon: Icon(
                    Iconsax.eye_slash
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwSections),

          // Terms & Conditions Checkbox
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: true,
                  onChanged: (value) {
                   
                  },
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'I agree to '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms of Use',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwSections),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(const HomeScreen()),
              child: const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}