import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ecommerce/domain/entities/cart_item.dart';
import '../../../ecommerce/presentation/providers/ecommerce_provider.dart';
import '../../data/datasources/sales_firestore_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/entities/sale_order.dart';
import '../../domain/repositories/sales_repository.dart';

final salesDatasourceProvider = Provider<SalesFirestoreDatasource>((ref) {
  return SalesFirestoreDatasource(firestore: ref.watch(firestoreProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(datasource: ref.watch(salesDatasourceProvider));
});

final allOrdersProvider = StreamProvider<List<SaleOrder>>((ref) {
  return ref.watch(salesRepositoryProvider).watchAllOrders();
});

final customerOrdersProvider = StreamProvider<List<SaleOrder>>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(salesRepositoryProvider).watchCustomerOrders(user.uid);
});

final saleDetailProvider = FutureProvider.autoDispose
    .family<SaleOrder, String>((ref, saleId) {
  return ref.watch(salesRepositoryProvider).getOrderById(saleId);
});

class CheckoutState {
  final bool isLoading;
  final String? errorMessage;

  const CheckoutState({this.isLoading = false, this.errorMessage});
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final SalesRepository repository;

  CheckoutNotifier({required this.repository}) : super(const CheckoutState());

  Future<String?> completePurchase({
    required AppUser customer,
    required List<CartItem> cartItems,
    required String paymentMethod,
  }) async {
    state = const CheckoutState(isLoading: true);
    try {
      final orderId = await repository.createOrder(
        customer: customer,
        cartItems: cartItems,
        paymentMethod: paymentMethod,
      );
      state = const CheckoutState();
      return orderId;
    } catch (error) {
      state = CheckoutState(errorMessage: error.toString());
      return null;
    }
  }
}

final checkoutNotifierProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(repository: ref.watch(salesRepositoryProvider));
});
