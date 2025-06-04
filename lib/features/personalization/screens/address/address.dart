import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/add_new_address.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/edit_address.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/widgets/single_address.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();

    return Scaffold(
      // FloatingActionButton luôn hiển thị
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Iconsax.add,
          color: AppColors.white,
        ),
      ),
      appBar: Appbar(
        showBackArrow: true,
        title: Text(
          'Địa Chỉ',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        // XÓA actions để remove reload button khỏi AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Obx(() {
          // Show loading indicator
          if (addressController.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.md),
                  Text('Đang tải danh sách địa chỉ...'),
                ],
              ),
            );
          }

          // Show error message if there's an error
          if (addressController.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      addressController.error.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ElevatedButton.icon(
                    onPressed: () => addressController.fetchAddressesOfCurrentUser(),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show empty state if no addresses
          if (addressController.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.location,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Chưa có địa chỉ nào',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    child: Text(
                      'Thêm địa chỉ đầu tiên của bạn để bắt đầu mua sắm',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  // Big action button for first address
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddNewAddressScreen()),
                    icon: const Icon(Iconsax.add),
                    label: const Text('Thêm địa chỉ đầu tiên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xl,
                        vertical: AppSizes.md,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show list of addresses - Clean layout without header
          return RefreshIndicator(
            onRefresh: () => addressController.fetchAddressesOfCurrentUser(),
            color: AppColors.primary,
            child: ListView.separated(
              itemCount: addressController.addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                final address = addressController.addresses[index];
                return SingleAddress(
                  address: address,
                  onTap: () {
                    // Handle address selection
                    addressController.selectAddress(address.id);
                    
                    // Show options dialog
                    _showAddressOptionsDialog(context, address, addressController);
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // Show dialog with address options
  void _showAddressOptionsDialog(BuildContext context, address, AddressController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Address info header
            Row(
              children: [
                const Icon(
                  Iconsax.location,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Tùy chọn địa chỉ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Mặc định',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            
            // Address details
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Text(
                address.formattedAddress,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Options
            if (!address.isDefault) ...[
              _buildOptionTile(
                context,
                icon: Iconsax.tick_circle,
                title: 'Đặt làm mặc định',
                subtitle: 'Sử dụng địa chỉ này cho đơn hàng mới',
                color: AppColors.buttonPrimary,
                onTap: () {
                  Get.back();
                  controller.selectDefaultAddress(address.id);
                },
              ),
              const Divider(height: 1),
            ],
            
            _buildOptionTile(
              context,
              icon: Iconsax.edit,
              title: 'Chỉnh sửa',
              subtitle: 'Cập nhật thông tin địa chỉ',
              color: AppColors.buttonPrimary,
              onTap: () {
                // Navigate to edit address screen
                Get.to(() => EditAddressScreen(address: address));
              },
            ),
            const Divider(height: 1),
            
            _buildOptionTile(
              context,
              icon: Iconsax.trash,
              title: 'Xóa địa chỉ',
              subtitle: 'Xóa vĩnh viễn khỏi danh sách',
              color: Colors.red,
              onTap: () {
                Get.back();
                _showDeleteConfirmDialog(context, address, controller);
              },
            ),
            
            // Add safe area at bottom
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext context, address, AddressController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Colors.red.shade600,
              size: 24,
            ),
            const SizedBox(width: AppSizes.sm),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                address.formattedAddress,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Hành động này không thể hoàn tác.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeAddress(address.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}