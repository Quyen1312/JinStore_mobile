import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Model cho phương thức thanh toán
class PaymentMethod {
  final String id;
  final String name;
  final String image;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.image,
    required this.icon,
  });
}

class BillingPaymentSection extends StatelessWidget {
  const BillingPaymentSection({super.key});

  // Danh sách các phương thức thanh toán
  static final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'cod',
      name: 'Thanh toán khi nhận hàng',
      image: 'assets/icons/payments/cod.png', // Thay đổi đường dẫn theo assets của bạn
      icon: Iconsax.money_send,
    ),
    PaymentMethod(
      id: 'vnpay',
      name: 'Thanh toán qua VNPay',
      image: 'assets/icons/payments/vnpay.png', // Thay đổi đường dẫn theo assets của bạn
      icon: Iconsax.card,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    
    // Controller để quản lý trạng thái được chọn
    final selectedPaymentMethod = _paymentMethods[0].obs; // Mặc định chọn COD

    return Column(
      children: [
        // Heading
        Sectionheading(
          title: 'Phương thức thanh toán',
          buttonTitle: 'Thay đổi',
          showActionButton: true,
          onPressed: () => _showPaymentMethodSelector(context, selectedPaymentMethod),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),
        
        // Hiển thị phương thức thanh toán được chọn
        Obx(
          () => Row(
            children: [
              RoundedContainer(
                width: 60,
                height: 35,
                backgroundColor: dark ? AppColors.light : AppColors.white,
                padding: const EdgeInsets.all(AppSizes.sm),
                child: selectedPaymentMethod.value.image.isNotEmpty
                    ? Image(
                        image: AssetImage(selectedPaymentMethod.value.image),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback nếu không tìm thấy hình ảnh
                          return Icon(
                            selectedPaymentMethod.value.icon,
                            color: dark ? AppColors.dark : AppColors.primary,
                          );
                        },
                      )
                    : Icon(
                        selectedPaymentMethod.value.icon,
                        color: dark ? AppColors.dark : AppColors.primary,
                      ),
              ),
              const SizedBox(width: AppSizes.spaceBtwItems / 2),
              Expanded(
                child: Text(
                  selectedPaymentMethod.value.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Hàm hiển thị dialog để chọn phương thức thanh toán
  void _showPaymentMethodSelector(BuildContext context, Rx<PaymentMethod> selectedMethod) {
    final dark = HelperFunctions.isDarkMode(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? AppColors.dark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn phương thức thanh toán',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              
              // Danh sách phương thức thanh toán
              ..._paymentMethods.map((method) => Obx(() => 
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: RoundedContainer(
                    width: 50,
                    height: 35,
                    backgroundColor: dark ? AppColors.light : AppColors.white,
                    padding: const EdgeInsets.all(AppSizes.xs),
                    child: method.image.isNotEmpty
                        ? Image(
                            image: AssetImage(method.image),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                method.icon,
                                color: dark ? AppColors.dark : AppColors.primary,
                                size: 20,
                              );
                            },
                          )
                        : Icon(
                            method.icon,
                            color: dark ? AppColors.dark : AppColors.primary,
                            size: 20,
                          ),
                  ),
                  title: Text(method.name),
                  trailing: Radio<String>(
                    value: method.id,
                    groupValue: selectedMethod.value.id,
                    onChanged: (String? value) {
                      if (value != null) {
                        selectedMethod.value = _paymentMethods
                            .firstWhere((m) => m.id == value);
                        Navigator.of(context).pop();
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {
                    selectedMethod.value = method;
                    Navigator.of(context).pop();
                  },
                ),
              )),
              
              const SizedBox(height: AppSizes.spaceBtwItems),
            ],
          ),
        );
      },
    );
  }

  // Hàm static để lấy phương thức thanh toán được chọn từ bên ngoài
  static String getSelectedPaymentMethodId() {
    // Bạn có thể sử dụng GetStorage hoặc SharedPreferences để lưu trữ
    // Hoặc sử dụng GetX controller riêng để quản lý trạng thái global
    return 'cod'; // Mặc định trả về COD
  }

  // Hàm static để kiểm tra có phải VNPay không
  static bool isVNPaySelected(String paymentMethodId) {
    return paymentMethodId == 'vnpay';
  }
}