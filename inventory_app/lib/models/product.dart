class Product {
  final int id;
  final String name;
  final String? description;
  final int stock;
  final double price;
  final String? category;
  final String? image;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.stock,
    required this.price,
    this.category,
    this.image,
  });

  factory Product.fromJson(Map<String,dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    stock: json['stock'],
    price: (json['price'] as num).toDouble(),
    category: json['category'],
    image: json['image'],
  );
}
