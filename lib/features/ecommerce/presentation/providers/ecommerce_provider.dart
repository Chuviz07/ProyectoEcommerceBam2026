import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/product_firestore_datasource.dart';
import '../../data/datasources/product_storage_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider =
    Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final productFirestoreDatasourceProvider =
    Provider<ProductFirestoreDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return ProductFirestoreDatasource(
    firestore: firestore,
  );
});

final productStorageDatasourceProvider =
    Provider<ProductStorageDatasource>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  final uuid = ref.watch(uuidProvider);

  return ProductStorageDatasource(
    storage: storage,
    uuid: uuid,
  );
});

final productRepositoryProvider =
    Provider<ProductRepository>((ref) {
  final firestoreDatasource =
      ref.watch(productFirestoreDatasourceProvider);

  final storageDatasource =
      ref.watch(productStorageDatasourceProvider);

  return ProductRepositoryImpl(
    firestoreDatasource: firestoreDatasource,
    storageDatasource: storageDatasource,
  );
});

final getProductsUseCaseProvider =
    Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(
    ref.watch(productRepositoryProvider),
  );
});

final createProductUseCaseProvider =
    Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(
    ref.watch(productRepositoryProvider),
  );
});

final updateProductUseCaseProvider =
    Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(
    ref.watch(productRepositoryProvider),
  );
});

final deleteProductUseCaseProvider =
    Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(
    ref.watch(productRepositoryProvider),
  );
});

final productsProvider =
    StreamProvider<List<Product>>((ref) {
  final useCase =
      ref.watch(getProductsUseCaseProvider);

  return useCase();
});

class HomeProducts {
  final List<Product> recommended;
  final List<Product> summer;

  const HomeProducts({
    required this.recommended,
    required this.summer,
  });
}

final homeProductsProvider =
    Provider<AsyncValue<HomeProducts>>((ref) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.whenData((products) {
    return HomeProducts(
      recommended: products
          .where(
            (product) => product.isRecommended,
          )
          .toList(),
      summer: products
          .where(
            (product) => product.isSummer,
          )
          .toList(),
    );
  });
});

class ProductFormState {
  final bool isLoading;
  final String? errorMessage;

  const ProductFormState({
    this.isLoading = false,
    this.errorMessage,
  });
}

class ProductFormNotifier
    extends StateNotifier<ProductFormState> {
  final ProductRepository repository;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductFormNotifier({
    required this.repository,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(const ProductFormState());

  Future<void> createProduct({
    required Product product,
    Uint8List? imageBytes,
    String? imageExtension,
    String? imageContentType,
  }) async {
    state = const ProductFormState(
      isLoading: true,
    );

    try {
      var finalProduct = product;

      if (imageBytes != null) {
        final uploaded =
            await repository.uploadProductImage(
          bytes: imageBytes,
          fileExtension: imageExtension ?? 'jpg',
          contentType:
              imageContentType ?? 'image/jpeg',
        );

        finalProduct = product.copyWith(
          imageUrl: uploaded.downloadUrl,
          imageStoragePath: uploaded.storagePath,
        );
      }

      await createProductUseCase(finalProduct);

      state = const ProductFormState();
    } catch (error) {
      state = ProductFormState(
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> updateProduct({
    required Product product,
    Uint8List? newImageBytes,
    String? imageExtension,
    String? imageContentType,
  }) async {
    state = const ProductFormState(
      isLoading: true,
    );

    try {
      var updatedProduct = product;
      final oldStoragePath =
          product.imageStoragePath;

      if (newImageBytes != null) {
        final uploaded =
            await repository.uploadProductImage(
          bytes: newImageBytes,
          fileExtension: imageExtension ?? 'jpg',
          contentType:
              imageContentType ?? 'image/jpeg',
        );

        updatedProduct = product.copyWith(
          imageUrl: uploaded.downloadUrl,
          imageStoragePath: uploaded.storagePath,
        );
      }

      await updateProductUseCase(
        updatedProduct,
      );

      if (newImageBytes != null &&
          oldStoragePath.isNotEmpty) {
        await refDeleteOldImage(
          oldStoragePath,
        );
      }

      state = const ProductFormState();
    } catch (error) {
      state = ProductFormState(
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> refDeleteOldImage(
    String storagePath,
  ) async {
    final storageDatasource =
        ProductStorageDatasource(
      storage: FirebaseStorage.instance,
      uuid: const Uuid(),
    );

    await storageDatasource.deleteProductImage(
      storagePath,
    );
  }

  Future<void> deleteProduct(
    Product product,
  ) async {
    state = const ProductFormState(
      isLoading: true,
    );

    try {
      await deleteProductUseCase(product);

      state = const ProductFormState();
    } catch (error) {
      state = ProductFormState(
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }
}

final productFormNotifierProvider =
    StateNotifierProvider<ProductFormNotifier,
        ProductFormState>((ref) {
  return ProductFormNotifier(
    repository: ref.watch(productRepositoryProvider),
    createProductUseCase:
        ref.watch(createProductUseCaseProvider),
    updateProductUseCase:
        ref.watch(updateProductUseCaseProvider),
    deleteProductUseCase:
        ref.watch(deleteProductUseCaseProvider),
  );
});

final homeCarouselIndexProvider =
    StateProvider<int>((ref) => 0);

final selectedBottomNavIndexProvider =
    StateProvider<int>((ref) => 0);