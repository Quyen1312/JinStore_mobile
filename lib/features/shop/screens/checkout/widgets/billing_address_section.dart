import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/add_new_address.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BillingAddressSection extends StatelessWidget {
  const BillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    
    return Obx(
      () {
        final selectedAddress = addressController.selectedAddress.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Sectionheading(
              title: 'Địa chỉ giao hàng',
              buttonTitle: 'Thay đổi',
              onPressed: () => _showAddressSelectionDialog(context, addressController),
              showActionButton: true,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            
            if (selectedAddress == null)
              Row(
                children: [
                  Icon(
                    Iconsax.location,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    size: 16,
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Expanded(
                    child: Text(
                      'Chưa có địa chỉ được chọn',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address details using the actual Address model properties
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.location,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addressController.getFormattedAddress(selectedAddress),
                              style: Theme.of(context).textTheme.bodyMedium,
                              softWrap: true,
                            ),
                            if (selectedAddress.isDefault) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Mặc định',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _showAddressSelectionDialog(BuildContext context, AddressController addressController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn địa chỉ giao hàng',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Add new address button - Moved to top for better UX
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog first
                  
                  // Navigate to add address screen and wait for result
                  final result = await Get.to(() => const AddNewAddressScreen());
                  
                  // Refresh addresses after returning from add address screen
                  await addressController.fetchAddressesOfCurrentUser();
                  
                  // Show the dialog again to display updated list
                  if (context.mounted) {
                    _showAddressSelectionDialog(context, addressController);
                  }
                },
                icon: const Icon(Iconsax.add),
                label: const Text('Thêm địa chỉ mới'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSizes.md),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Divider
            const Divider(),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Address list
            Expanded(
              child: Obx(() {
                if (addressController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (addressController.addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.location_slash,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Text(
                          'Chưa có địa chỉ nào',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems / 2),
                        Text(
                          'Hãy thêm địa chỉ giao hàng để tiếp tục',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => addressController.fetchAddressesOfCurrentUser(),
                  child: ListView.builder(
                    itemCount: addressController.addresses.length,
                    itemBuilder: (context, index) {
                      final address = addressController.addresses[index];
                      final isSelected = addressController.selectedAddress.value?.id == address.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                        elevation: isSelected ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppSizes.md),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isSelected ? Iconsax.location_tick : Iconsax.location,
                              color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.outline,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            addressController.getFormattedAddress(address),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (address.isDefault) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Địa chỉ mặc định',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: isSelected 
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : null,
                          onTap: () async {
                            await addressController.selectAddress(address.id);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}