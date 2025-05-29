import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
          itemCount: itemCount,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) => const SizedBox(
                width: AppSizes.spaceBtwItems,
              ),
          itemBuilder: (_, __) {
            return const Column(
              children: [
                // Image
                ShimmerEffect(
                  width: 55,
                  height: 55,
                  radius: 55,
                ),
                SizedBox(
                  height: AppSizes.spaceBtwItems / 2,
                ),

                // Text
                ShimmerEffect(width: 55, height: 8)
              ],
            );
          }),
    );
  }
}
