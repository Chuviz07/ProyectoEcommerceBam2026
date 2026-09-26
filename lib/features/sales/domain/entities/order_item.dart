class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final String size;
  final String color;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.size,
    required this.color,
  });

  double get subtotal => unitPrice * quantity;
}
