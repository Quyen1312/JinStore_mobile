// Lớp con để biểu diễn đối tượng avatar
class Avatar {
  final String url;
  final String publicId;

  Avatar({
    required this.url,
    required this.publicId,
  });

  factory Avatar.fromJson(Map<String, dynamic>? json) {
    // Nếu json là null hoặc không chứa các key cần thiết, trả về giá trị mặc định
    if (json == null) {
      return Avatar(url: '', publicId: '');
    }
    return Avatar(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

// Giả sử bạn sẽ có một AddressModel riêng.
// Vì chưa có schema của Address, tạm thời dùng Map<String, dynamic> hoặc một class đơn giản.
// class AddressModel {
//   final String id;
//   // ... các trường khác của Address
//   AddressModel({required this.id, /* ... */});

//   factory AddressModel.fromJson(Map<String, dynamic> json) {
//     return AddressModel(id: json['_id'], /* ... */);
//   }
// }


class User {
  final String id; // Từ _id của Mongoose
  final String username;
  final String fullname;
  final String email;
  final String? phone;
  final Avatar avatar; // Đã sửa: dùng lớp Avatar
  final bool isAdmin;  // Đã sửa: từ 'role' thành 'isAdmin' và kiểu bool
  final bool isActive;
  final String? gender; // Thêm mới
  final DateTime? dateBirth; // Thêm mới
  final List<dynamic> addresses; // Thêm mới - Nên là List<AddressModel> nếu có
  final String authProvider; // Thêm mới
  final String? googleId; // Thêm mới
  final String? facebookId; // Thêm mới
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    this.phone,
    required this.avatar, // Sửa: non-nullable Avatar
    required this.isAdmin,
    required this.isActive,
    this.gender,
    this.dateBirth,
    required this.addresses,
    required this.authProvider,
    this.googleId,
    this.facebookId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>?), // Sửa: parse đối tượng Avatar
      isAdmin: json['isAdmin'] as bool? ?? false, // Sửa: parse isAdmin
      isActive: json['isActive'] as bool? ?? true,
      gender: json['gender'] as String?,
      dateBirth: json['dateBirth'] == null
          ? null
          : DateTime.tryParse(json['dateBirth'] as String),
      addresses: (json['address'] as List<dynamic>?)?.map((e) => e as dynamic).toList() ?? [], // Sửa: parse mảng address, nên thay 'dynamic' bằng 'AddressModel.fromJson'
      authProvider: json['authProvider'] as String? ?? 'local',
      googleId: json['googleId'] as String?,
      facebookId: json['facebookId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'avatar': avatar.toJson(), // Sửa: serialize đối tượng Avatar
      'isAdmin': isAdmin,
      'isActive': isActive,
      'gender': gender,
      'dateBirth': dateBirth?.toIso8601String(),
      'address': addresses.map((e) => e /* e.toJson() nếu là AddressModel */).toList(),
      'authProvider': authProvider,
      'googleId': googleId,
      'facebookId': facebookId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? fullname,
    String? email,
    String? phone,
    Avatar? avatar,
    bool? isAdmin,
    bool? isActive,
    String? gender,
    DateTime? dateBirth,
    List<dynamic>? addresses,
    String? authProvider,
    String? googleId,
    String? facebookId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      dateBirth: dateBirth ?? this.dateBirth,
      addresses: addresses ?? this.addresses,
      authProvider: authProvider ?? this.authProvider,
      googleId: googleId ?? this.googleId,
      facebookId: facebookId ?? this.facebookId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
