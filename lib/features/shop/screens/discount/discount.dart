import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_jin/utils/loaders/animation_loader.dart'; 
import 'package:get/get.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/shop/controllers/discount_controller.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:flutter_application_jin/utils/constants/images.dart'; 

class DiscountScreen extends StatelessWidget { 

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiscountController()); 
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: Appbar( 
        title: Text('Mã giảm giá của bạn', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty && controller.userAvailableDiscounts.isEmpty) {
          return Center(
            child: AnimationLoaderWidget(
              text: 'Đã có lỗi xảy ra: ${controller.error.value}',
              animation: Images.loaderAnimation,
            ),
          );
        }

        if (controller.userAvailableDiscounts.isEmpty) {
          return const Center(
            child: AnimationLoaderWidget(
              text: 'Bạn chưa có mã giảm giá nào.',
              animation: Images.loaderAnimation, 
              showAction: false,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchAvailableDiscountsForCurrentUser();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: controller.userAvailableDiscounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                final discount = controller.userAvailableDiscounts[index];
                final bool isValid = discount.isValid;
                final Color primaryColor = isValid ? AppColors.primary : Colors.grey;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.05),
                          primaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header với mã và giá trị giảm
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.formatDiscountValue(discount),
                                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                        color: primaryColor, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        discount.code,
                                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isValid ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isValid ? 'Khả dụng' : 'Hết hạn',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.md),
                          
                          // Thông tin chi tiết
                          Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              color: dark ? Colors.grey[800] : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  context,
                                  Icons.shopping_cart,
                                  'Đơn tối thiểu',
                                  controller.formatCurrency(discount.minOrderAmount),
                                ),
                                const Divider(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.calendar_today,
                                  'Ngày kích hoạt',
                                  controller.formatDate(discount.activationDate),
                                ),
                                const Divider(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.schedule,
                                  'Hạn sử dụng',
                                  controller.formatDate(discount.expirationDate),
                                ),
                                const Divider(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.inventory,
                                  'Số lượng',
                                  '${discount.quantityLimit - discount.quantityUsed}/${discount.quantityLimit} còn lại',
                                ),
                                const Divider(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.category,
                                  'Loại giảm giá',
                                  discount.type == 'fixed' ? 'Giảm cố định' : 'Giảm theo phần trăm',
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.md),
                          
                          // Action buttons
                          if (isValid) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: discount.code));
                                  Loaders.successSnackBar(
                                    title: 'Đã sao chép', 
                                    message: 'Mã ${discount.code} đã được sao chép.'
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Sao chép mã'),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.block, color: Colors.grey[600], size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Không thể sử dụng',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: AppSizes.sm),
                          
                          // Chi tiết button
                          TextButton.icon(
                            onPressed: () {
                              _showDiscountDetails(context, discount, controller);
                            },
                            icon: Icon(Icons.info_outline, size: 16, color: primaryColor),
                            label: Text(
                              'Xem chi tiết',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }



  void _showDiscountDetails(BuildContext context, discount, DiscountController controller) {
    Get.defaultDialog(
      title: "Chi tiết mã giảm giá",
      titleStyle: Theme.of(context).textTheme.titleLarge,
      content: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Mã giảm giá:", discount.code),
                  const Divider(),
                  _buildDetailRow("Loại:", discount.type == 'fixed' ? 'Giảm cố định' : 'Giảm theo %'),
                  const Divider(),
                  _buildDetailRow("Giá trị:", controller.formatDiscountValue(discount)),
                  const Divider(),
                  _buildDetailRow("Đơn tối thiểu:", controller.formatCurrency(discount.minOrderAmount)),
                  const Divider(),
                  _buildDetailRow("Ngày kích hoạt:", controller.formatDate(discount.activationDate)),
                  const Divider(),
                  _buildDetailRow("Ngày hết hạn:", controller.formatDate(discount.expirationDate)),
                  const Divider(),
                  _buildDetailRow("Số lượng giới hạn:", "${discount.quantityLimit}"),
                  const Divider(),
                  _buildDetailRow("Đã sử dụng:", "${discount.quantityUsed}"),
                  const Divider(),
                  _buildDetailRow("Còn lại:", "${discount.quantityLimit - discount.quantityUsed}"),
                  const Divider(),
                  _buildDetailRow("Trạng thái:", discount.isValid ? "Có thể sử dụng" : "Không thể sử dụng"),
                ],
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(), 
        child: const Text("Đóng")
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}