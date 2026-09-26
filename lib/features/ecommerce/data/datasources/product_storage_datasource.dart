import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ProductImageUploadResult {
  final String downloadUrl;
  final String storagePath;

  const ProductImageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
  });
}

class ProductStorageDatasource {
  final FirebaseStorage storage;
  final Uuid uuid;

  ProductStorageDatasource({
    required this.storage,
    required this.uuid,
  });

  Future<ProductImageUploadResult> uploadProductImage({
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) async {
    final imageId = uuid.v4();

    final normalizedExtension =
        fileExtension.replaceAll('.', '').toLowerCase();

    final storagePath =
        'products/$imageId/product.$normalizedExtension';

    final reference = storage.ref(
      storagePath,
    );

    final metadata = SettableMetadata(
      contentType: contentType,
    );

    await reference.putData(
      bytes,
      metadata,
    );

    final downloadUrl =
        await reference.getDownloadURL();

    return ProductImageUploadResult(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
    );
  }

  Future<void> deleteProductImage(
    String storagePath,
  ) async {
    if (storagePath.trim().isEmpty) {
      return;
    }

    try {
      await storage.ref(storagePath).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }
}