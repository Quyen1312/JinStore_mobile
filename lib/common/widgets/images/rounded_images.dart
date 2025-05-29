import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({
    super.key,
    this.width,
    this.height,
    required this.imageUrl,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.padding,
    this.isNetworkImage = false,
    this.onTap,
    this.borderRadius = AppSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
            border: border,
            color: HelperFunctions.isDarkMode(context)
                ? AppColors.dark
                : AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius)),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadius.circular(borderRadius)
              : BorderRadius.zero,
          child: isNetworkImage
              ? CachedNetworkImage(
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  alignment: Alignment.center,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      ShimmerEffect(
                    width: double.infinity,
                    height: height!,
                    radius: AppSizes.cardRadiusMd,
                  ),
                )
              : Image(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
