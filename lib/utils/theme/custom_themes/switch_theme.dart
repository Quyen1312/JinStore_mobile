import 'package:flutter/material.dart';

class SwitchThemes {
  SwitchThemes._();

  // Customizable Light Text Theme
  static SwitchThemeData lightSwitchTheme = SwitchThemeData(
    // trackColor: WidgetStateProperty.all(Color(0xFF634C9F).withOpacity(0.7)),
    overlayColor: WidgetStateProperty.all(const Color(0xffffffff)),
    splashRadius: 5.0,
    trackColor: WidgetStateProperty.all(const Color(0xFF634C9F)),
  );

  // Customizable Dark Text Theme
  static SwitchThemeData darkSwitchTheme = SwitchThemeData(
    // trackColor: WidgetStateProperty.all(Color(0xFF634C9F).withOpacity(0.7)),
    overlayColor: WidgetStateProperty.all(const Color(0xffffffff)),
    splashRadius: 5.0,
    trackColor: WidgetStateProperty.all(const Color(0xFF634C9F)),
  );
}
