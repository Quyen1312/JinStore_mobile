import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
    this.width = 400,
    this.height = 400,
    this.padding = 0,
    this.margin,
    this.child,
    required this.backgroundColor,
    this.radius = 400,
  });

  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final Widget? child;
  final EdgeInsets? margin;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
    );
  }
}
