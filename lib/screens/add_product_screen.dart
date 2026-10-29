import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  final Color pastelBg = const Color(0xFFF7F3E9);
  final Color pastelCard = const Color(0xFFFFFDF9);
  final Color pastelPrimary = const Color(0xFFB4C5E4);
  final Color pastelText = const Color(0xFF4A4E69);

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelBg,
      appBar: AppBar(
        backgroundColor: pastelPrimary,
        title: Text('Tambah Produk', style: TextStyle(color: pastelText)),
        iconTheme: IconThemeData(color: pastelText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk (cth: BMW Pencil)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga (cth: 9.99)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: pastelPrimary),
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          final ok = await context
                              .read<ProductProvider>()
                              .addProduct({
                            'title': _titleController.text,
                            'price':
                                double.tryParse(_priceController.text) ?? 0.0,
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Produk berhasil ditambahkan!'
                                      : 'Gagal menambah produk',
                                ),
                              ),
                            );
                            if (ok) context.pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan',
                        style: TextStyle(
                          color: pastelText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}