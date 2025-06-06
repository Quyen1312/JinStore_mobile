/// Custom exceptions cho Google Sign-In
class GoogleSignInException implements Exception {
  final String message;
  final String? code;
  
  const GoogleSignInException(this.message, {this.code});
  
  @override
  String toString() => 'GoogleSignInException: $message';
}

class GoogleSignInCancelledException extends GoogleSignInException {
  const GoogleSignInCancelledException() : super('User cancelled Google Sign-In', code: 'CANCELLED');
}

class GoogleSignInNetworkException extends GoogleSignInException {
  const GoogleSignInNetworkException() : super('Network error during Google Sign-In', code: 'NETWORK_ERROR');
}

class GoogleSignInConfigException extends GoogleSignInException {
  const GoogleSignInConfigException() : super('Google Sign-In configuration error', code: 'CONFIG_ERROR');
}

/// Utility class để xử lý Google Sign-In errors
class GoogleSignInErrorHandler {
  
  /// Convert PlatformException từ google_sign_in thành custom exception
  static GoogleSignInException handlePlatformException(dynamic error) {
    if (error is Exception) {
      final String errorString = error.toString().toLowerCase();
      
      // Cancelled by user
      if (errorString.contains('sign_in_cancelled') || 
          errorString.contains('cancelled') ||
          errorString.contains('user_cancelled')) {
        return const GoogleSignInCancelledException();
      }
      
      // Network errors
      if (errorString.contains('network_error') ||
          errorString.contains('network') ||
          errorString.contains('connection')) {
        return const GoogleSignInNetworkException();
      }
      
      // Configuration errors
      if (errorString.contains('developer_error') ||
          errorString.contains('invalid_client') ||
          errorString.contains('config')) {
        return const GoogleSignInConfigException();
      }
      
      // Generic error
      return GoogleSignInException(
        'Google Sign-In failed: ${error.toString()}',
        code: 'UNKNOWN_ERROR'
      );
    }
    
    return const GoogleSignInException(
      'Unknown Google Sign-In error',
      code: 'UNKNOWN_ERROR'
    );
  }
  
  /// Lấy message thân thiện với user
  static String getUserFriendlyMessage(GoogleSignInException exception) {
    switch (exception.code) {
      case 'CANCELLED':
        return 'Bạn đã hủy đăng nhập Google.';
      case 'NETWORK_ERROR':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
      case 'CONFIG_ERROR':
        return 'Lỗi cấu hình ứng dụng. Vui lòng liên hệ hỗ trợ.';
      default:
        return 'Đăng nhập Google thất bại. Vui lòng thử lại.';
    }
  }
  
  /// Check xem có nên retry không dựa trên error type
  static bool shouldRetry(GoogleSignInException exception) {
    switch (exception.code) {
      case 'NETWORK_ERROR':
        return true;
      case 'CANCELLED':
      case 'CONFIG_ERROR':
        return false;
      default:
        return true;
    }
  }
}