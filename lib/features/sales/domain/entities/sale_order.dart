import 'order_item.dart';

class SaleOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;

  const SaleOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
