import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  final int quantity;

  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  CartItem copyWith({
    Product? product,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => product.price * quantity;
}