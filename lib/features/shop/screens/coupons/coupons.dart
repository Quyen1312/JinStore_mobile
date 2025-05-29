import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';

class Coupons extends StatelessWidget {
  const Coupons({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: Text('My Coupons'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) => Image.asset(Images.giftVoucher),
        ),
      ),
    );
  }
}
