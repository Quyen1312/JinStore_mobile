import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/images/rounded_images.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_title_text.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundedImage(
          imageUrl: Images.banner1,
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(AppSizes.sm),
          backgroundColor: HelperFunctions.isDarkMode(context) ? AppColors.darkerGrey : AppColors.light,
          ),
        const SizedBox(width: AppSizes.spaceBtwItems,),
    
        //title, price, size
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: const ProductTitleText(title: '', maxLines: 1,)),
            //attribute
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'color', style: Theme.of(context).textTheme.bodySmall),
                TextSpan(text: 'size', style: Theme.of(context).textTheme.bodyLarge),
                TextSpan(text: 'UK', style: Theme.of(context).textTheme.bodyLarge),
              ])
            )
          ],
        )
      ],
    );
  }
}