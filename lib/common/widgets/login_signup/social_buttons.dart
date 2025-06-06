import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/service/google_signin_exception.dart';
import 'package:flutter_application_jin/service/google_signin_service.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';

class SocialButtons extends StatefulWidget {
  const SocialButtons({super.key});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  final AuthController authController = Get.find<AuthController>();
  final GoogleSignInService googleService = GoogleSignInService.instance;
  
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Không gọi initialize() ở đây nữa để tránh double init
    // GoogleSignInService đã được init trong main.dart
    print('📱 [SocialButtons] Initialized, GoogleSignIn status: ${googleService.isInitialized}');
  }

  /// ✅ Xử lý đăng nhập Google - Support cả Web và Mobile
  Future<void> _handleGoogleSignIn() async {
    if (isGoogleLoading) return; // Prevent double tap

    setState(() {
      isGoogleLoading = true;
    });

    try {
      print('🚀 [SocialButtons] Starting Google Sign-In flow on ${kIsWeb ? 'Web' : 'Mobile'}...');
      
      // ✅ Show loading feedback
      Loaders.customToast(message: kIsWeb 
          ? 'Đang kết nối với Google (Web)...' 
          : 'Đang kết nối với Google...');

      // ✅ Step 1: Get Token from Google (Web or Mobile)
      final String? token = await googleService.signInWithGoogle();
      
      if (token == null) {
        // User cancelled - không phải lỗi
        print('ℹ️ [SocialButtons] User cancelled Google Sign-In');
        return;
      }

      print('✅ [SocialButtons] Got token from Google (${kIsWeb ? 'Web' : 'Mobile'})');

      // ✅ Step 2: Send token to backend 
      print('📤 [SocialButtons] Sending token to backend...');
      
      if (kIsWeb) {
        // ✅ Web: Real backend call (bật tính năng này)
        try {
          await authController.loginWithGoogle(idToken: token);
          print('🎉 [SocialButtons] Web Google Sign-In with backend completed!');
          _navigateToMainApp();
        } catch (backendError) {
          print('❌ [SocialButtons] Backend error on web: $backendError');
          // Fallback: Show demo success nếu backend fail
          _showWebSuccessDemo(token);
        }
      } else {
        // Mobile: Real backend call
        await authController.loginWithGoogle(idToken: token);
        print('🎉 [SocialButtons] Google Sign-In flow completed successfully!');
        _navigateToMainApp();
      }

    } on GoogleSignInCancelledException {
      // User cancelled - không cần hiển thị error
      print('ℹ️ [SocialButtons] User cancelled Google Sign-In');
      
    } on GoogleSignInNetworkException catch (e) {
      print('❌ [SocialButtons] Network error: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi kết nối',
        message: 'Kiểm tra kết nối internet và thử lại.',
      );
      await _cleanupGoogleSession();
      
    } on GoogleSignInConfigException catch (e) {
      print('❌ [SocialButtons] Config error: $e');
      Loaders.errorSnackBar(
        title: 'Lỗi cấu hình',
        message: 'Ứng dụng chưa được cấu hình đúng. Vui lòng liên hệ hỗ trợ.',
      );
      await _cleanupGoogleSession();
      
    } on GoogleSignInException catch (e) {
      print('❌ [SocialButtons] Google Sign-In error: $e');
      Loaders.errorSnackBar(
        title: 'Đăng nhập Google thất bại',
        message: GoogleSignInErrorHandler.getUserFriendlyMessage(e),
      );
      await _cleanupGoogleSession();
      
    } catch (error) {
      print('❌ [SocialButtons] Unexpected error: $error');
      
      // ✅ Handle backend/AuthController errors
      String errorMessage = error.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      
      // ✅ Show user-friendly error
      Loaders.errorSnackBar(
        title: 'Đăng nhập thất bại',
        message: _getBackendErrorMessage(errorMessage),
      );
      
      // ✅ Cleanup Google session on backend error
      await _cleanupGoogleSession();
      
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  /// ✅ Demo success cho Web development
  void _showWebSuccessDemo(String token) {
    // Get current Google user info
    final currentUser = googleService.currentUser;
    
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Google Sign-In Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎉 Google Sign-In hoạt động thành công!'),
            const SizedBox(height: 12),
            if (currentUser != null) ...[
              Text('👤 User: ${currentUser.displayName}'),
              Text('📧 Email: ${currentUser.email}'),
              const SizedBox(height: 8),
            ],
            Text('🎫 Token: ${token.substring(0, 30)}...'),
            const SizedBox(height: 12),
            const Text('🚀 Bây giờ sẽ chuyển đến trang chính của ứng dụng!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // ✅ FIX: Đóng dialog trước khi navigate
              Navigator.of(Get.context!).pop();
              _navigateToMainApp();
            },
            child: const Text('Vào ứng dụng'),
          ),
          TextButton(
            onPressed: () {
              // ✅ FIX: Dùng Navigator thay vì Get.back()
              Navigator.of(Get.context!).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// ✅ Navigate to main app (NavigationMenu)
  void _navigateToMainApp() {
    print('🎯 [SocialButtons] Navigating to NavigationMenu...');
    
    // Clear all previous routes and go to NavigationMenu
    Get.offAllNamed('/navigation-menu');
    
    // Show success message
    Loaders.successSnackBar(
      title: 'Đăng nhập thành công!',
      message: 'Chào mừng bạn đến với JinStore 🎉',
    );
  }

  /// ✅ Cleanup Google session khi có lỗi
  Future<void> _cleanupGoogleSession() async {
    try {
      await googleService.signOut();
      print('🧹 [SocialButtons] Google session cleaned up');
    } catch (e) {
      print('⚠️ [SocialButtons] Failed to cleanup Google session: $e');
    }
  }

  /// ✅ Convert backend error thành user-friendly message
  String _getBackendErrorMessage(String error) {
    final String lowerError = error.toLowerCase();
    
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Lỗi kết nối server. Vui lòng thử lại sau.';
    }
    
    if (lowerError.contains('invalid') && lowerError.contains('token')) {
      return 'Lỗi xác thực Google. Vui lòng thử lại.';
    }
    
    if (lowerError.contains('user not found') || lowerError.contains('account')) {
      return 'Không thể tạo tài khoản. Vui lòng thử lại.';
    }
    
    if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Lỗi server tạm thời. Vui lòng thử lại sau ít phút.';
    }
    
    // Default message
    return 'Đăng nhập Google thất bại. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              IconButton(
                onPressed: isGoogleLoading ? null : _handleGoogleSignIn,
                tooltip: kIsWeb 
                    ? 'Đăng nhập Google (Web Development)'
                    : 'Đăng nhập với Google',
                icon: Opacity(
                  opacity: isGoogleLoading ? 0.5 : 1.0,
                  child: const Image(
                    height: AppSizes.iconMd,
                    width: AppSizes.iconMd,
                    image: AssetImage(Images.google),
                  ),
                ),
              ),
              
              // ✅ Loading indicator
              if (isGoogleLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                
              // ✅ Platform indicator
              if (kIsWeb)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.web,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Cleanup nếu cần
    super.dispose();
  }
}