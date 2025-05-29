import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';

class OrderListItems extends StatelessWidget {
  const OrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

        return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(
            height: AppSizes.spaceBtwItems,
          ),
          itemCount: 4,
          itemBuilder: (_, index) {
            return RoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(AppSizes.md),
              backgroundColor: dark ? AppColors.dark : AppColors.light,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 1 - Icon
                      const Icon(Iconsax.ship),
                      const SizedBox(
                        width: AppSizes.spaceBtwItems / 2,
                      ),

                      // 2 -Status & Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .apply(
                                      color: AppColors.primary,
                                      fontWeightDelta: 1),
                            ),
                            Text(
                              '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            )
                          ],
                        ),
                      ),

                      // 3 - Icon
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Iconsax.arrow_right_34,
                            size: AppSizes.iconSm,
                          ))
                    ],
                  ),

                  const SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),

                  //  Row 2
                  Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          // 1 - Icon
                          const Icon(Iconsax.tag),
                          const SizedBox(
                            width: AppSizes.spaceBtwItems / 2,
                          ),

                          // 2 -Status & Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  '',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                      Expanded(
                          child: Row(
                        children: [
                          // 1 - Icon
                          const Icon(Iconsax.calendar),
                          const SizedBox(
                            width: AppSizes.spaceBtwItems / 2,
                          ),

                          // 2 -Status & Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shipping Date',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  '',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  )
                ],
              ),
            );
          },
        );
      }
  }
