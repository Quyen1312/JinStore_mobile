import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/address.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/validators/validation.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key, required this.address});
  
  final Address address;

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = Get.find<AddressController>();

  // Text controllers
  final _detailedController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Pre-fill form với dữ liệu địa chỉ hiện tại
    _detailedController.text = widget.address.detailed ?? '';
    _districtController.text = widget.address.district ?? '';
    _cityController.text = widget.address.city ?? '';
    _provinceController.text = widget.address.province ?? '';
    _isDefault = widget.address.isDefault;
  }

  @override
  void dispose() {
    _detailedController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _addressController.editAddress(
          addressId: widget.address.id,
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
        print('Error updating address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: Text('Chỉnh sửa địa chỉ'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card hiển thị địa chỉ cũ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            color: Colors.blue.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            'Địa chỉ hiện tại',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (widget.address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Text(
                                'Mặc định',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        widget.address.formattedAddress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spaceBtwSections),
                
                // Form fields
                Text(
                  'Thông tin chỉnh sửa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),

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

                // Nút cập nhật
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addressController.isLoading.value ? null : _updateAddress,
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
                              Text('Đang cập nhật...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.edit),
                              SizedBox(width: AppSizes.sm),
                              Text('Cập nhật địa chỉ'),
                            ],
                          ),
                  ),
                )),
                
                const SizedBox(height: AppSizes.sm),
                
                // Helper text
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
                              'Đang cập nhật địa chỉ và chuyển về danh sách...',
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