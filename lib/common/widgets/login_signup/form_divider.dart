import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:get/get.dart'; // Giả sử AppTexts có hằng số

class FormDivider extends StatelessWidget {
  const FormDivider({
    super.key,
    required this.dividerText,
    // required this.dark, // Biến dark không còn cần thiết nếu chúng ta dùng màu từ Theme
  });

  final String dividerText;
  // final bool dark; // Không cần nữa

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark; // Lấy theme hiện tại
    final Color dividerColor = dark ? AppColors.darkGrey : AppColors.grey;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Divider(
            color: dividerColor,
            thickness: 0.5,
            indent: 20, // Giảm indent
            endIndent: 5,
          ),
        ),
        Padding( // Thêm Padding cho Text để không bị quá sát Divider
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            dividerText.capitalize!, // Sử dụng AppTexts nếu có, hoặc giữ nguyên
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Flexible(
          child: Divider(
            color: dividerColor,
            thickness: 0.5,
            indent: 5,
            endIndent: 20, // Giảm indent
          ),
        )
      ],
    );
  }
}
