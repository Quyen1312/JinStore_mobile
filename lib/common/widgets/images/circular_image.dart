import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({
    super.key,
    this.fit = BoxFit.cover,
    required this.image,
    this.isNetworkImage = false,
    this.overlayColor,
    this.backgroundColor,
    this.width = 56,
    this.height = 56,
    this.padding = AppSizes.sm,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (HelperFunctions.isDarkMode(context)
                ? AppColors.black
                : AppColors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100 - padding),
        child: isNetworkImage ? _buildNetworkImage(context) : _buildAssetImage(context),
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    // Validate URL before attempting to load
    if (image.isEmpty || (!image.startsWith('http://') && !image.startsWith('https://'))) {
      return _buildErrorWidget(context);
    }

    return CachedNetworkImage(
      imageUrl: image,
      fit: fit ?? BoxFit.cover,
      color: overlayColor,
      placeholder: (context, url) => _buildLoadingWidget(context),
      errorWidget: (context, url, error) {
        print('Error loading network image: $url - Error: $error');
        return _buildErrorWidget(context);
      },
    );
  }

  Widget _buildAssetImage(BuildContext context) {
    if (image.isEmpty) {
      return _buildErrorWidget(context);
    }

    return Image.asset(
      image,
      fit: fit ?? BoxFit.cover,
      color: overlayColor,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading asset image: $image - Error: $error');
        return _buildErrorWidget(context);
      },
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: width * 0.3,
          height: width * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              HelperFunctions.isDarkMode(context) ? AppColors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: width * 0.4,
        color: Colors.grey[600],
      ),
    );
  }
}