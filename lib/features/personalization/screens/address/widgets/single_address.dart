import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: onTap,
        child: RoundedContainer(
            padding: const EdgeInsets.all(AppSizes.md),
            width: double.infinity,
            showBorder: true,
            backgroundColor:  AppColors.primary.withOpacity(0.5),
            borderColor: 
                Colors.transparent,
                
            margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Iconsax.tick_circle5,
                      color: 
                           AppColors.light
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.and,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: AppSizes.sm / 2,
                    ),
                    Text(
                      AppTexts.and,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: AppSizes.sm / 2,
                    ),
                    Text(
                      AppTexts.and,
                      softWrap: true,
                    ),
                  ],
                )
              ],
            )),
      );
    });
  }
}
