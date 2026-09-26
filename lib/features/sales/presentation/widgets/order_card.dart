import 'package:flutter/material.dart';

import '../../domain/entities/sale_order.dart';

class OrderCard extends StatelessWidget {
  final SaleOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt;
    final dateText = date == null
        ? 'Procesando fecha'
        : '${_two(date.day)}/${_two(date.month)}/${date.year} '
            '${_two(date.hour)}:${_two(date.minute)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        title: Text(
          'Compra #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$dateText · ${order.totalItems} artículo(s)'),
        trailing: Text(
          'Q ${order.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (order.customerName.isNotEmpty || order.customerEmail.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(order.customerName.isEmpty ? 'Cliente' : order.customerName),
              subtitle: Text(order.customerEmail),
            ),
          ...order.items.map(
            (item) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: item.imageUrl.isEmpty
                      ? const ColoredBox(
                          color: Color(0xFFE9EDF3),
                          child: Icon(Icons.image_outlined),
                        )
                      : Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFFE9EDF3),
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
              ),
              title: Text(item.productName),
              subtitle: Text(
                '${item.color} / ${item.size} · ${item.quantity} x Q ${item.unitPrice.toStringAsFixed(2)}',
              ),
              trailing: Text('Q ${item.subtotal.toStringAsFixed(2)}'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                const Text('Estado:'),
                const SizedBox(width: 8),
                Chip(label: Text(order.status == 'completed' ? 'Completada' : order.status)),
                const Spacer(),
                Text('Pago: ${order.paymentMethod}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
