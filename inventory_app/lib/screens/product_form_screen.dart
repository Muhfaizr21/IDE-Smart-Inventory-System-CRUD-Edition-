import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final ApiService api = ApiService();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _stock = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController();
  String? imagePath;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name.text = widget.product!.name;
      _desc.text = widget.product!.description ?? '';
      _stock.text = widget.product!.stock.toString();
      _price.text = widget.product!.price.toString();
      _category.text = widget.product!.category ?? '';
    }
  }

  Future pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => imagePath = picked.path);
  }

  void submit() async {
    setState(() => loading = true);
    final body = {
      'name': _name.text,
      'description': _desc.text,
      'stock': int.tryParse(_stock.text) ?? 0,
      'price': double.tryParse(_price.text) ?? 0,
      'category': _category.text
    };

    try {
      if (widget.product == null) {
        await api.createProduct(body, imagePath);
      } else {
        await api.updateProduct(widget.product!.id, body, imagePath);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Add Product' : 'Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
          const SizedBox(height: 10),
          Row(children: [
            ElevatedButton(onPressed: pickImage, child: const Text('Pick Image')),
            const SizedBox(width: 10),
            if (imagePath != null) Text('Selected', style: const TextStyle(fontSize: 12)),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: loading ? null : submit, child: loading ? const CircularProgressIndicator() : const Text('Save')),
        ]),
      ),
    );
  }
}
