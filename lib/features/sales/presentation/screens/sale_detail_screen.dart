import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_provider.dart';

class SaleDetailScreen extends ConsumerWidget {
  final String saleId;
  final String? notificationTotal;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
    this.notificationTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleDetailProvider(saleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la compra')),
      body: saleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 52, color: Colors.red),
                const SizedBox(height: 12),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(saleDetailProvider(saleId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Intentar de nuevo'),
                ),
              ],
            ),
          ),
        ),
        data: (sale) {
          final date = sale.createdAt;
          final dateText = date == null
              ? 'Fecha pendiente'
              : '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/${date.year} '
                  '${date.hour.toString().padLeft(2, '0')}:'
                  '${date.minute.toString().padLeft(2, '0')}';
          final sentTotal = double.tryParse(notificationTotal ?? '');

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(saleDetailProvider(saleId).future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Venta #${sale.id}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(dateText),
                        Text('Estado: ${sale.status}'),
                        Text('Método de pago: ${sale.paymentMethod}'),
                        const Divider(height: 28),
                        Text(
                          'Total: Q ${sale.total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (sentTotal != null && sentTotal != sale.total)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'El total mostrado fue actualizado desde Firestore.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Productos', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...sale.items.map(
                  (item) => Card(
                    child: ListTile(
                      leading: item.imageUrl.isEmpty
                          ? const Icon(Icons.inventory_2_outlined)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                      title: Text(item.productName),
                      subtitle: Text(
                        '${item.color} / ${item.size}\n'
                        '${item.quantity} x Q ${item.unitPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Text('Q ${item.subtotal.toStringAsFixed(2)}'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
