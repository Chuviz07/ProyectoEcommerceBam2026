// import '../entities/product.dart';
// import '../repositories/product_repository.dart';

// class HomeProducts {
//   final List<Product> recommended;
//   final List<Product> summer;

//   const HomeProducts({
//     required this.recommended,
//     required this.summer,
//   });
// }

// class GetHomeProductsUseCase {
//   final ProductRepository repository;

//   const GetHomeProductsUseCase(this.repository);

//   HomeProducts call() {
//     return HomeProducts(
//       recommended: repository.getRecommendedProducts(),
//       summer: repository.getSummerProducts(),
//     );
//   }
// }