import 'package:flutter/material.dart';
import 'package:flutter_application_jin/bottom_navigation_bar.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/coupon_widget.dart';
import 'package:flutter_application_jin/common/widgets/success_screen/success_screen.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'widgets/billing_payment_section.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: Appbar(
        showBackArrow: true,
        title: Text(
          'Order Review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            // items in Cart
            const CartItems(
              showAddRemoveButton: false,
            ),
            const SizedBox(
              height: AppSizes.spaceBtwSections,
            ),

            // Coupon Textfield
            const CouponCode(),
            const SizedBox(
              height: AppSizes.spaceBtwSections,
            ),

            // Billing Sections
            RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.black : AppColors.white,
                child: const Column(
                  children: [
                    // Pricing
                    BillingAmountSection(),
                    SizedBox(
                      height: AppSizes.spaceBtwItems,
                    ),

                    // Divider
                    Divider(),
                    SizedBox(
                      height: AppSizes.spaceBtwItems,
                    ),

                    // Payment Methods
                    BillingPaymentSection(),
                    SizedBox(
                      height: AppSizes.spaceBtwItems,
                    ),

                    // Address
                    BillingAddressSection()
                  ],
                ))
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
            onPressed: () => Get.to(
              () => SuccessScreen(image: Images.successfulPaymentIcon, title: 'Payment success', subTitle: '', onPressed: () => Get.offAll(() => const BottomNavMenu()),
            )
      ),
      child: Text('Checkout ')),
    )
    );
  }
}
