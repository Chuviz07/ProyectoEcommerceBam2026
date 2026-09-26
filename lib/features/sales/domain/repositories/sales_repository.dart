import '../../../auth/domain/entities/app_user.dart';
import '../../../ecommerce/domain/entities/cart_item.dart';
import '../entities/sale_order.dart';

abstract class SalesRepository {
  Stream<List<SaleOrder>> watchAllOrders();

  Stream<List<SaleOrder>> watchCustomerOrders(String customerId);

  Future<SaleOrder> getOrderById(String orderId);

  Future<String> createOrder({
    required AppUser customer,
    required List<CartItem> cartItems,
    required String paymentMethod,
  });
}
