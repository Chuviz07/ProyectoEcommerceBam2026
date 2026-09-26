import '../../../auth/domain/entities/app_user.dart';
import '../../../ecommerce/domain/entities/cart_item.dart';
import '../../domain/entities/sale_order.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_firestore_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesFirestoreDatasource datasource;

  SalesRepositoryImpl({required this.datasource});

  @override
  Stream<List<SaleOrder>> watchAllOrders() => datasource.watchAllOrders();

  @override
  Stream<List<SaleOrder>> watchCustomerOrders(String customerId) =>
      datasource.watchCustomerOrders(customerId);

  @override
  Future<SaleOrder> getOrderById(String orderId) =>
      datasource.getOrderById(orderId);

  @override
  Future<String> createOrder({
    required AppUser customer,
    required List<CartItem> cartItems,
    required String paymentMethod,
  }) {
    return datasource.createOrder(
      customer: customer,
      cartItems: cartItems,
      paymentMethod: paymentMethod,
    );
  }
}
