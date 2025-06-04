import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/address.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = Get.find<AddressController>();

  // Text controllers
  final _detailedController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  bool _isDefault = false;

  @override
  void dispose() {
    _detailedController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _addressController.addNewAddress(
          detailed: _detailedController.text.trim(),
          district: _districtController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
          isDefaultAddress: _isDefault,
        );

        // Navigate về UserAddressScreen với Get.off()
        if (mounted) {
          Get.off(() => const UserAddressScreen());
        }
      } catch (e) {
        // Error đã được handle trong AddressController
        print('Error saving address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: Text('Thêm địa chỉ mới'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Địa chỉ chi tiết (số nhà, tên đường)
                TextFormField(
                  controller: _detailedController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.building_31),
                    labelText: 'Địa chỉ chi tiết',
                    hintText: 'Số nhà, tên đường...',
                  ),
                  validator: (value) => Validator.validateEmptyText('Địa chỉ chi tiết', value),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // Phường/Xã
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.location),
                    labelText: 'Phường/Xã',
                    hintText: 'Nhập phường/xã',
                  ),
                  validator: (value) => Validator.validateEmptyText('Phường/Xã', value),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // Quận/Huyện và Tỉnh/Thành phố
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'Quận/Huyện',
                          hintText: 'Nhập quận/huyện',
                        ),
                        validator: (value) => Validator.validateEmptyText('Quận/Huyện', value),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: _provinceController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'Tỉnh/Thành phố',
                          hintText: 'Nhập tỉnh/thành phố',
                        ),
                        validator: (value) => Validator.validateEmptyText('Tỉnh/Thành phố', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                // Checkbox đặt làm địa chỉ mặc định
                Row(
                  children: [
                    Obx(() => Checkbox(
                      value: _isDefault,
                      onChanged: _addressController.isLoading.value 
                        ? null 
                        : (value) {
                            setState(() {
                              _isDefault = value ?? false;
                            });
                          },
                    )),
                    Expanded(
                      child: Text(
                        'Đặt làm địa chỉ mặc định',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.defaultSpace),

                // Nút lưu - với navigation Get.off()
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addressController.isLoading.value ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    ),
                    child: _addressController.isLoading.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: AppSizes.sm),
                              Text('Đang lưu...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Icon(Iconsax.tick_circle),
                               SizedBox(width: AppSizes.sm),
                               Text('Lưu địa chỉ'),
                            ],
                          ),
                  ),
                )),
                
                const SizedBox(height: AppSizes.sm),
                
                // Helper text - thông báo navigation
                Obx(() {
                  if (_addressController.isLoading.value) {
                    return Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            color: Colors.blue.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              'Đang lưu địa chỉ và chuyển về danh sách...',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}