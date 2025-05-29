import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/sizes.dart';

class BillingAddressSection extends StatelessWidget {
  const BillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sectionheading(
            title: 'Shipping Address',
            buttonTitle: 'Change',
            onPressed: () {},
            showActionButton: true,
          ),
          Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ltmq',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Text(
                          '077999888'
                              .toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_history,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Expanded(
                          child: Text(
                            '30 duong van an, hue',
                            style: Theme.of(context).textTheme.bodyMedium ??
                                const TextStyle(fontSize: 14),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

