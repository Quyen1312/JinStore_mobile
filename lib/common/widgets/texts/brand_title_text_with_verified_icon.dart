import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/brand_title_text.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/enum.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BrandTitleWithVerifiedIcon extends StatelessWidget {
  const BrandTitleWithVerifiedIcon({
    super.key,
    this.textColor,
    this.maxLines = 1,
    required this.title,
    this.iconColor = AppColors.primary,
    this.textAlign = TextAlign.center,
    this.brandTextSize = TextSizes.small,
  });

  final String title;
  final int maxLines;
  final Color? textColor, iconColor;
  final TextAlign? textAlign;
  final TextSizes brandTextSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: BrandTitleText(
            title: title,
            color: textColor,
            maxLines: maxLines,
            textAlign: textAlign,
            brandTextSize: brandTextSize,
          ), // TBrandTitleText
        ), // Flexible
        const SizedBox(width: AppSizes.xs),
        Icon(Iconsax.verify, color: iconColor, size: AppSizes.iconXs),
      ],
    ); // Row
  }
}
