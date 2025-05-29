import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        // Properly handle back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      //items in cart
      body: SingleChildScrollView(
        child: 
        Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: CartItems(), 
        ),
      ),

      //checkout button
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: ElevatedButton(
            onPressed: () => Get.to(() => {}),
            child: Text('Checkout'),
          ),
      )
        );
      }
}

