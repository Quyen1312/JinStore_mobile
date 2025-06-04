import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
// Import DisplayCartItem từ cart_service.dart (nơi nó được định nghĩa ở các lượt trước)
import 'package:flutter_application_jin/service/cart_service.dart' show DisplayCartItem;
// Hoặc nếu bạn đã tách DisplayCartItem ra file riêng, ví dụ:
// import 'package:flutter_application_jin/features/shop/models/display_cart_item_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.cartItem, // Thay đổi kiểu thành DisplayCartItem
    // Thêm các callback nếu cần, ví dụ: để tăng/giảm số lượng
    // this.onAdd,
    // this.onRemove,
  });

  final DisplayCartItem cartItem; // Sử dụng DisplayCartItem
  // final VoidCallback? onAdd;
  // final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bool dark = HelperFunctions.isDarkMode(context);
    // DisplayCartItem chứa thông tin chi tiết sản phẩm đã được populate
    // và quantity từ giỏ hàng.

    return Row(
      children: [
        // Image
        RoundedImage(
          // DisplayCartItem có images là List<String>, lấy ảnh đầu tiên
          imageUrl: cartItem.images.isNotEmpty ? cartItem.images.first : '',
          width: 60,
          height: 60,
          isNetworkImage: cartItem.images.isNotEmpty && cartItem.images.first.isNotEmpty,
          padding: const EdgeInsets.all(AppSizes.sm),
          backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
        ),
        const SizedBox(width: AppSizes.spaceBtwItems),

        // Title, Price, Size etc.
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Title
              ProductTitleText(title: cartItem.name, maxLines: 1),

              // Đơn vị tính (nếu có)
              if (cartItem.unit != null && cartItem.unit!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text('Đơn vị: ${cartItem.unit}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ProductPriceText(price: cartItem.discountPrice.toString()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Text(
            'SL: ${cartItem.quantity}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
