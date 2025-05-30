    // File: lib/features/shop/models/category_nested_model.dart
    class CategoryNestedModel {
      final String id;
      final String name;
      // Thêm các trường khác của Category nếu backend populate và bạn cần, ví dụ: image
      // final String? image; 

      CategoryNestedModel({
        required this.id,
        required this.name,
        // this.image,
      });

      factory CategoryNestedModel.fromJson(Map<String, dynamic> json) {
        return CategoryNestedModel(
          id: json['_id'] as String? ?? json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          // image: json['image'] as String?, // Nếu có trường image
        );
      }

      Map<String, dynamic> toJson() {
        return {
          '_id': id,
          'name': name,
          // if (image != null) 'image': image,
        };
      }
    }
    