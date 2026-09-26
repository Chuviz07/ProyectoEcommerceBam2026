import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ecommerce_provider.dart';
import '../widgets/product_image_placeholder.dart';
import '../widgets/product_section.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'product_admin_screen.dart';
import '../../../sales/presentation/screens/admin_sales_dashboard_screen.dart';
import '../../../sales/presentation/screens/customer_purchase_history_screen.dart';

import '../../../../core/notifications/notification_service.dart';

class EcommerceHomeScreen extends ConsumerWidget {
  const EcommerceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carouselIndex = ref.watch(homeCarouselIndexProvider);
    final bottomIndex = ref.watch(selectedBottomNavIndexProvider);
    final homeProductsAsync = ref.watch(homeProductsProvider);

    final authUserAsync = ref.watch(authUserProvider);
    final currentUser = authUserAsync.valueOrNull;
    final isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HomeHeader(
                isAdmin: isAdmin,
              ),
              const SizedBox(height: 12),

              // Banner principal
              SizedBox(
                height: 150,
                child: PageView.builder(
                  itemCount: 5,
                  onPageChanged: (index) {
                    ref.read(homeCarouselIndexProvider.notifier).state = index;
                  },
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ProductImagePlaceholder(
                        height: 150,
                        width: double.infinity,
                        borderRadius: 0,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Puntitos del carrusel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isActive = carouselIndex == index;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: isActive ? 8 : 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0A7CFF)
                          : const Color(0xFFD6E5F7),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              homeProductsAsync.when(
                data: (homeProducts) {
                  return Column(
                    children: [
                      ProductSection(
                        title: 'Perfect for you',
                        products: homeProducts.recommended,
                      ),

                      const SizedBox(height: 18),

                      ProductSection(
                        title: 'For this summer',
                        products: homeProducts.summer,
                      ),
                    ],
                  );
                },
                loading: () {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No se pudieron cargar los productos.\n$error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A7CFF),
        unselectedItemColor: const Color(0xFFC7CDD6),
        onTap: (index) {
          ref.read(selectedBottomNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  final bool isAdmin;

  const _HomeHeader({
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 26,
          ),

          const Spacer(),

          // Botón visible únicamente para administradores
          if (isAdmin) ...[
            IconButton(
              tooltip: 'Existencias y ventas',
              icon: const Icon(
                Icons.analytics_outlined,
                size: 27,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSalesDashboardScreen(),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Administrar productos',
              icon: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 27,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductAdminScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ] else ...[
            IconButton(
              tooltip: 'Mis compras',
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerPurchaseHistoryScreen(),
                  ),
                );
              },
            ),
          ],

          // Habilitar notificaciones push
          IconButton(
            tooltip: 'Activar notificaciones',
            icon: const Icon(
              Icons.notifications_outlined,
              size: 26,
            ),
            onPressed: () async {
              final token = await NotificationService.instance
                  .requestPermissionAndGetToken();

              if (!context.mounted) return;

              if (token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se concedió permiso para recibir notificaciones.',
                    ),
                  ),
                );
                return;
              }

              await NotificationService.instance.showLocalNotification(
                title: '¡Notificaciones activadas!',
                body: 'Ya puedes recibir promociones y novedades.',
                payload: 'notifications_enabled',
              );

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Las notificaciones fueron activadas correctamente.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          const SizedBox(width: 4),

          const Icon(
            Icons.favorite_border,
            size: 26,
          ),

          const SizedBox(width: 18),

          // Cerrar sesión
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(
              Icons.logout,
              size: 26,
            ),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),

          const SizedBox(width: 10),

          // Carrito
          IconButton(
            tooltip: 'Carrito',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 26,
                ),

                if (cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -9,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A7CFF),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartCount > 99 ? '99+' : cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}