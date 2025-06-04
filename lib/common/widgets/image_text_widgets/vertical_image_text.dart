import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class VerticalImageText extends StatelessWidget {
  const VerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor,
    this.backgroundColor,
    this.onTap,
    this.isNetworkImage = false,
  });

  final String image;
  final String title;
  final Color? textColor;
  final Color? backgroundColor;
  final void Function()? onTap;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final defaultTextColor = textColor ?? (dark ? AppColors.white : AppColors.black);
    final defaultBackgroundColor = backgroundColor ?? (dark ? AppColors.dark : AppColors.light);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSizes.spaceBtwItems),
        child: Column(
          children: [
            // ✅ Image Container with better styling
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: defaultBackgroundColor,
                borderRadius: BorderRadius.circular(100),
                // ✅ Add subtle border for better visibility
                border: Border.all(
                  color: defaultTextColor.withOpacity(0.1),
                  width: 1,
                ),
                // ✅ Add shadow for depth
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _buildImage(context, defaultTextColor),
              ),
            ),
            
            const SizedBox(height: AppSizes.spaceBtwItems / 2),

            // ✅ Title with better text handling
            SizedBox(
              width: 65, // ✅ Slightly wider for better text display
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: defaultTextColor,
                  fontWeight: FontWeight.w500, // ✅ Slightly bolder
                ),
                maxLines: 2, // ✅ Allow 2 lines for longer names
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Build image with proper error handling
  Widget _buildImage(BuildContext context, Color textColor) {
    // ✅ Handle empty image
    if (image.isEmpty) {
      return _buildPlaceholderIcon(textColor);
    }

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingWidget(textColor),
        errorWidget: (context, url, error) {
          print('❌ Error loading category image: $error');
          return _buildPlaceholderIcon(textColor);
        },
        // ✅ Add memory cache
        memCacheWidth: 112, // 2x the display size for better quality
        memCacheHeight: 112,
      );
    } else {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset image: $error');
          return _buildPlaceholderIcon(textColor);
        },
      );
    }
  }

  /// ✅ Loading widget with shimmer effect
  Widget _buildLoadingWidget(Color textColor) {
    return ShimmerEffect(
      width: 40,
      height: 40,
      radius: 20,
      color: textColor.withOpacity(0.1),
    );
  }

  /// ✅ Placeholder icon for missing/error images
  Widget _buildPlaceholderIcon(Color textColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Iconsax.category,
        size: 24,
        color: textColor.withOpacity(0.6),
      ),
    );
  }
}