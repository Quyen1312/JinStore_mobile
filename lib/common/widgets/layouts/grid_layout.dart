import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';


class GridLayout extends StatelessWidget {
  const GridLayout(
      {super.key,
      required this.itemCount,
      this.mainAxisExtent = 288,
      required this.itemBuilder});

  final int itemCount;
  final double? mainAxisExtent;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.gridViewSpacing,
        mainAxisSpacing: AppSizes.gridViewSpacing,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
