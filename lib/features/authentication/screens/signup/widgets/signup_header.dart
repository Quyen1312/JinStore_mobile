import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Let's create your account",
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
