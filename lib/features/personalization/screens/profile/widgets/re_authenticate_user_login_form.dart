import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class ReAuthLoginForm extends StatelessWidget {
  const ReAuthLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: Text('Re-Authenticate User'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.direct_right),
                        labelText: 'Email'),
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwInputFields,
                  ),
                  Obx(
                    () => TextFormField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.password_check),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Iconsax.eye_slash))),
                    ),
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwSections,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Verify'),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
