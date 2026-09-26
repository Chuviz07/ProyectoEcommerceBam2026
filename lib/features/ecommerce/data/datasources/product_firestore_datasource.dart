import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductFirestoreDatasource {
  final FirebaseFirestore firestore;

  ProductFirestoreDatasource({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>>
      get _productsCollection {
    return firestore.collection('products');
  }

  Stream<List<ProductModel>> watchProducts() {
    return _productsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(ProductModel.fromFirestore)
          .toList();
    });
  }

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _productsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs
        .map(ProductModel.fromFirestore)
        .toList();
  }

  Future<String> createProduct(
    ProductModel product,
  ) async {
    final document = _productsCollection.doc();

    final productWithId = ProductModel(
      id: document.id,
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

    await document.set(
      productWithId.toCreateMap(),
    );

    return document.id;
  }

  Future<void> updateProduct(
    ProductModel product,
  ) async {
    if (product.id.isEmpty) {
      throw Exception(
        'No se puede actualizar un producto sin ID',
      );
    }

    await _productsCollection
        .doc(product.id)
        .update(
          product.toUpdateMap(),
        );
  }

  Future<void> deleteProduct(
    String productId,
  ) async {
    if (productId.isEmpty) {
      throw Exception(
        'No se puede eliminar un producto sin ID',
      );
    }

    await _productsCollection
        .doc(productId)
        .delete();
  }
}