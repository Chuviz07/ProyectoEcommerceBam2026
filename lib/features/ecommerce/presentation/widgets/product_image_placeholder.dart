import 'package:flutter/material.dart';

class ProductImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ProductImagePlaceholder({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,

      // Decoración visual del contenedor
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      // Icono de la imagen
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9DCCFF),
        size: 32,
      ),
    );
  }
}