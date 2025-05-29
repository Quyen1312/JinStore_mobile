import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';

class SettingsMenuTiles extends StatelessWidget {
  const SettingsMenuTiles(
      {super.key,
      required this.icon,
      required this.title,
      required this.subTitle,
      this.trailing,
      this.onTap});

  final IconData icon;
  final String title, subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 28,
        color: AppColors.primary,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        subTitle,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      trailing: trailing,
    );
  }
}
