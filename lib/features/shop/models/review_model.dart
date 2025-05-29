import 'dart:convert';

class ReviewModel {
  final String id; // Maps to _id
  final String user; // Maps to user ID
  final String product; // Maps to product ID
  final int rating;
  final String comment;
  final List<String> likes; // List of user IDs
  final bool isVerifiedPurchase;
  final String status; // 'pending', 'approved', 'rejected'
  final int likeCount; // Virtual field
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.user,
    required this.product,
    required this.rating,
    required this.comment,
    this.likes = const [],
    this.isVerifiedPurchase = false,
    this.status = 'pending',
    this.likeCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Convert ReviewModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'product': product,
      'rating': rating,
      'comment': comment,
      'likes': likes,
      'isVerifiedPurchase': isVerifiedPurchase,
      'status': status,
      'likeCount': likeCount,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create ReviewModel from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      rating: json['rating'] ?? 1,
      comment: json['comment'] ?? '',
      likes: (json['likes'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      status: json['status'] ?? 'pending',
      likeCount: json['likeCount'] ?? (json['likes'] as List<dynamic>?)?.length ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Static empty method
  static ReviewModel empty() => ReviewModel(
        id: '',
        user: '',
        product: '',
        rating: 1,
        comment: '',
      );

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static ReviewModel fromJsonString(String jsonString) {
    try {
      return ReviewModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }
}