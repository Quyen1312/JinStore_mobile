import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Hãy đăng ký tài khoản của bạn",
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
