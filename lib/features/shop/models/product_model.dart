class ProductImage {
  final String url;
  final String publicId;

  ProductImage({
    this.url = '',
    this.publicId = '',
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }
}

class ProductInformation {
  final String key;
  final String value;

  ProductInformation({
    required this.key,
    required this.value,
  });

  factory ProductInformation.fromJson(Map<String, dynamic> json) {
    return ProductInformation(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

}

class ProductModel {
  final String id; // Maps to _id
  final String name;
  final String description;
  final double price;
  final String unit;
  final double discount;
  final int quantity;
  final String? categoryId; // Maps to _idCategory
  final String? reviewId; // Maps to _idReview
  final double averageRating;
  final bool isActive;
  final List<ProductImage> images;
  final List<ProductInformation> information;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    this.discount = 0.0,
    this.quantity = 0,
    this.categoryId,
    this.reviewId,
    this.averageRating = 0.0,
    this.isActive = true,
    this.images = const [],
    this.information = const [],
    this.createdAt,
    this.updatedAt,
  });


  // Create ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      categoryId: json['_idCategory']?.toString() ?? json['categoryId']?.toString(),
      reviewId: json['_idReview']?.toString() ?? json['reviewId']?.toString(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => ProductImage.fromJson(image))
              .toList() ??
          [],
      information: (json['information'] as List<dynamic>?)
              ?.map((info) => ProductInformation.fromJson(info))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

}
class Product{
    late List<ProductModel> _products;
    List<ProductModel> get products => _products;
    Product({required products}){
      _products = products;
    }

    Product.fromJson(Map<String, dynamic> json) {
      if(json['products'] != null){
        _products = <ProductModel>[];
        json['products'].forEach((v){
          _products.add(ProductModel.fromJson(v));
        });
      }
    }
  }