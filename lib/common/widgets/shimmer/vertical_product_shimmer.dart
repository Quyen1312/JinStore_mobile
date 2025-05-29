import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class VerticalProductShimmer extends StatelessWidget {
  const VerticalProductShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridLayout(
        itemCount: itemCount,
        itemBuilder: (_, __) => const SizedBox(
              width: 180,
              child: Column(
                children: [
                  // Images
                  ShimmerEffect(width: 180, height: 180),
                  SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),

                  // Text
                  ShimmerEffect(width: 160, height: 15),
                  SizedBox(height: AppSizes.spaceBtwItems / 2),
                  ShimmerEffect(width: 160, height: 15),
                ],
              ),
            ));
  }
}
