import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/shimmer_effect.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class VerticalImageText extends StatelessWidget {
  const VerticalImageText(
      {super.key,
      required this.image,
      required this.title,
      this.textColor = AppColors.white,
      this.backgroundColor,
      this.onTap,
      this.isNetworkImage = false});

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSizes.spaceBtwItems),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(AppSizes.cardRadiusMd),
              decoration: BoxDecoration(
                color:  AppColors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: isNetworkImage
                    ? CachedNetworkImage(
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        imageUrl: image,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                const ShimmerEffect(
                          width: 55,
                          height: 55,
                          radius: 55,
                        ),
                      )
                    : Image(
                        height: 34,
                        width: 34,
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                        ),
              ),
            ),
            const SizedBox(
              height: AppSizes.spaceBtwItems / 2,
            ),
            SizedBox(
              width: 55,
              child: Text(
                textAlign: TextAlign.center,
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
