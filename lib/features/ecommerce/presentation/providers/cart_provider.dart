import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct({
    required Product product,
    required String size,
    required String color,
  }) {
    final index = state.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (index >= 0) {
      final updatedItems = [...state];
      final currentItem = updatedItems[index];

      updatedItems[index] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );

      state = updatedItems;
    } else {
      state = [
        ...state,
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: 1,
        ),
      ];
    }
  }

  void clear() {
    state = [];
  }

  void increment(CartItem item) {
    state = state.map((cartItem) {
      if (cartItem.product.id == item.product.id &&
          cartItem.size == item.size &&
          cartItem.color == item.color) {
        return cartItem.copyWith(
          quantity: cartItem.quantity + 1,
        );
      }

      return cartItem;
    }).toList();
  }

  void decrement(CartItem item) {
    state = state
        .map((cartItem) {
          if (cartItem.product.id == item.product.id &&
              cartItem.size == item.size &&
              cartItem.color == item.color) {
            return cartItem.copyWith(
              quantity: cartItem.quantity - 1,
            );
          }

          return cartItem;
        })
        .where((cartItem) => cartItem.quantity > 0)
        .toList();
  }

  double get total {
    return state.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  int get totalItems {
    return state.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);

  return items.fold(
    0,
    (sum, item) => sum + item.total,
  );
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);

  return items.fold(
    0,
    (sum, item) => sum + item.quantity,
  );
});