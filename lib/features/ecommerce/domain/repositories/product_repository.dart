import 'dart:typed_data';

import '../entities/product.dart';

class UploadedProductImage {
  final String downloadUrl;
  final String storagePath;

  const UploadedProductImage({
    required this.downloadUrl,
    required this.storagePath,
  });
}

abstract class ProductRepository {
  Stream<List<Product>> watchProducts();

  Future<List<Product>> getProducts();

  Future<String> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(Product product);

  Future<UploadedProductImage> uploadProductImage({
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  });
}