import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/add_new_address.dart';
import 'package:flutter_application_jin/features/personalization/screens/address/widgets/single_address.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(
          () => const AddNewAddressScreen(),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Iconsax.add,
          color: AppColors.white,
        ),
      ),
      appBar: Appbar(
        showBackArrow: true,
        leadingOnPressed: () {
          debugPrint('Back button pressed');
          Get.back(); // or Navigator.pop(context)
        },
        title: Text(
          'Address',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              SingleAddress(onTap: () {
                
              },)
            ],
          )),
    );
  }
}
