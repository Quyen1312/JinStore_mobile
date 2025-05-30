// File: lib/features/authentication/models/user_model.dart

// Lớp Avatar giữ nguyên như trước nếu backend trả về cấu trúc tương tự cho avatar
class Avatar {
  final String url;
  final String? publicId;

  Avatar({
    this.url = '', // Giá trị mặc định nếu url là null từ JSON
    this.publicId,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['url'] = url;
    if (publicId != null && publicId!.isNotEmpty) { // Chỉ thêm nếu có giá trị
      data['publicId'] = publicId;
    }
    return data;
  }
}

class User {
  final String id; // Map từ _id của MongoDB
  final String username;
  final String fullname;
  final String email;
  final String? password; // Nullable, chỉ required khi authProvider là 'local'
  final String? phone;
  final String? gender; // 'male', 'female', 'other'
  final DateTime? dateBirth;
  final List<String> address; // Danh sách các ID của Address
  final bool isAdmin;
  final String authProvider; // 'local', 'google', 'facebook'
  final String? googleId;
  final String? facebookId; // Thêm trường facebookId
  final Avatar avatar;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    this.password,
    this.phone,
    this.gender,
    this.dateBirth,
    this.address = const [],
    this.isAdmin = false, // default từ schema
    this.authProvider = 'local', // default từ schema
    this.googleId,
    this.facebookId,
    required this.avatar, // default từ schema là { url: '', publicId: '' }
    this.isActive = true, // default từ schema
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '', // Ưu tiên _id
      username: json['username'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String?, // Password thường không được trả về từ API
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateBirth: json['dateBirth'] != null ? DateTime.tryParse(json['dateBirth'].toString()) : null,
      // address là một mảng các ObjectId, nên ở Flutter sẽ là List<String> chứa các ID đó
      address: (json['address'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isAdmin: json['isAdmin'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'local',
      googleId: json['googleId'] as String?,
      facebookId: json['facebookId'] as String?,
      avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>? ?? {'url': '', 'publicId': ''}), // Cung cấp giá trị mặc định cho Avatar.fromJson
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  /// Tạo JSON payload cho API đăng ký (/api/auth/register).
  /// Chỉ bao gồm các trường mà backend `registerUser` yêu cầu trong `req.body`.
  Map<String, dynamic> toRegisterJson() {
    final data = {
      'fullname': fullname.trim(),
      'username': username.trim(),
      'email': email.trim(),
      // Password và confirmPassword được gửi nếu có
      if (password != null && password!.isNotEmpty) 'password': password,
      // Backend `registerUser` của bạn lấy `confirmPassword` từ `req.body` để tự so sánh.
      // `SignupForm` sẽ đảm bảo `password` và `confirmPassword` nhập vào là giống nhau.
      if (password != null && password!.isNotEmpty) 'confirmPassword': password, 
      // Các trường khác như phone, gender, dateBirth không được backend `registerUser` sử dụng trực tiếp khi tạo user mới.
      // 'authProvider' sẽ được backend tự đặt là 'local' nếu không có thông tin khác.
    };
    return data;
  }

  /// Tạo JSON payload cho API cập nhật thông tin người dùng (/api/users/info-user/update).
  /// Chỉ bao gồm các trường người dùng được phép tự cập nhật.
  Map<String, dynamic> toUpdateJson() {
    final data = <String, dynamic>{};
    // Chỉ thêm vào data nếu giá trị không phải là giá trị khởi tạo rỗng/mặc định
    // hoặc nếu bạn muốn cho phép xóa giá trị bằng cách gửi chuỗi rỗng.
    // Điều này phụ thuộc vào logic backend của bạn.
    // Ở đây, chúng ta giả định nếu người dùng không thay đổi thì không gửi.
    // Tuy nhiên, để đơn giản, có thể gửi các giá trị hiện tại.
    
    data['fullname'] = fullname.trim();
    if (phone != null && phone!.isNotEmpty) data['phone'] = phone!.trim();
    if (gender != null && gender!.isNotEmpty) data['gender'] = gender;
    if (dateBirth != null) data['dateBirth'] = dateBirth!.toIso8601String();
    
    // Avatar update is complex: usually involves file upload to a separate endpoint,
    // then updating the avatar URL/publicId here.
    // If only URL/publicId strings are updated:
    // if (avatar.url.isNotEmpty) data['avatar'] = avatar.toJson(); // Hoặc chỉ gửi các trường con của avatar nếu API yêu cầu

    return data;
  }

  // toJson() này có thể dùng cho mục đích chung, không phải lúc nào cũng là để gửi lên API.
  // Ví dụ: lưu vào local storage, hoặc debug.
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Gửi _id nếu backend mong đợi
      'username': username,
      'fullname': fullname,
      'email': email,
      // Không bao giờ gửi password đã hash ngược lại client, hoặc gửi password thô lên server trừ khi là đăng ký/đổi mật khẩu
      'phone': phone,
      'gender': gender,
      'dateBirth': dateBirth?.toIso8601String(),
      'address': address, // Danh sách ID địa chỉ
      'isAdmin': isAdmin,
      'authProvider': authProvider,
      'googleId': googleId,
      'facebookId': facebookId,
      'avatar': avatar.toJson(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? fullname,
    String? email,
    // Không bao gồm password trong copyWith trừ khi có lý do rất cụ thể
    String? phone,
    String? gender,
    DateTime? dateBirth,
    List<String>? address,
    bool? isAdmin,
    String? authProvider,
    String? googleId,
    String? facebookId,
    Avatar? avatar,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      password: this.password, // Giữ nguyên password hiện tại khi copy
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateBirth: dateBirth ?? this.dateBirth,
      address: address ?? this.address,
      isAdmin: isAdmin ?? this.isAdmin,
      authProvider: authProvider ?? this.authProvider,
      googleId: googleId ?? this.googleId,
      facebookId: facebookId ?? this.facebookId,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
