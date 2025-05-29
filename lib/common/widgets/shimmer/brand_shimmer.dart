import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';

class BrandShimmer extends StatelessWidget {
  const BrandShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridLayout(
        itemCount: itemCount,
        itemBuilder: (_, __) => const ShimmerEffect(width: 300, height: 80));
  }
}
