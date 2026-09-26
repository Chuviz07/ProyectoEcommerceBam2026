import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../sales/presentation/providers/sales_provider.dart';
import '../../../sales/presentation/screens/customer_purchase_history_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethods = ref.watch(paymentMethodsProvider);
    final selectedPaymentId = ref.watch(selectedPaymentMethodProvider);
    final billingSameAsShipping = ref.watch(billingSameAsShippingProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final cardMethods = paymentMethods.where((method) => method.isCard).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: checkoutState.isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Pago', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Elige un método de pago',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Al confirmar se registrará la venta y se descontará la existencia.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    ...cardMethods.map((method) {
                      final selected = selectedPaymentId == method.id;
                      return Card(
                        child: RadioListTile<String>(
                          value: method.id,
                          groupValue: selectedPaymentId,
                          onChanged: checkoutState.isLoading
                              ? null
                              : (value) {
                                  if (value != null) {
                                    ref.read(selectedPaymentMethodProvider.notifier).state = value;
                                  }
                                },
                          title: Text(method.name),
                          subtitle: Text(method.maskedNumber),
                          secondary: Icon(
                            Icons.credit_card,
                            color: selected ? const Color(0xFF0A7CFF) : Colors.grey,
                          ),
                        ),
                      );
                    }),
                    CheckboxListTile(
                      value: billingSameAsShipping,
                      onChanged: checkoutState.isLoading
                          ? null
                          : (value) {
                              ref.read(billingSameAsShippingProvider.notifier).state = value ?? false;
                            },
                      title: const Text(
                        'La dirección de facturación es igual a la dirección de envío',
                        style: TextStyle(fontSize: 12),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (checkoutState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          checkoutState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text('Total', style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  Text(
                    'Q ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: checkoutState.isLoading
                      ? null
                      : () => _completePurchase(context, ref, selectedPaymentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A7CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: checkoutState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirmar compra'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completePurchase(
    BuildContext context,
    WidgetRef ref,
    String selectedPaymentId,
  ) async {
    final user = ref.read(authUserProvider).valueOrNull;
    final items = ref.read(cartProvider);
    final methods = ref.read(paymentMethodsProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comprar.')),
      );
      return;
    }

    final matchingMethods = methods.where((method) => method.id == selectedPaymentId);
    final selectedMethod = matchingMethods.isEmpty ? null : matchingMethods.first;
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un método de pago.')),
      );
      return;
    }

    // El trigger se ejecuta inmediatamente después de crear orders/{saleId}.
    // Por eso guardamos el token antes de registrar la compra.
    final notificationsReady = await NotificationService.instance
        .prepareForPurchaseNotification();

    if (!context.mounted) return;
    if (!notificationsReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La compra continuará, pero no recibirás la notificación porque '
            'el permiso no está activo.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    final orderId = await ref.read(checkoutNotifierProvider.notifier).completePurchase(
          customer: user,
          cartItems: items,
          paymentMethod: selectedMethod.name,
        );

    if (!context.mounted || orderId == null) return;

    ref.read(cartProvider.notifier).clear();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
        title: const Text('Compra realizada'),
        content: Text(
          notificationsReady
              ? 'La venta fue registrada. Recibirás una notificación con el detalle.'
              : 'La venta fue registrada y la existencia fue actualizada.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ver mis compras'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerPurchaseHistoryScreen()),
      (route) => route.isFirst,
    );
  }
}
