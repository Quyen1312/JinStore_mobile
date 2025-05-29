import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: () {
        Get.back();
      },
      leading: RoundedContainer(
        width: 60,
        height: 40,
        backgroundColor: HelperFunctions.isDarkMode(context)
            ? AppColors.light
            : AppColors.white,
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Image(
          image: AssetImage(Images.paypal),
          fit: BoxFit.contain,
        ),
      ),
      title: Text(''),
      trailing: const Icon(Iconsax.arrow_right_34),
    );
  }
}
