import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class VerticalProductShimmer extends StatelessWidget {
  const VerticalProductShimmer({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.gridSpacing,
        crossAxisSpacing: AppSizes.gridSpacing,
        mainAxisExtent: 288,
      ),
      itemBuilder: (_, __) {
        return RoundedContainer(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              const ShimmerEffect(
                width: double.infinity,
                height: 180,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Title
              const ShimmerEffect(
                width: double.infinity,
                height: 20,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems / 2),

              // Price
              const ShimmerEffect(
                width: 100,
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
