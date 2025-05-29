class Avatar {
  final String url;
  final String publicId;

  Avatar({
    this.url = '',
    this.publicId = '',
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

class User {
  final String id;
  final String username;
  final String fullname;
  final String email;
  final String? password; // Only required for authProvider: 'local'
  final String? phone;
  final String? gender; // 'male', 'female', 'other'
  final DateTime? dateBirth;
  final List<String> address; // List of Address IDs
  final bool isAdmin;
  final String authProvider; // 'local', 'google', 'facebook'
  final String? googleId;
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
    this.isAdmin = false,
    this.authProvider = 'local',
    this.googleId,
    required this.avatar,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a User from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'],
      gender: json['gender'],
      dateBirth: json['dateBirth'] != null ? DateTime.parse(json['dateBirth']) : null,
      address: (json['address'] as List<dynamic>?)?.cast<String>() ?? [],
      isAdmin: json['isAdmin'] ?? false,
      authProvider: json['authProvider'] ?? 'local',
      googleId: json['googleId'],
      avatar: Avatar.fromJson(json['avatar'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert User instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
      'email': email,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (dateBirth != null) 'dateBirth': dateBirth!.toIso8601String(),
      'address': address,
      'isAdmin': isAdmin,
      'authProvider': authProvider,
      if (googleId != null) 'googleId': googleId,
      'avatar': avatar.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

}