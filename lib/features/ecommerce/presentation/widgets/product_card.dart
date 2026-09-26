import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'product_network_image.dart';
// import 'product_image_placeholder.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),

      // Forma de la tarjeta
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen superior del producto
          // const ProductImagePlaceholder(
          //   height: 110,
          //   width: double.infinity,
          //   borderRadius: 14,
          // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ProductNetworkImage(
              imageUrl: product.imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: 14,
            ),
          ),
          const SizedBox(height: 10),

          // Nombre del producto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Precio del producto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Q ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}