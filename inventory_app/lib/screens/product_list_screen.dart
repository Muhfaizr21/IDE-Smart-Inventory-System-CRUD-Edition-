import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../utils/secure_storage.dart';
import 'product_form_screen.dart';
import 'login_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService api = ApiService();
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    setState(() => loading = true);
    try {
      final res = await api.fetchProducts();
      final data = res.data;
      final list = (data['data'] as List).map((e) => Product.fromJson(e)).toList();
      setState(() => products = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fetch error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  void remove(int id) async {
    try {
      await api.deleteProduct(id);
      fetch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void logout() async {
    await api.logout();
    await deleteToken();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async { fetch(); },
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (_, i) {
            final p = products[i];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('Stock: ${p.stock} • Rp ${p.price.toStringAsFixed(0)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: p))).then((_) => fetch())),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => remove(p.id)),
              ]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())).then((_) => fetch()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
