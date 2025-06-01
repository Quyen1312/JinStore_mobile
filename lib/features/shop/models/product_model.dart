// File: lib/features/shop/models/product_model.dart

class ImageModel {
  final String url;
  final String? publicId;

  ImageModel({required this.url, this.publicId});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
        'url': url,
        if (publicId != null) 'publicId': publicId,
      };
}

class ProductInformation {
  final String key;
  final String value;
  
  ProductInformation({required this.key, required this.value});
  
  factory ProductInformation.fromJson(Map<String, dynamic> json) {
    return ProductInformation(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double discount;
  final int quantity;
  final int countBuy;
  
  final String? categoryId; // Từ _idCategory
  final String? categoryName; // Nếu populate category
  
  final List<ImageModel> images;
  final List<ProductInformation> information;
  
  // Thay đổi: _idReview là singular trong schema, không phải array
  final String? reviewId; // Từ _idReview trong Mongoose
  
  final double averageRating;
  final bool isActive;
  
  // Loại bỏ isFeatured vì không có trong schema
  // Bạn có thể thêm logic để determine featured products khác
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.discount,
    required this.quantity,
    required this.countBuy,
    this.categoryId,
    this.categoryName,
    required this.images,
    required this.information,
    this.reviewId, // Singular, not array
    required this.averageRating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter để check nếu product là featured (có thể dựa trên logic business)
  bool get isFeatured {
    // Ví dụ logic: sản phẩm có averageRating >= 4.0 hoặc countBuy > 100
    return averageRating >= 4.0 || countBuy > 100;
  }

  // Getter để check nếu sản phẩm available
  bool get isAvailable {
    return isActive && quantity > 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Hàm helper để parse int một cách an toàn
    int _parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Hàm helper để parse double một cách an toàn
    double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Hàm helper để parse boolean an toàn
    bool _parseBool(dynamic value, {bool defaultValue = false}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      if (value is int) return value == 1;
      return defaultValue;
    }

    // Hàm helper để parse String từ ObjectId hoặc String
    String? _parseObjectIdToString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic> && value.containsKey('\$oid')) {
        return value['\$oid'] as String;
      }
      return value.toString();
    }

    // Hàm helper để parse DateTime
    DateTime _parseDateTime(dynamic value, {DateTime? defaultValue}) {
      if (value == null) return defaultValue ?? DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? (defaultValue ?? DateTime.now());
      }
      if (value is Map<String, dynamic> && value.containsKey('\$date')) {
        String dateStr = value['\$date'] as String;
        return DateTime.tryParse(dateStr) ?? (defaultValue ?? DateTime.now());
      }
      return defaultValue ?? DateTime.now();
    }
    
    // Xử lý categoryId và categoryName
    String? catId;
    String? catName;
    
    if (json['_idCategory'] != null) {
      var categoryData = json['_idCategory'];
      if (categoryData is String) {
        catId = categoryData;
      } else if (categoryData is Map<String, dynamic>) {
        // Nếu category được populate
        catId = _parseObjectIdToString(categoryData['_id']);
        catName = categoryData['name'] as String?;
      } else {
        catId = _parseObjectIdToString(categoryData);
      }
    }

    // Parse images array
    List<ImageModel> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var imageData in json['images'] as List<dynamic>) {
        try {
          if (imageData is Map<String, dynamic>) {
            parsedImages.add(ImageModel.fromJson(imageData));
          }
        } catch (e) {
          print('[WARNING] Failed to parse image: $e');
        }
      }
    }

    // Parse information array
    List<ProductInformation> parsedInformation = [];
    if (json['information'] != null && json['information'] is List) {
      for (var infoData in json['information'] as List<dynamic>) {
        try {
          if (infoData is Map<String, dynamic>) {
            parsedInformation.add(ProductInformation.fromJson(infoData));
          }
        } catch (e) {
          print('[WARNING] Failed to parse information: $e');
        }
      }
    }

    return ProductModel(
      id: _parseObjectIdToString(json['_id']) ?? '',
      name: json['name'] as String? ?? 'Sản phẩm không tên',
      description: json['description'] as String? ?? '',
      price: _parseDouble(json['price']),
      unit: json['unit'] as String? ?? '',
      discount: _parseDouble(json['discount']),
      quantity: _parseInt(json['quantity']),
      countBuy: _parseInt(json['countBuy']),
      
      categoryId: catId,
      categoryName: catName,

      images: parsedImages,
      information: parsedInformation,
      
      // _idReview là singular trong schema
      reviewId: _parseObjectIdToString(json['_idReview']),
      
      averageRating: _parseDouble(json['averageRating']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
      
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'discount': discount,
      'quantity': quantity,
      'countBuy': countBuy,
      'averageRating': averageRating,
      'isActive': isActive,
      'images': images.map((img) => img.toJson()).toList(),
      'information': information.map((info) => info.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (categoryId != null) '_idCategory': categoryId,
      if (reviewId != null) '_idReview': reviewId,
    };
  }
}