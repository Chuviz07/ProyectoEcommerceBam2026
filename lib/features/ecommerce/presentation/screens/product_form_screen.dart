import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/product.dart';
import '../providers/ecommerce_provider.dart';
import '../widgets/product_network_image.dart';

class ProductFormScreen
    extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  bool get isEditing => product != null;

  @override
  ConsumerState<ProductFormScreen> createState() {
    return _ProductFormScreenState();
  }
}

class _ProductFormScreenState
    extends ConsumerState<ProductFormScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController categoryController;
  late final TextEditingController priceController;
  late final TextEditingController descriptionController;
  late final TextEditingController sizesController;
  late final TextEditingController colorsController;
  late final TextEditingController stockController;

  final ImagePicker imagePicker = ImagePicker();

  Uint8List? selectedImageBytes;
  String? selectedImageExtension;
  String? selectedImageContentType;

  bool isRecommended = false;
  bool isSummer = false;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    nameController = TextEditingController(
      text: product?.name ?? '',
    );

    categoryController = TextEditingController(
      text: product?.category ?? '',
    );

    priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    sizesController = TextEditingController(
      text: product?.sizes.join(', ') ?? '',
    );

    colorsController = TextEditingController(
      text: product?.colors.join(', ') ?? '',
    );

    stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );

    isRecommended =
        product?.isRecommended ?? false;

    isSummer = product?.isSummer ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    sizesController.dispose();
    colorsController.dispose();
    stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState =
        ref.watch(productFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Editar producto'
              : 'Nuevo producto',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImagePreview(),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed:
                  formState.isLoading ? null : _pickImage,
              icon: const Icon(
                Icons.upload_file_outlined,
              ),
              label: Text(
                selectedImageBytes == null
                    ? 'Seleccionar imagen'
                    : 'Cambiar imagen',
              ),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixText: 'Q ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(
                  value?.trim() ?? '',
                );

                if (price == null || price <= 0) {
                  return 'Ingresa un precio válido';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Existencias',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final stock = int.tryParse(
                  value?.trim() ?? '',
                );

                if (stock == null || stock < 0) {
                  return 'Ingresa una cantidad válida';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: sizesController,
              decoration: const InputDecoration(
                labelText: 'Tallas',
                hintText: 'S, M, L, XL',
                helperText:
                    'Separa cada talla con una coma',
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: colorsController,
              decoration: const InputDecoration(
                labelText: 'Colores',
                hintText: 'Black, Blue, White',
                helperText:
                    'Separa cada color con una coma',
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mostrar en Perfect for you',
              ),
              value: isRecommended,
              onChanged: formState.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        isRecommended = value;
                      });
                    },
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mostrar en For this summer',
              ),
              value: isSummer,
              onChanged: formState.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        isSummer = value;
                      });
                    },
            ),

            if (formState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                formState.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed:
                    formState.isLoading ? null : _save,
                child: formState.isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Guardar cambios'
                            : 'Crear producto',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          selectedImageBytes!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    }

    final existingUrl =
        widget.product?.imageUrl ?? '';

    if (existingUrl.isNotEmpty) {
      return ProductNetworkImage(
        imageUrl: existingUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.contain,
        borderRadius: 12,
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final selectedFile =
        await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (selectedFile == null) {
      return;
    }

    final bytes = await selectedFile.readAsBytes();

    final extension = _getFileExtension(
      selectedFile.name,
    );

    final contentType = _getContentType(
      extension,
    );

    setState(() {
      selectedImageBytes = bytes;
      selectedImageExtension = extension;
      selectedImageContentType = contentType;
    });
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!widget.isEditing &&
        selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona una imagen para el producto',
          ),
        ),
      );

      return;
    }

    final product = Product(
      id: widget.product?.id ?? '',
      name: nameController.text.trim(),
      category: categoryController.text.trim(),
      price: double.parse(
        priceController.text.trim(),
      ),
      imageUrl:
          widget.product?.imageUrl ?? '',
      imageStoragePath:
          widget.product?.imageStoragePath ?? '',
      description:
          descriptionController.text.trim(),
      sizes: _splitValues(
        sizesController.text,
      ),
      colors: _splitValues(
        colorsController.text,
      ),
      stock: int.parse(
        stockController.text.trim(),
      ),
      isRecommended: isRecommended,
      isSummer: isSummer,
      createdAt: widget.product?.createdAt,
      updatedAt: widget.product?.updatedAt,
    );

    try {
      final notifier = ref.read(
        productFormNotifierProvider.notifier,
      );

      if (widget.isEditing) {
        await notifier.updateProduct(
          product: product,
          newImageBytes: selectedImageBytes,
          imageExtension:
              selectedImageExtension,
          imageContentType:
              selectedImageContentType,
        );
      } else {
        await notifier.createProduct(
          product: product,
          imageBytes: selectedImageBytes,
          imageExtension:
              selectedImageExtension,
          imageContentType:
              selectedImageContentType,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Producto actualizado correctamente'
                : 'Producto creado correctamente',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: $error',
          ),
        ),
      );
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  List<String> _splitValues(String value) {
    return value
        .split(',')
        .map((element) => element.trim())
        .where((element) => element.isNotEmpty)
        .toSet()
        .toList();
  }

  String _getFileExtension(String filename) {
    final parts = filename.split('.');

    if (parts.length < 2) {
      return 'jpg';
    }

    return parts.last.toLowerCase();
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}