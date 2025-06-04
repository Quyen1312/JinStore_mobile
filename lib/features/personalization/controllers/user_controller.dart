import 'dart:io'; // Cho File
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart'; // Để kiểm tra quyền admin nếu cần
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:flutter_application_jin/service/user_service.dart';
import 'package:flutter_application_jin/utils/popups/loaders.dart'; // Để dùng JLoaders
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final UserService _userService = Get.find<UserService>();
  final AuthController _authController = Get.find<AuthController>(); // Để lấy thông tin user hiện tại nếu cần

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<User?> currentUser = Rx<User?>(null); // User hiện tại đang được xem/quản lý bởi controller này
  final RxList<User> userList = <User>[].obs; // Danh sách người dùng cho admin
  final RxBool isProfileComplete = false.obs;


  @override
  void onInit() {
    super.onInit();
    // Lắng nghe thay đổi của currentUser từ AuthController để cập nhật currentUser của UserController
    // Điều này hữu ích nếu AuthController là nguồn chính cho thông tin người dùng đã đăng nhập.
    ever(_authController.currentUser, (User? authUser) {
      if (authUser != null) {
        currentUser.value = authUser;
        checkProfileCompletion();
      } else {
        // Nếu AuthController logout, UserController cũng nên reset
        currentUser.value = null;
        isProfileComplete.value = false;
      }
    });

    // Nếu AuthController đã có user khi UserController init, đồng bộ ngay
    if (_authController.currentUser.value != null) {
        currentUser.value = _authController.currentUser.value;
        checkProfileCompletion();
    } else if (_authController.isLoggedIn.value) {
        // Nếu đã login nhưng chưa có currentUser trong AuthController (ví dụ, app vừa mở)
        // AuthController.checkLoginStatus() sẽ gọi fetchAndSetCurrentUser,
        // và listener ở trên sẽ cập nhật UserController.currentUser.
        // Hoặc, có thể gọi fetchUserProfileOfCurrentUser() ở đây nếu cần ngay.
        fetchUserProfileOfCurrentUser();
    }
  }

  /// Lấy thông tin hồ sơ của người dùng hiện tại đã đăng nhập
  Future<void> fetchUserProfileOfCurrentUser() async {
    // Hàm này được gọi bởi UserController để tự lấy thông tin user của chính nó,
    // khác với AuthController.fetchAndSetCurrentUser là để AuthController tự cập nhật.
    try {
      isLoading.value = true;
      error.value = '';
      // Gọi getUserInfo không có tham số để lấy user hiện tại
      final userData = await _userService.getUserInfo();
      currentUser.value = userData;
      // Đồng bộ lại với AuthController nếu cần, hoặc giả định AuthController đã có từ checkLoginStatus
      if (_authController.currentUser.value == null || _authController.currentUser.value!.id != userData.id) {
          _authController.currentUser.value = userData;
      }
      checkProfileCompletion();
    } catch (e) {
      print("UserController fetchUserProfileOfCurrentUser Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải hồ sơ', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy thông tin hồ sơ của một người dùng cụ thể (cho admin)
  Future<User?> fetchUserProfileById(String userId) async {
    // Hàm này cho admin xem thông tin user khác
    try {
      isLoading.value = true;
      error.value = '';
      final userData = await _userService.getUserInfo(userId);
      // Không set currentUser.value ở đây vì đây là xem user khác
      return userData;
    } catch (e) {
      print("UserController fetchUserProfileById Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải hồ sơ người dùng', message: e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }


  /// Lấy tất cả người dùng (Admin only)
  Future<void> fetchAllUsersAdmin() async {
    // Kiểm tra quyền admin ở đây nếu cần thiết, hoặc để backend xử lý
    // if(!_authController.currentUser.value?.isAdmin == true) {
    //   Loaders.errorSnackBar(title: 'Lỗi', message: 'Bạn không có quyền thực hiện hành động này.');
    //   return;
    // }
    try {
      isLoading.value = true;
      error.value = '';
      final users = await _userService.getAllUsers();
      userList.assignAll(users);
    } catch (e) {
      print("UserController fetchAllUsersAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi tải danh sách người dùng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật hồ sơ người dùng
  /// Nếu userIdToUpdate là null, cập nhật người dùng hiện tại.
  /// Nếu userIdToUpdate được cung cấp, admin đang cập nhật người dùng khác.
  Future<void> updateUserProfile({
    String? userIdToUpdate, // ID của user cần cập nhật (nếu admin thực hiện)
    String? fullname,
    String? phone,
    String? gender,
    String? dateOfBirth, // YYYY-MM-DD
    File? avatarFile,
    bool? isAdminRole, // Chỉ admin mới được set
    bool? isActiveStatus, // Chỉ admin mới được set
  }) async {
    // Xác định ID người dùng sẽ được cập nhật
    String targetUserId = userIdToUpdate ?? currentUser.value?.id ?? '';
    if (targetUserId.isEmpty) {
      Loaders.errorSnackBar(title: 'Lỗi', message: 'Không xác định được người dùng để cập nhật.');
      return;
    }

    // Kiểm tra quyền nếu admin cập nhật người khác
    bool isUpdatingSelf = (userIdToUpdate == null || userIdToUpdate == currentUser.value?.id);
    if (!isUpdatingSelf && !(_authController.currentUser.value?.isAdmin == true)) {
        Loaders.errorSnackBar(title: 'Lỗi', message: 'Bạn không có quyền cập nhật người dùng này.');
        return;
    }


    try {
      isLoading.value = true;
      error.value = '';

      final updatedUser = await _userService.updateUserProfile(
        userIdToUpdate: targetUserId, // Luôn truyền ID rõ ràng
        fullname: fullname,
        phone: phone,
        gender: gender,
        dateBirth: dateOfBirth,
        avatar: avatarFile,
        isAdmin: isAdminRole, // Sẽ được backend kiểm tra quyền admin
        isActive: isActiveStatus, // Sẽ được backend kiểm tra quyền admin
      );

      // Nếu người dùng tự cập nhật hồ sơ của chính họ, cập nhật currentUser
      if (isUpdatingSelf) {
        currentUser.value = updatedUser;
         if (_authController.currentUser.value?.id == updatedUser.id) {
            _authController.currentUser.value = updatedUser; // Đồng bộ với AuthController
        }
        checkProfileCompletion();
      } else {
        // Nếu admin cập nhật user khác, cập nhật user đó trong userList (nếu có)
        int index = userList.indexWhere((user) => user.id == updatedUser.id);
        if (index != -1) {
          userList[index] = updatedUser;
        }
      }
      Loaders.successSnackBar(title: 'Thành công', message: 'Hồ sơ đã được cập nhật.');
    } catch (e) {
      print("UserController updateUserProfile Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Cập nhật thất bại', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Người dùng tự đổi mật khẩu (khi đã đăng nhập)
  Future<void> changeCurrentUserPassword({
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
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      Loaders.successSnackBar(title: 'Thành công', message: 'Mật khẩu đã được thay đổi.');
      // Cân nhắc: Có thể cần yêu cầu đăng nhập lại sau khi đổi mật khẩu thành công.
      // await _authController.logout();
    } catch (e) {
      print("UserController changeCurrentUserPassword Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Đổi mật khẩu thất bại', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Xử lý đặt lại mật khẩu (thường dùng trong luồng quên mật khẩu)
  Future<void> handleResetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _userService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      Loaders.successSnackBar(title: 'Thành công', message: 'Mật khẩu đã được đặt lại. Vui lòng đăng nhập.');
      Get.offAllNamed('/login'); // Điều hướng về màn hình đăng nhập
    } catch (e) {
      print("UserController handleResetPassword Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Đặt lại mật khẩu thất bại', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// Xóa người dùng (Admin only)
  Future<void> deleteUserByAdmin(String userIdToDelete) async {
    // Kiểm tra quyền admin ở client (tùy chọn, backend là nguồn chính)
    // if(!_authController.currentUser.value?.isAdmin == true) {
    //   Loaders.errorSnackBar(title: 'Lỗi', message: 'Bạn không có quyền thực hiện hành động này.');
    //   return;
    // }
    try {
      isLoading.value = true;
      error.value = '';
      await _userService.deleteUserByAdmin(userIdToDelete);
      Loaders.successSnackBar(
        title: 'Thành công',
        message: 'Xóa tài khoản người dùng thành công.',
      );
      // Cập nhật lại danh sách người dùng nếu đang hiển thị
      userList.removeWhere((user) => user.id == userIdToDelete);
      // Không tự động logout admin ở đây
    } catch (e) {
      print("UserController deleteUserByAdmin Error: $e");
      error.value = e.toString();
      Loaders.errorSnackBar(title: 'Lỗi xóa người dùng', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void checkProfileCompletion() {
    if (currentUser.value == null) {
      isProfileComplete.value = false;
      return;
    }
    final user = currentUser.value!;
    // fullname và phone là bắt buộc theo User model đã sửa, nhưng có thể null nếu mới tạo
    // User model đã được cập nhật, fullname là String, phone là String?
    isProfileComplete.value = user.fullname.isNotEmpty && (user.phone?.isNotEmpty ?? false);
  }

  String getFormattedName() {
    return currentUser.value?.fullname ?? '';
  }

  String getAvatarUrl() {
    // User model đã được sửa để avatar là object Avatar { url, publicId }
    return currentUser.value?.avatar.url ?? '';
  }

  String getPhone() {
    return currentUser.value?.phone ?? '';
  }

  bool isCurrentUserActive() {
    return currentUser.value?.isActive ?? false;
  }

  bool get isCurrentUserAdmin {
    return currentUser.value?.isAdmin ?? false;
  }
}
