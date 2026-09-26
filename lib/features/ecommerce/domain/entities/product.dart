class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String imageStoragePath;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final bool isRecommended;
  final bool isSummer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.imageStoragePath,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.isRecommended,
    required this.isSummer,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? imageUrl,
    String? imageStoragePath,
    String? description,
    List<String>? sizes,
    List<String>? colors,
    int? stock,
    bool? isRecommended,
    bool? isSummer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageStoragePath:
          imageStoragePath ?? this.imageStoragePath,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      stock: stock ?? this.stock,
      isRecommended:
          isRecommended ?? this.isRecommended,
      isSummer: isSummer ?? this.isSummer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}