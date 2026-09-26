import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.imageUrl,
    required super.unitPrice,
    required super.quantity,
    required super.size,
    required super.color,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      size: map['size']?.toString() ?? '',
      color: map['color']?.toString() ?? '',
    );
  }

  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      productId: item.productId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      size: item.size,
      color: item.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'size': size,
      'color': color,
      'subtotal': subtotal,
    };
  }
}
