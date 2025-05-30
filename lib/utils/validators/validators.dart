class Validator {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống.';
    }
    // Sử dụng regex được cung cấp bởi người dùng cho email
    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Địa chỉ email không hợp lệ.';
    }
    return null;
  }

  static String? validateFullname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Họ và tên không được để trống.';
    }
    // Regex cho fullname: Chấp nhận chữ cái (bao gồm tiếng Việt có dấu) và khoảng trắng.
    // Dart không hỗ trợ \p{L} trực tiếp. Regex này là một sự thay thế.
    // Bạn có thể cần điều chỉnh nó nếu muốn hỗ trợ nhiều loại ký tự hơn
    // hoặc sử dụng một package regex mạnh hơn nếu cần độ chính xác Unicode cao.
    final fullnameRegExp = RegExp(r'^[a-zA-ZàáãạảăắằẳẵặâấầẩẫậèéẹẻẽêềếểễệđìíịỉĩòóõọỏôốồổỗộơớờởỡợùúũụủưứừửữựỳỵỷỹýÀÁÃẠẢĂẮẰẲẴẶÂẤẦẨẪẬÈÉẸẺẼÊỀẾỂỄỆĐÌÍỊỈĨÒÓÕỌỎÔỐỒỔỖỘƠỚỜỞỠỢÙÚŨỤỦƯỨỪỬỮỰỲỴỶỸÝ\s]+$');
    if (!fullnameRegExp.hasMatch(value)) {
      return 'Họ và tên không hợp lệ (chỉ nên chứa chữ cái và khoảng trắng).';
    }
    return null;
  }


  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ thường.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ HOA.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ số.';
    }
    // Backend không yêu cầu ký tự đặc biệt, nhưng nếu bạn muốn, có thể thêm:
    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt.';
    // }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu.';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      // Backend không dùng phone khi đăng ký, nên có thể cho phép rỗng ở client
      return null; 
    }
    // Backend không validate SĐT khi đăng ký, nhưng nếu muốn có ở client:
    final phoneRegExp = RegExp(r'^\d{10}$'); // Ví dụ: 10 chữ số
    if (!phoneRegExp.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ (yêu cầu 10 chữ số).';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên đăng nhập không được để trống.';
    }
    if (value.length < 4) { // Ví dụ: yêu cầu tối thiểu 4 ký tự
      return 'Tên đăng nhập phải có ít nhất 4 ký tự.';
    }
    if (value.contains(' ')) {
        return 'Tên đăng nhập không được chứa khoảng trắng.';
    }
    // Kiểm tra ký tự đặc biệt cho username (chỉ cho phép chữ, số, gạch dưới, gạch nối)
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegExp.hasMatch(value)) {
      return 'Tên đăng nhập chỉ chứa chữ, số, "_" hoặc "-".';
    }
    return null;
  }
}
