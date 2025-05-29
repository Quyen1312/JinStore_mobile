import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/screens/splash/splash_screen.dart'; // Đảm bảo đường dẫn này chính xác
import 'package:flutter_application_jin/utils/helpers/dependencies.dart' as dep; // Alias cho dependencies
import 'package:flutter_application_jin/utils/theme/theme.dart'; // Import theme của bạn
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hàm main, điểm khởi đầu của ứng dụng
Future<void> main() async {
  // --- Đảm bảo các Widget Binding đã được khởi tạo ---
  // Cần thiết cho các hoạt động bất đồng bộ trước khi runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // --- Khởi tạo SharedPreferences ---
  // Cần thiết nếu bạn lưu trữ dữ liệu cục bộ như token, trạng thái onboarding, v.v.
  // Get.putAsync() có thể là một cách tốt hơn để xử lý SharedPreferences nếu bạn muốn nó là một service có thể truy cập qua GetX
  await SharedPreferences.getInstance();

  // --- Khởi tạo Dependencies ---
  // Gọi hàm init từ file dependencies.dart để đăng ký các services, repositories, controllers
  await dep.init();

  // --- Chạy ứng dụng ---
  runApp(const App());
}

// Widget App gốc của ứng dụng
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JinStore', // Lấy tên ứng dụng từ hằng số (nếu có)
      themeMode: ThemeMode.system, // Sử dụng theme hệ thống (sáng/tối)
      theme: AppTheme.lightTheme, // Theme sáng
      darkTheme: AppTheme.darkTheme, // Theme tối
      debugShowCheckedModeBanner: false, // Tắt banner debug
      // initialBinding: GeneralBindings(), // Nếu bạn có GeneralBindings cho các controller không lazy load
      
      // --- Màn hình bắt đầu ---
      // Đặt SplashScreen làm màn hình home ban đầu.
      // SplashController sẽ xử lý logic điều hướng dựa trên trạng thái đăng nhập.
      home: SplashScreen(), 
    );
  }
}
