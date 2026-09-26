import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/ecommerce_provider.dart';
import '../widgets/product_network_image.dart';
import 'product_form_screen.dart';

class ProductAdminScreen extends ConsumerWidget {
  const ProductAdminScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserProvider);
    final productsAsync = ref.watch(productsProvider);
    final formState =
        ref.watch(productFormNotifierProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text(
              'No se pudo verificar el usuario',
            ),
          ),
        );
      },
      data: (user) {
        if (user == null || !user.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Acceso denegado',
              ),
            ),
            body: const Center(
              child: Text(
                'No tienes permiso para administrar productos',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Administrar productos',
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: formState.isLoading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProductFormScreen(),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text(
              'Nuevo producto',
            ),
          ),
          body: productsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) {
              return Center(
                child: Text(
                  'Error al cargar productos:\n$error',
                  textAlign: TextAlign.center,
                ),
              );
            },
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'Todavía no hay productos registrados',
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  final product = products[index];

                  return _ProductAdminTile(
                    product: product,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductAdminTile extends ConsumerWidget {
  final Product product;

  const _ProductAdminTile({
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ProductNetworkImage(
        imageUrl: product.imageUrl,
        width: 60,
        height: 60,
        borderRadius: 8,
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${product.category} · Q ${product.price.toStringAsFixed(2)} · Stock: ${product.stock}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(
                  product: product,
                ),
              ),
            );

            return;
          }

          if (value == 'delete') {
            await _confirmDelete(
              context,
              ref,
            );
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 10),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Eliminar',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar producto',
          ),
          content: Text(
            '¿Deseas eliminar "${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref
          .read(
            productFormNotifierProvider.notifier,
          )
          .deleteProduct(product);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} fue eliminado',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo eliminar: $error',
          ),
        ),
      );
    }
  }
}