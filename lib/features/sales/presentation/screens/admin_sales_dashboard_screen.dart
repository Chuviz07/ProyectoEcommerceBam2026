import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ecommerce/domain/entities/product.dart';
import '../../../ecommerce/presentation/providers/ecommerce_provider.dart';
import '../../domain/entities/sale_order.dart';
import '../providers/sales_provider.dart';
import '../widgets/order_card.dart';

class AdminSalesDashboardScreen extends ConsumerWidget {
  const AdminSalesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).valueOrNull;
    if (user == null || !user.isAdmin) {
      return const Scaffold(body: Center(child: Text('Acceso denegado')));
    }

    final productsAsync = ref.watch(productsProvider);
    final ordersAsync = ref.watch(allOrdersProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Control de ventas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Existencia'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Ventas'),
              Tab(icon: Icon(Icons.people_outline), text: 'Clientes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (products) => _InventoryTab(products: products),
            ),
            ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (orders) => _SalesTab(orders: orders),
            ),
            ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (orders) => _CustomersTab(orders: orders),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  final List<Product> products;

  const _InventoryTab({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const Center(child: Text('No hay productos'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        final lowStock = product.stock <= 5;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: lowStock ? Colors.red.shade50 : Colors.green.shade50,
              child: Icon(
                lowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                color: lowStock ? Colors.red : Colors.green,
              ),
            ),
            title: Text(product.name),
            subtitle: Text('${product.category} · Q ${product.price.toStringAsFixed(2)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${product.stock}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(lowStock ? 'Stock bajo' : 'unidades', style: TextStyle(color: lowStock ? Colors.red : Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SalesTab extends StatelessWidget {
  final List<SaleOrder> orders;

  const _SalesTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const Center(child: Text('Todavía no hay ventas'));

    final revenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final itemCount = orders.fold<int>(0, (sum, order) => sum + order.totalItems);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(label: 'Ingresos', value: 'Q ${revenue.toStringAsFixed(2)}')),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(label: 'Productos vendidos', value: '$itemCount')),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(label: 'Ventas realizadas', value: '${orders.length}'),
        const SizedBox(height: 20),
        const Text('Historial por fecha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...orders.map((order) => OrderCard(order: order)),
      ],
    );
  }
}

class _CustomersTab extends StatelessWidget {
  final List<SaleOrder> orders;

  const _CustomersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SaleOrder>>{};
    for (final order in orders) {
      grouped.putIfAbsent(order.customerId, () => []).add(order);
    }

    if (grouped.isEmpty) return const Center(child: Text('Todavía no hay clientes con compras'));

    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.fold<double>(0, (sum, order) => sum + order.total);
        final bTotal = b.value.fold<double>(0, (sum, order) => sum + order.total);
        return bTotal.compareTo(aTotal);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (_, index) {
        final customerOrders = entries[index].value;
        final first = customerOrders.first;
        final spent = customerOrders.fold<double>(0, (sum, order) => sum + order.total);
        final purchasedItems = customerOrders.fold<int>(0, (sum, order) => sum + order.totalItems);

        return Card(
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(first.customerName.isEmpty ? 'Cliente' : first.customerName),
            subtitle: Text('${first.customerEmail}\n${customerOrders.length} compra(s) · $purchasedItems producto(s)'),
            trailing: Text('Q ${spent.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            children: customerOrders.map((order) => OrderCard(order: order)).toList(),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
