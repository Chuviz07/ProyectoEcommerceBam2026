import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class InterestOptionTile extends StatelessWidget {

  final String title;
  final bool selected;

  // Función que se ejecuta al presionar.
  final VoidCallback onTap;

  // Constructor del widget que recibe valores obligatorios.
  const InterestOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    // Permite detectar toques sobre el widget.
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,

      child: Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightBlue
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.lightBlue
                : AppColors.border,
          ),
        ),

        // Organiza elementos horizontalmente.
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Solo muestra el icono si está seleccionado.
            if (selected)
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}