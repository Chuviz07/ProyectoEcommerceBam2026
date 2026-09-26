import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.imageUrl,
    required super.imageStoragePath,
    required super.description,
    required super.sizes,
    required super.colors,
    required super.stock,
    required super.isRecommended,
    required super.isSummer,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'El producto ${document.id} no contiene información',
      );
    }

    return ProductModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl']?.toString() ?? '',
      imageStoragePath:
          data['imageStoragePath']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      sizes: List<String>.from(
        data['sizes'] ?? const [],
      ),
      colors: List<String>.from(
        data['colors'] ?? const [],
      ),
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isRecommended:
          data['isRecommended'] as bool? ?? false,
      isSummer: data['isSummer'] as bool? ?? false,
      createdAt: _timestampToDateTime(
        data['createdAt'],
      ),
      updatedAt: _timestampToDateTime(
        data['updatedAt'],
      ),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      imageUrl: product.imageUrl,
      imageStoragePath: product.imageStoragePath,
      description: product.description,
      sizes: product.sizes,
      colors: product.colors,
      stock: product.stock,
      isRecommended: product.isRecommended,
      isSummer: product.isSummer,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'stock': stock,
      'isRecommended': isRecommended,
      'isSummer': isSummer,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'stock': stock,
      'isRecommended': isRecommended,
      'isSummer': isSummer,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _timestampToDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}