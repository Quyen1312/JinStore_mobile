import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter_application_jin/utils/helpers/dependencies.dart' as dep; // Import with a prefix
import 'package:get/get.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX dependencies
  await dep.init(); // Call init from the prefixed import

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Optional: to hide debug banner
      themeMode: ThemeMode.system, // Optional: set theme mode
      // theme: AppTheme.lightTheme, // Optional: if you have custom themes
      // darkTheme: AppTheme.darkTheme, // Optional: if you have custom themes
      home: const OnBoardingScreen(), // Your initial screen
    );
  }
}