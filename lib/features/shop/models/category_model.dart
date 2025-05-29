import 'dart:convert';

class CategoryImage {
  final String url;
  final String publicId;

  CategoryImage({
    this.url = '',
    this.publicId = '',
  });

  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
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

class CategoryModel {
  final String id; // Maps to _id
  final String code;
  final String name;
  final String slug;
  final String description;
  final bool isOutstanding;
  final String status; // 'active' or 'inactive'
  final CategoryImage image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.slug,
    this.description = '',
    this.isOutstanding = false,
    this.status = 'active',
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'slug': slug,
      'description': description,
      'isOutstanding': isOutstanding,
      'status': status,
      'image': image.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      isOutstanding: json['isOutstanding'] ?? false,
      status: json['status'] ?? 'active',
      image: CategoryImage.fromJson(json['image'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static empty method
  static CategoryModel empty() => CategoryModel(
        id: '',
        code: '',
        name: '',
        slug: '',
        image: CategoryImage(),
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static CategoryModel fromJsonString(String jsonString) {
    try {
      return CategoryModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}