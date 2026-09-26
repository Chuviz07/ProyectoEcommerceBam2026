import '../entities/product.dart';
import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(Product product) {
    return repository.deleteProduct(product);
  }
}