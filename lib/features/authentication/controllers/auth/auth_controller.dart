import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter_application_jin/service/auth_service.dart';
import 'package:flutter_application_jin/features/authentication/screens/login/login.dart';
import 'package:flutter_application_jin/navigation_menu.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Kiểm tra trạng thái đăng nhập khi app khởi động
  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Kiểm tra có token hợp lệ không
      final hasValidLogin = await _authService.isLoggedIn();
      if (!hasValidLogin) {
        _resetAuthState();
        return;
      }

      // Lấy thông tin user đã lưu local (nhanh hơn)
      final savedUser = await _authService.getSavedUserData();
      if (savedUser != null) {
        currentUser.value = savedUser;
        isLoggedIn.value = true;
      }

      // Verify và sync với server (trong background)
      await _syncUserProfileWithServer();

    } catch (e) {
      print('❌ Lỗi checkLoginStatus: $e');
      error.value = _extractErrorMessage(e);
      await _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync thông tin user với server (không block UI)
  Future<void> _syncUserProfileWithServer() async {
    try {
      // Kiểm tra token có hợp lệ không, tự động refresh nếu cần
      final validToken = await _authService.getValidAccessToken();
      if (validToken == null) {
        throw UnauthorizedException('Không thể lấy token hợp lệ');
      }

      // Lấy thông tin mới nhất từ server
      final userProfile = await _authService.getProfile();
      currentUser.value = userProfile;
      isLoggedIn.value = true;

    } catch (e) {
      print('⚠️ Lỗi sync user profile: $e');
      if (e is UnauthorizedException || e is ForbiddenException) {
        await _handleAuthError(e);
      }
    }
  }

  /// Fetch thông tin user hiện tại từ server
  Future<void> fetchAndSetCurrentUser() async {
    if (!isLoggedIn.value) return;
    
    try {
      isLoading.value = true;
      error.value = '';

      final userProfile = await _authService.getProfile();
      currentUser.value = userProfile;

    } catch (e) {
      print('❌ Lỗi fetchAndSetCurrentUser: $e');
      error.value = _extractErrorMessage(e);
      await _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Kiểm tra login status và điều hướng phù hợp
  Future<void> checkLoginStatusAndNavigate() async {
    await checkLoginStatus();
    
    if (isLoggedIn.value && currentUser.value != null) {
      print('✅ Navigating to NavigationMenu');
      Get.offAll(() => const NavigationMenu());
    } else {
      print('❌ Navigating to LoginScreen');
      Get.offAll(() => LoginScreen());
    }
  }

  /// Đăng nhập
  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loginResult = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      // ✅ AuthService đã tự động lưu token và user data
      // Chỉ cần lấy user data đã lưu
      final savedUser = await _authService.getSavedUserData();
      if (savedUser != null) {
        currentUser.value = savedUser;
        isLoggedIn.value = true;
        
        _showSuccessMessage('Đăng nhập thành công!', 
            'Chào mừng bạn trở lại, ${savedUser.fullname}!');
        
        Get.offAll(() => const NavigationMenu());
      } else {
        throw Exception('Không thể lấy thông tin người dùng sau khi đăng nhập.');
      }

    } catch (e) {
      print('❌ [AuthController] Lỗi đăng nhập: $e');
      error.value = _extractErrorMessage(e);
      _resetAuthState();
      Loaders.errorSnackBar(
        title: 'Đăng nhập thất bại', 
        message: _extractErrorMessage(e)
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đăng ký
  Future<void> register({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authService.register(
        fullname: fullname,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      _showSuccessMessage('Đăng ký thành công!', 'Vui lòng đăng nhập để tiếp tục.');
      
      // ✅ FIX: Navigate to LoginScreen, not NavigationMenu
      Get.off(() => LoginScreen());

    } catch (e) {
      print('❌ [AuthController] Lỗi đăng ký: $e');
      error.value = _extractErrorMessage(e);
      Loaders.errorSnackBar(
        title: 'Đăng ký thất bại', 
        message: _extractErrorMessage(e)
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';

      // AuthService sẽ tự động xử lý việc gọi API logout và clear data
      await _authService.logout();

    } catch (e) {
      print('⚠️ [AuthController] Lỗi khi gọi API logout: $e');
      // Vẫn tiếp tục logout local ngay cả khi API lỗi
      // AuthService.logout() đã clear local data trong finally block
    } finally {
      _resetAuthState();
      isLoading.value = false;
      
      // Show success message
      Loaders.successSnackBar(
        title: 'Đăng xuất thành công',
        message: 'Hẹn gặp lại bạn!'
      );
      
      Get.offAll(() => LoginScreen());
    }
  }

  /// Thử refresh token
  Future<bool> tryRefreshToken() async {
    if (isLoading.value) return false; // Tránh gọi nhiều lần

    try {
      isLoading.value = true;
      error.value = '';

      // ✅ AuthService.refreshToken() đã handle everything
      final result = await _authService.refreshToken();
      
      if (result['accessToken'] != null) {
        // Token đã được lưu tự động, chỉ cần update UI state
        final savedUser = await _authService.getSavedUserData();
        if (savedUser != null) {
          currentUser.value = savedUser;
          isLoggedIn.value = true;
        }
        
        print('✅ Token refresh thành công');
        return true;
      } else {
        throw Exception('Không nhận được access token mới từ refresh.');
      }

    } catch (e) {
      print('❌ [AuthController] Lỗi refreshToken: $e');
      error.value = _extractErrorMessage(e);
      await _handleAuthError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Lấy token hợp lệ (delegate to AuthService)
  Future<String?> getValidToken() async {
    try {
      return await _authService.getValidAccessToken();
    } catch (e) {
      print('❌ Không thể lấy valid token: $e');
      await _handleAuthError(e);
      return null;
    }
  }

  /// ✅ Method alias cho compatibility với old services
  Future<String?> getValidAccessToken() async {
    return await getValidToken();
  }

  /// Cập nhật profile
  Future<void> updateProfile({
    String? fullname,
    String? email,
    String? avatarUrl,
  }) async {
    if (currentUser.value == null) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Không có thông tin người dùng để cập nhật.');
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final updatedUser = await _authService.updateProfile(
        fullname: fullname,
        email: email,
        avatarUrl: avatarUrl,
      );

      currentUser.value = updatedUser;
      _showSuccessMessage('Thành công', 'Hồ sơ đã được cập nhật.');

    } catch (e) {
      print('❌ [AuthController] Lỗi updateProfile: $e');
      error.value = _extractErrorMessage(e);
      Loaders.errorSnackBar(
        title: 'Cập nhật thất bại', 
        message: _extractErrorMessage(e)
      );
      await _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentUser.value == null) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập để đổi mật khẩu.');
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      await _authService.changePasswordAuth(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _showSuccessMessage('Thành công', 'Mật khẩu đã được thay đổi.');
      
      // Optional: logout sau khi đổi mật khẩu thành công
      // await logout();

    } catch (e) {
      print('❌ [AuthController] Lỗi changePassword: $e');
      error.value = _extractErrorMessage(e);
      Loaders.errorSnackBar(
        title: 'Đổi mật khẩu thất bại', 
        message: _extractErrorMessage(e)
      );
      await _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Dọn dẹp dữ liệu hết hạn
  Future<void> cleanExpiredData() async {
    try {
      await _authService.cleanExpiredData();
      // Kiểm tra lại trạng thái sau khi clean
      await checkLoginStatus();
    } catch (e) {
      print('⚠️ Lỗi clean expired data: $e');
    }
  }

  /// ✅ Đăng nhập với Google
  Future<void> loginWithGoogle({required String idToken}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loginResult = await _authService.loginWithGoogle(idToken: idToken);
      
      // AuthService đã tự động lưu token và user data
      final savedUser = await _authService.getSavedUserData();
      if (savedUser != null) {
        currentUser.value = savedUser;
        isLoggedIn.value = true;
        
        _showSuccessMessage('Đăng nhập Google thành công!', 
            'Chào mừng bạn, ${savedUser.fullname}!');
        
        Get.offAll(() => const NavigationMenu());
      } else {
        throw Exception('Không thể lấy thông tin người dùng sau khi đăng nhập Google.');
      }

    } catch (e) {
      print('❌ [AuthController] Lỗi Google login: $e');
      error.value = _extractErrorMessage(e);
      _resetAuthState();
      Loaders.errorSnackBar(
        title: 'Đăng nhập Google thất bại', 
        message: _extractErrorMessage(e)
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============= HELPER METHODS =============

  /// ✅ Extract error message từ different exception types
  String _extractErrorMessage(dynamic error) {
    if (error is UnauthorizedException) {
      return error.message;
    } else if (error is ForbiddenException) {
      return error.message;
    } else if (error is NotFoundException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      return error;
    } else {
      return error.toString();
    }
  }

  /// Reset trạng thái authentication
  void _resetAuthState() {
    isLoggedIn.value = false;
    currentUser.value = null;
    error.value = '';
  }

  /// ✅ Xử lý lỗi authentication với proper exception handling
  Future<void> _handleAuthError(dynamic e) async {
    // Handle custom exceptions từ AuthService
    if (e is UnauthorizedException || e is ForbiddenException) {
      print('🔐 Auth error, thực hiện logout: $e');
      await _authService.clearAuthData();
      _resetAuthState();
      
      // Chỉ show message và redirect nếu user đang active
      if (Get.currentRoute != '/login') {
        Loaders.errorSnackBar(
          title: 'Phiên hết hạn', 
          message: 'Vui lòng đăng nhập lại.'
        );
        Get.offAll(() => LoginScreen());
      }
    } else if (e is NotFoundException) {
      // API endpoint không tồn tại
      Loaders.errorSnackBar(
        title: 'Lỗi server', 
        message: 'Tính năng này hiện không khả dụng.'
      );
    }
    // Các exception khác không cần special handling
  }

  /// Show success message
  void _showSuccessMessage(String title, String message) {
    Loaders.successSnackBar(title: title, message: message);
  }

  // ============= GETTERS =============

  /// Kiểm tra user có phải admin không
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  /// Kiểm tra user có active không
  bool get isUserActive => currentUser.value?.isActive ?? false;

  /// Lấy tên user hiện tại
  String get currentUserName => currentUser.value?.fullname ?? '';

  /// Lấy email user hiện tại
  String get currentUserEmail => currentUser.value?.email ?? '';

  /// Lấy avatar URL
  String get currentUserAvatar => currentUser.value?.avatar?.url ?? '';

  /// Lấy user ID hiện tại
  String? get currentUserId => currentUser.value?.id;

  // ============= CONVENIENCE METHODS =============

  /// ✅ Check if user is authenticated and has valid token
  Future<bool> isAuthenticated() async {
    try {
      final token = await getValidToken();
      return token != null && isLoggedIn.value;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Ensure user is authenticated before performing action
  Future<bool> ensureAuthenticated() async {
    if (!isLoggedIn.value) {
      Loaders.errorSnackBar(
        title: 'Yêu cầu đăng nhập',
        message: 'Vui lòng đăng nhập để sử dụng tính năng này.'
      );
      Get.to(() => LoginScreen());
      return false;
    }

    final token = await getValidToken();
    if (token == null) {
      Loaders.errorSnackBar(
        title: 'Phiên hết hạn',
        message: 'Vui lòng đăng nhập lại.'
      );
      Get.offAll(() => LoginScreen());
      return false;
    }

    return true;
  }
}