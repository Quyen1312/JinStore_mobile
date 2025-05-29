import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:flutter_application_jin/utils/constants/text_string.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Appbar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.homeAppbarTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: AppColors.grey),
          ),
          Text(
            AppTexts.homeAppbarSubTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: AppColors.grey),
          ),
        ],
      ),
      actions: const [
        CartCounterIcon(
          iconColor: AppColors.white,
        )
      ],
    );
  }
}
