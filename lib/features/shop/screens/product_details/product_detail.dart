import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/texts/section_heading.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_attribute.dart';
import 'package:flutter_application_jin/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/product_model.dart';
import 'widgets/bottom_add_to_cart_widget.dart';
import 'widgets/product_detail_image_slider.dart';
import 'widgets/rating_share_widget.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomAddToCart(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1 - Product Image Slider
            ProductDetailImageSlider(product: product),

            /// 2 - Product Details
            Padding(
              padding: const EdgeInsets.only(
                  right: AppSizes.defaultSpace,
                  left: AppSizes.defaultSpace,
                  bottom: AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Rating & Share Button
                  const RatingAndShare(),
                  // Price, Title, Stock, & Brand
                  ProductMetaData(product: product),

                  // Attributes
                  ProductAttribute(product: product),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {}, child: const Text('Checkout')),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // Description
                  const Sectionheading(
                      title: 'Description', showActionButton: false),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  const ReadMoreText(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: ' Show Less',
                    moreStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    lessStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),

                  // Reviews
                  const Divider(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Sectionheading(
                          title: 'Reviews(199)', showActionButton: false),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Iconsax.arrow_right_3, size: 18))
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
