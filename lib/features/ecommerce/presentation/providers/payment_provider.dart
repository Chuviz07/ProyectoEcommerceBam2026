import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_method.dart';

final paymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return const[
    PaymentMethod (
      id: 'Bam', 
      type: 'Credit Card', 
      name: 'VISA', 
      maskedNumber: 'xxxx xxxx xxx 1234',
      isCard: true
    ),
    PaymentMethod (
      id: 'Bam', 
      type: 'Credit Card', 
      name: 'MasterCard', 
      maskedNumber: 'xxxx xxxx xxx 7418',
      isCard: true
    ),
    PaymentMethod (
      id: 'Bam', 
      type: 'Credit Card', 
      name: 'VISA', 
      maskedNumber: 'xxxx xxxx xxx 4567',
      isCard: true
    )
  ];
});

final selectedPaymentMethodProvider = StateProvider<String>((ref) {
  return 'mastercard';
});

final billingSameAsShippingProvider = StateProvider<bool>((ref){
  return true; 
});