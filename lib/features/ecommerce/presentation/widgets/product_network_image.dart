import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      debugPrint('La URL de la imagen está vacía');
      return _placeholder();
    }

    debugPrint('Intentando mostrar imagen: $cleanUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,

        // Evita algunos problemas de renderizado en Flutter Web.
        webHtmlElementStrategy:
            kIsWeb
                ? WebHtmlElementStrategy.prefer
                : WebHtmlElementStrategy.never,

        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          final expectedBytes =
              loadingProgress.expectedTotalBytes;

          final progress =
              expectedBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      expectedBytes
                  : null;

          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: progress,
              ),
            ),
          );
        },
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          debugPrint(
            'Error cargando la imagen $cleanUrl: $error',
          );

          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
      ),
    );
  }
}