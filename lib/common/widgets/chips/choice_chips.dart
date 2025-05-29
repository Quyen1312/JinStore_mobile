import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';

class CustomChoiceChip extends StatelessWidget {
  const CustomChoiceChip(
      {super.key, required this.text, required this.selected, this.onSelected});

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isColor = HelperFunctions.getColor(text) != null;
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        selected: selected,
        label: isColor ? const SizedBox() : Text(text),
        onSelected: onSelected,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : null,
        ),
        avatar: isColor
            ? CircularContainer(
                backgroundColor: HelperFunctions.getColor(text)!,
                width: 50,
                height: 50,
              )
            : null,
        shape: isColor ? const CircleBorder() : null,
        labelPadding: isColor ? const EdgeInsets.all(0) : null,
        padding: isColor ? const EdgeInsets.all(0) : null,
        backgroundColor: HelperFunctions.getColor(text),
      ),
    );
  }
}
