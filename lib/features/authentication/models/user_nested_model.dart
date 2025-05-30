    // File: lib/features/authentication/models/user_nested_model.dart (hoặc trong shop/models)
    class UserNestedModel {
      final String id; // Backend populate user, nên có _id
      final String username;
      final String email;

      UserNestedModel({
        required this.id,
        required this.username,
        required this.email,
      });

      factory UserNestedModel.fromJson(Map<String, dynamic> json) {
        return UserNestedModel(
          id: json['_id'] as String? ?? json['id'] as String? ?? '',
          username: json['username'] as String? ?? '',
          email: json['email'] as String? ?? '',
        );
      }

      Map<String, dynamic> toJson() {
        return {
          '_id': id,
          'username': username,
          'email': email,
        };
      }
    }
    