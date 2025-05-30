import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/personalization/controllers/user/user_controller.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart'; // Thêm import này
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final TextEditingController firstNameController = TextEditingController(text: userController.user.value?.fullname.split(' ').first ?? '');
    final TextEditingController lastNameController = TextEditingController(text: userController.user.value?.fullname.split(' ').sublist(1).join(' ') ?? '');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];
    String? selectedGender; // To store the selected gender

    return Scaffold(
      appBar: Appbar(
        showBackArrow: true,
        title: Text('Đổi tên', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Sử dụng tên thật để dễ dàng xác minh. Tên này sẽ xuất hiện trên một vài trang.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Text field and button
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: firstNameController,
                    // Sử dụng AppValidator
                    validator: (value) => Validator.validateEmptyText('Họ và tên', value), 
                    expands: false,
                    decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Iconsax.user)),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: lastNameController,
                    // Sử dụng AppValidator
                    validator: (value) => Validator.validateEmptyText('Số điện thoại', value), 
                    expands: false,
                    decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Iconsax.call)),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  // Replace TextFormField with DropdownButtonFormField for Gender
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      prefixIcon: Icon(Iconsax.health),
                    ),
                    value: selectedGender,
                    items: genderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Update the selected gender
                      // You might want to update a controller's state here
                      // For now, we'll just update the local variable if you're managing state locally
                      // setState(() { // If this were a StatefulWidget
                      //   selectedGender = newValue;
                      // });
                    },
                    validator: (value) => value == null ? 'Vui lòng chọn giới tính' : null,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: lastNameController,
                    // Sử dụng AppValidator
                    validator: (value) => Validator.validateEmptyText('Ngày sinh', value), 
                    expands: false,
                    decoration: const InputDecoration(
                        labelText: 'Ngày sinh',
                        prefixIcon: Icon(Iconsax.calendar)),
                  ),  
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            // Save button
            SizedBox(
              width: double.infinity,
              child: Obx(() => userController.profileLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Logic cập nhật tên
                    // Ví dụ:
                    // final newFullName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
                    // await userController.updateUserName(newFullName); 
                    // Bạn cần tạo phương thức updateUserName trong UserController
                  }
                },
                child: const Text('Lưu'),
              )),
            )
          ],
        ),
      ),
    );
  }
}
