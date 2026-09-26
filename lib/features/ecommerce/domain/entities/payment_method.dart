class PaymentMethod {
  final String id;
  final String type;
  final String name;
  final String maskedNumber;
  final bool  isCard;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.maskedNumber,
    required this.isCard,
  });
}