import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart'; // Nếu cần hiển thị brand
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:flutter_application_jin/features/shop/models/cart_item_model.dart'; // Import CartItemModel
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CartItemWidget extends StatelessWidget { // Đổi tên class thành CartItemWidget để tránh trùng
  const CartItemWidget({ // Đổi tên class
    super.key,
    required this.cartItem,
  });

  final CartItemModel cartItem;

  @override
  Widget build(BuildContext context) {
    final bool dark = HelperFunctions.isDarkMode(context);
    return Row(
      children: [
        // Image
        RoundedImage(
          imageUrl: cartItem.imageUrl ?? '', // Sử dụng ảnh từ cartItem
          width: 60,
          height: 60,
          isNetworkImage: cartItem.imageUrl != null && cartItem.imageUrl!.isNotEmpty,
          padding: const EdgeInsets.all(AppSizes.sm),
          backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
        ),
        const SizedBox(width: AppSizes.spaceBtwItems),
    
        // Title, Price, Size etc.
        Expanded( // Sử dụng Expanded để Column chiếm không gian còn lại
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Name (Nếu có trong ProductModel và CartItemModel)
              // BrandTitleWithVerifiedIcon(title: cartItem.productBrand ?? 'Brand'), 
              
              // Product Title
              ProductTitleText(title: cartItem.name, maxLines: 1),
              
              // Attributes (Ví dụ: Color, Size - nếu có)
              // if (cartItem.selectedAttributes != null && cartItem.selectedAttributes!.isNotEmpty)
              //   Text.rich(
              //     TextSpan(
              //       children: cartItem.selectedAttributes!.entries.map((entry) => 
              //         TextSpan(children: [
              //           TextSpan(text: ' ${entry.key}: ', style: Theme.of(context).textTheme.bodySmall),
              //           TextSpan(text: '${entry.value} ', style: Theme.of(context).textTheme.bodyLarge),
              //         ])
              //       ).toList(),
              //     ),
              //   ),
              
              // Đơn vị tính (nếu có)
              if (cartItem.unit != null && cartItem.unit!.isNotEmpty)
                Text('Đơn vị: ${cartItem.unit}', style: Theme.of(context).textTheme.bodySmall),

            ],
          ),
        )
      ],
    );
  }
}
