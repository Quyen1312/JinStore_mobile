import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_jin/utils/loaders/animation_loader.dart'; 
import 'package:get/get.dart';
import 'package:coupon_uikit/coupon_uikit.dart'; 
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

        if (controller.error.value.isNotEmpty && controller.discounts.isEmpty) {
          return Center(
            child: AnimationLoaderWidget(
              text: 'Đã có lỗi xảy ra: ${controller.error.value}',
              animation: Images.loaderAnimation,
            ),
          );
        }

        if (controller.discounts.isEmpty) {
          return const Center(
            child: AnimationLoaderWidget(
              text: 'Bạn chưa có mã giảm giá nào.',
              animation: Images.loaderAnimation, 
              showAction: false,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: controller.discounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              final discount = controller.discounts[index];
              final bool isValid = discount.isValid;
              final Color primaryColor = isValid ? AppColors.primary : Colors.grey;
              final Color onPrimaryColor = isValid ? AppColors.white : AppColors.darkGrey;

              return CouponCard(
                height: 150, // Điều chỉnh chiều cao nếu cần
                backgroundColor: primaryColor.withOpacity(0.1),
                border: const BorderSide(color: AppColors.primary),
                curvePosition: 100, // Vị trí đường cắt
                curveRadius: 25,
                firstChild: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatDiscountValue(discount),
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        discount.code, // Hiển thị code
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: dark ? AppColors.lightGrey : AppColors.darkGrey),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Đơn tối thiểu: ${controller.formatCurrency(discount.minOrderAmount)}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        'HSD: ${controller.formatDate(discount.endDate)}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      if (!isValid)
                        Text(
                          'Đã hết hạn/Không hợp lệ',
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.error),
                        ),
                    ],
                  ),
                ),
                secondChild: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: primaryColor,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isValid)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                          ),
                          onPressed: () {
                            // Logic khi nhấn "Sử dụng"
                            // Ví dụ: Quay lại màn hình giỏ hàng và tự động áp dụng
                            // Hoặc copy mã và thông báo
                            Clipboard.setData(ClipboardData(text: discount.code));
                            Loaders.successSnackBar(title: 'Đã sao chép', message: 'Mã ${discount.code} đã được sao chép.');
                            // Có thể gọi applyDiscountToCart nếu muốn áp dụng ngay
                            // controller.applyDiscountToCart(discount.code, cartController.totalCartPrice.value);
                            // Get.back(); // Quay lại màn hình trước đó
                          },
                          child: const Text('Lưu mã'),
                        )
                      else
                        Text('Không thể dùng', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey)),
                      const SizedBox(height: AppSizes.xs),
                       TextButton(
                        onPressed: () {
                          // Hiển thị chi tiết điều kiện áp dụng (nếu có)
                          Get.defaultDialog(
                            title: "Chi tiết mã giảm giá",
                            middleText: "Mã: ${discount.code}\nGiảm: ${controller.formatDiscountValue(discount)}\nĐơn tối thiểu: ${controller.formatCurrency(discount.minOrderAmount)}\nNgày bắt đầu: ${controller.formatDate(discount.startDate)}\nNgày hết hạn: ${controller.formatDate(discount.endDate)}\n${discount.applicableProducts?.isNotEmpty == true ? 'Sản phẩm áp dụng: ${discount.applicableProducts!.join(", ")}\n' : ''}${discount.applicableCategories?.isNotEmpty == true ? 'Danh mục áp dụng: ${discount.applicableCategories!.join(", ")}' : ''}",
                            confirm: ElevatedButton(onPressed: () => Get.back(), child: const Text("Đóng"))
                          );
                        },
                        child: Text('Điều kiện', style: TextStyle(color: primaryColor)),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}