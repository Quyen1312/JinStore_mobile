import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/shop/controllers/home/home_controller.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/custom_shapes/containers/circular_container.dart';
import '../../../../../common/widgets/images/rounded_images.dart';
import '../../../../../utils/constants/colors.dart';

class PromoSlider extends StatelessWidget {
  const PromoSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                onPageChanged: (index, _) => controller.updatePageIndicator(index),
              ),
              items: 
                  const [
                    RoundedImage(imageUrl: Images.banner1,),
                    RoundedImage(imageUrl: Images.banner2,),
                    RoundedImage(imageUrl: Images.banner3,),
                    RoundedImage(imageUrl: Images.banner4,),
                      ],
              ),
            const SizedBox(
              height: AppSizes.spaceBtwItems,
            ),
            Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 4; i++)
                    CircularContainer(
                      width: 15,
                      height: 5,
                      margin: const EdgeInsets.only(right: 10),
                      backgroundColor:
                          controller.carouselCurrentIndex.value == i
                              ? AppColors.primary
                              : AppColors.grey,
                    ),
                ],
              ),
            )
          ],
        );
      }
    }