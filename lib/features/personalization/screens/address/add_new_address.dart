import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: Text(
          'Add New Address',
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user), labelText: 'Name'),
                ),
                const SizedBox(
                  height: AppSizes.spaceBtwInputFields,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.mobile),
                      labelText: 'Phone Number'),
                ),
                const SizedBox(
                  height: AppSizes.spaceBtwInputFields,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.building_31),
                            labelText: 'Street'),
                      ),
                    ),
                    const SizedBox(
                      width: AppSizes.spaceBtwInputFields,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.code),
                            labelText: 'Postal Code'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: AppSizes.spaceBtwInputFields,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.building),
                            labelText: 'City'),
                      ),
                    ),
                    const SizedBox(
                      width: AppSizes.spaceBtwInputFields,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.activity),
                            labelText: 'Province'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: AppSizes.spaceBtwInputFields,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.global), labelText: 'Country'),
                ),
                const SizedBox(
                  height: AppSizes.defaultSpace,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Save')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
