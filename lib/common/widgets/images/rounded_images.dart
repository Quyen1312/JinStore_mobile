import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

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
    final dark = HelperFunctions.isDarkMode(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor ?? (dark ? AppColors.dark : AppColors.white),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadius.circular(borderRadius)
              : BorderRadius.zero,
          child: _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // ✅ Check for empty imageUrl first
    if (imageUrl.isEmpty) {
      print('⚠️ Empty imageUrl provided to RoundedImage');
      return _buildPlaceholder(context);
    }

    if (isNetworkImage) {
      print('🌐 Loading network image: $imageUrl');
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width ?? double.infinity,
        height: height,
        alignment: Alignment.center,
        placeholder: (context, url) {
          print('⏳ Loading placeholder for: $url');
          return ShimmerEffect(
            width: width ?? double.infinity,
            height: height ?? 200,
            radius: borderRadius,
          );
        },
        errorWidget: (context, url, error) {
          print('❌ Error loading network image $url: $error');
          return _buildPlaceholder(context);
        },
      );
    } else {
      print('📁 Loading asset image: $imageUrl');
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset image $imageUrl: $error');
          return _buildPlaceholder(context);
        },
      );
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey : AppColors.lightGrey,
        borderRadius: applyImageRadius 
            ? BorderRadius.circular(borderRadius) 
            : BorderRadius.zero,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.image,
              color: AppColors.grey,
              size: (height != null && height! < 100) ? 20 : 40,
            ),
            if (height == null || height! > 60) ...[
              const SizedBox(height: 8),
              Text(
                'Không thể tải ảnh',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: (height != null && height! < 100) ? 10 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}