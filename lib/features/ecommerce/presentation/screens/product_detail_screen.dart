import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_network_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>{
  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();

    selectedSize = widget.product.sizes.isNotEmpty
        ? widget.product.sizes.first
        : null;

    selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProductImageHeader(product: product),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductTitle(product: product),
                    const SizedBox(height: 18),

                    Text(
                      product.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      children: product.sizes.map((size) {
                        final isSelected = selectedSize == size;

                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Color',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: product.colors.map((colorName) {
                        final isSelected = selectedColor == colorName;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = colorName;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _getColor(colorName),
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (selectedSize == null || selectedColor == null) return;

                          ref.read(cartProvider.notifier).addProduct(
                                product: product,
                                size: selectedSize!,
                                color: selectedColor!,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} agregado al carrito'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to bag'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'blue':
        return Colors.blue;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown;
      case 'gold':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }
}

class _ProductImageHeader extends StatelessWidget {
  final Product product;

  const _ProductImageHeader({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      width: double.infinity,
      color: const Color(0xffeaf2ff),
      child: Stack(
        children: [
          Center(
            child: ProductNetworkImage(
              imageUrl: product.imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTitle extends StatelessWidget {
  final Product product;

  const _ProductTitle({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Q ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }
}