import 'dart:typed_data';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_firestore_datasource.dart';
import '../datasources/product_storage_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductFirestoreDatasource firestoreDatasource;
  final ProductStorageDatasource storageDatasource;

  ProductRepositoryImpl({
    required this.firestoreDatasource,
    required this.storageDatasource,
  });

  @override
  Stream<List<Product>> watchProducts() {
    return firestoreDatasource.watchProducts();
  }

  @override
  Future<List<Product>> getProducts() {
    return firestoreDatasource.getProducts();
  }

  @override
  Future<String> createProduct(
    Product product,
  ) {
    final model = ProductModel.fromEntity(product);

    return firestoreDatasource.createProduct(
      model,
    );
  }

  @override
  Future<void> updateProduct(
    Product product,
  ) {
    final model = ProductModel.fromEntity(product);

    return firestoreDatasource.updateProduct(
      model,
    );
  }

  @override
  Future<void> deleteProduct(
    Product product,
  ) async {
    await firestoreDatasource.deleteProduct(
      product.id,
    );

    if (product.imageStoragePath.isNotEmpty) {
      await storageDatasource.deleteProductImage(
        product.imageStoragePath,
      );
    }
  }

  @override
  Future<UploadedProductImage> uploadProductImage({
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) async {
    final result =
        await storageDatasource.uploadProductImage(
      bytes: bytes,
      fileExtension: fileExtension,
      contentType: contentType,
    );

    return UploadedProductImage(
      downloadUrl: result.downloadUrl,
      storagePath: result.storagePath,
    );
  }
}