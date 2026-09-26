import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sale_order.dart';
import 'order_item_model.dart';

class SaleOrderModel extends SaleOrder {
  const SaleOrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.customerEmail,
    required super.items,
    required super.total,
    required super.paymentMethod,
    required super.status,
    super.createdAt,
  });

  factory SaleOrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawItems = data['items'] as List<dynamic>? ?? const [];

    return SaleOrderModel(
      id: document.id,
      customerId: data['customerId']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      customerEmail: data['customerEmail']?.toString() ?? '',
      items: rawItems
          .whereType<Map>()
          .map((item) => OrderItemModel.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      status: data['status']?.toString() ?? 'completed',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
