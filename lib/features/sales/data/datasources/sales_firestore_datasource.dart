import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../ecommerce/domain/entities/cart_item.dart';
import '../models/order_item_model.dart';
import '../models/sale_order_model.dart';

class SalesFirestoreDatasource {
  final FirebaseFirestore firestore;

  SalesFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _orders =>
      firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _products =>
      firestore.collection('products');

  Stream<List<SaleOrderModel>> watchAllOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(SaleOrderModel.fromFirestore).toList(),
        );
  }

  Stream<List<SaleOrderModel>> watchCustomerOrders(String customerId) {
    return _orders.where('customerId', isEqualTo: customerId).snapshots().map(
      (snapshot) {
        final orders = snapshot.docs.map(SaleOrderModel.fromFirestore).toList();
        orders.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return orders;
      },
    );
  }

  Future<SaleOrderModel> getOrderById(String orderId) async {
    final document = await _orders.doc(orderId).get();

    if (!document.exists || document.data() == null) {
      throw Exception('No existe la venta con ID $orderId.');
    }

    return SaleOrderModel.fromFirestore(document);
  }

  Future<String> createOrder({
    required AppUser customer,
    required List<CartItem> cartItems,
    required String paymentMethod,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('No se puede registrar una compra con el carrito vacío.');
    }

    final orderReference = _orders.doc();

    await firestore.runTransaction((transaction) async {
      final quantityByProduct = <String, int>{};
      for (final item in cartItems) {
        quantityByProduct.update(
          item.product.id,
          (quantity) => quantity + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }

      final productSnapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};

      // Firestore exige realizar todas las lecturas antes de las escrituras.
      for (final productId in quantityByProduct.keys) {
        final reference = _products.doc(productId);
        productSnapshots[productId] = await transaction.get(reference);
      }

      for (final entry in quantityByProduct.entries) {
        final snapshot = productSnapshots[entry.key]!;
        if (!snapshot.exists) {
          throw Exception('Uno de los productos ya no existe.');
        }

        final currentStock = (snapshot.data()!['stock'] as num?)?.toInt() ?? 0;
        if (currentStock < entry.value) {
          final productName = snapshot.data()!['name']?.toString() ?? 'Producto';
          throw Exception(
            'No hay existencia suficiente de $productName. Disponible: $currentStock.',
          );
        }
      }

      final itemModels = <OrderItemModel>[];
      var total = 0.0;

      for (final cartItem in cartItems) {
        final productData = productSnapshots[cartItem.product.id]!.data()!;
        final currentPrice =
            (productData['price'] as num?)?.toDouble() ?? cartItem.product.price;
        final currentName =
            productData['name']?.toString() ?? cartItem.product.name;
        final currentImageUrl =
            productData['imageUrl']?.toString() ?? cartItem.product.imageUrl;

        itemModels.add(
          OrderItemModel(
            productId: cartItem.product.id,
            productName: currentName,
            imageUrl: currentImageUrl,
            unitPrice: currentPrice,
            quantity: cartItem.quantity,
            size: cartItem.size,
            color: cartItem.color,
          ),
        );
        total += currentPrice * cartItem.quantity;
      }

      for (final entry in quantityByProduct.entries) {
        final snapshot = productSnapshots[entry.key]!;
        final currentStock = (snapshot.data()!['stock'] as num?)?.toInt() ?? 0;
        transaction.update(_products.doc(entry.key), {
          'stock': currentStock - entry.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(orderReference, {
        'customerId': customer.uid,
        'customerName': customer.name,
        'customerEmail': customer.email,
        'items': itemModels.map((item) => item.toMap()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'status': 'completed',
        'notificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return orderReference.id;
  }
}
