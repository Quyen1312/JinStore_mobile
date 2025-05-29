import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/add_remove_button.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_item.dart';
import 'package:flutter_application_jin/common/widgets/texts/product_price_text.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class CartItems extends StatelessWidget {
  const CartItems({
    super.key, this.showAddRemoveButton = true
  });

  final bool showAddRemoveButton;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (_, __)=> const SizedBox(height: AppSizes.spaceBtwSections,),
      itemCount: 4,
      itemBuilder: (_, index) => Column(
        children: [
          CartItem(),
          if (showAddRemoveButton)
          SizedBox(height: AppSizes.spaceBtwItems,),
          
          if (showAddRemoveButton)
          Row(
            children: [
              Row(
                children: [
                  //extra space
                  SizedBox(width: 70,),
    
                  //add remove button
                  ProductQuantityWithAddRemoveButton(quantity: 24),
                ],
              ),
              
              ProductPriceText(price: '245'),
            ]
          
          )
          
          
          ],
      ),
      );
  }
}
