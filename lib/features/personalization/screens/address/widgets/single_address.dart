import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/features/personalization/models/address_model.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


class SingleAddress extends StatelessWidget {
  const SingleAddress({
    super.key,
    required this.address,
    required this.onTap,
  });

  final Address address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    
    return Obx(() {
      final isSelected = addressController.selectedAddress.value?.id == address.id;
      final isDefault = address.isDefault;
      
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with default badge and selected icon
              if (isDefault || isSelected) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Default badge
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.crown,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Mặc định',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    // Selected icon
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Iconsax.tick_circle5,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
              ],
              
              // Address info section - Improved alignment
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location icon - Fixed positioning
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.location,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  
                  // Address details - Better text layout
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2), // Align with icon center
                      child: Text(
                        _buildFullAddress().isNotEmpty 
                            ? _buildFullAddress()
                            : address.formattedAddress.isNotEmpty
                                ? address.formattedAddress
                                : 'Địa chỉ: ${address.toString()}', // Fallback to raw data
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  
                  // Action indicator - Aligned with text
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: AppSizes.xs), // Align with text
                    child: Icon(
                      Iconsax.more,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _buildShortAddress() {
    List<String> parts = [];
    
    if (address.district != null && address.district!.isNotEmpty) {
      parts.add(address.district!);
    }
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }
    if (address.province != null && address.province!.isNotEmpty) {
      parts.add(address.province!);
    }
    
    return parts.join(', ');
  }

  String _buildFullAddress() {
    List<String> parts = [];
    
    if (address.detailed != null && address.detailed!.isNotEmpty) {
      parts.add(address.detailed!);
    }
    if (address.district != null && address.district!.isNotEmpty) {
      parts.add(address.district!);
    }
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }
    if (address.province != null && address.province!.isNotEmpty) {
      parts.add(address.province!);
    }
    
    return parts.join(', ');
  }
}