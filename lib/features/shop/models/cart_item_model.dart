class CartItemModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? unit;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'unit': unit,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'],
    name: json['name'],
    price: json['price'].toDouble(),
    quantity: json['quantity'],
    imageUrl: json['imageUrl'],
    unit: json['unit'],
  );
} 