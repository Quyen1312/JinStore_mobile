import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/icons/circular_icon.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // Sửa thành iconsax_flutter

class ProductQuantityWithAddRemoveButton extends StatelessWidget {
  const ProductQuantityWithAddRemoveButton({
    super.key,
    required this.quantity,
    this.add,
    this.remove,
    this.isLoading = false, // Thêm trạng thái loading
  });

  final int quantity;
  final VoidCallback? add;
  final VoidCallback? remove;
  final bool isLoading; // Để hiển thị indicator nếu đang cập nhật

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularIcon(
          onPressed: isLoading ? null : remove, // Vô hiệu hóa khi loading
          icon: Iconsax.minus,
          width: 32,
          height: 32,
          size: AppSizes.md,
          color: HelperFunctions.isDarkMode(context)
              ? AppColors.white
              : AppColors.black,
          backgroundColor: HelperFunctions.isDarkMode(context)
              ? AppColors.darkerGrey
              : AppColors.light,
        ),
        const SizedBox(width: AppSizes.spaceBtwItems),
        // Hiển thị indicator nhỏ nếu đang loading, ngược lại hiển thị số lượng
        isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
        const SizedBox(width: AppSizes.spaceBtwItems),
        CircularIcon(
          onPressed: isLoading ? null : add, // Vô hiệu hóa khi loading
          icon: Iconsax.add,
          width: 32,
          height: 32,
          size: AppSizes.md,
          color: AppColors.white, // Màu icon cho nút add
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}
