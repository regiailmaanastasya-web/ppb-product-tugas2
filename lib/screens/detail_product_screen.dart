import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/api_service_products.dart';

class DetailProductScreen extends StatefulWidget {
  final String id;

  const DetailProductScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  final ApiServiceProducts _apiService = ApiServiceProducts();
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  final Color pastelBg = const Color(0xFFF7F3E9);
  final Color pastelCard = const Color(0xFFFFFDF9);
  final Color pastelPrimary = const Color(0xFFB4C5E4);
  final Color pastelAccent = const Color(0xFFFFCBCB);
  final Color pastelText = const Color(0xFF4A4E69);

  @override
  void initState() {
    super.initState();
    _fetchDetailProduct();
  }

  Future<void> _fetchDetailProduct() async {
    try {
      int productId = int.parse(widget.id);

      // Kalau produk ini sudah diubah atau ditambah di aplikasi, pakai versi itu
      final local = context.read<ProductProvider>().localProduct(productId);
      if (local != null) {
        setState(() {
          _product = local;
          _isLoading = false;
        });
        return;
      }

      // GET /products/{id}
      Product product = await _apiService.getProduct(productId);
      if (!mounted) return;
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantau hasil edit supaya layar ikut diperbarui
    final local = context.watch<ProductProvider>().localProduct(
      int.tryParse(widget.id) ?? -1,
    );
    if (local != null) _product = local;

    return Scaffold(
      backgroundColor: pastelBg,
      appBar: AppBar(
        backgroundColor: pastelPrimary,
        elevation: 0,
        // Tombol back di kiri atas
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke halaman sebelumnya; kalau tidak ada, ke daftar produk
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Detail Produk',
          style: TextStyle(color: pastelText, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: pastelText),
        actions: [
          // Tombol Edit
          if (_product != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/edit/${_product!.id}', extra: _product);
              },
            ),
          // Tombol Delete
          if (_product != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await context.read<ProductProvider>().deleteProduct(
                  _product!.id!,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Produk berhasil dihapus!'
                          : 'Gagal menghapus produk',
                    ),
                  ),
                );
                if (ok) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: pastelText))
          : _errorMessage != null
          ? Center(
              child: Text(
                'Gagal memuat detail: $_errorMessage',
                style: TextStyle(color: pastelText),
              ),
            )
          : _product == null
          ? Center(
              child: Text(
                'Produk tidak ditemukan',
                style: TextStyle(color: pastelText),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: pastelCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: (_product!.thumbnail ?? '').isEmpty
                          ? const Center(
                              child: Icon(Icons.image_not_supported, size: 48),
                            )
                          : CachedNetworkImage(
                              imageUrl: _product!.thumbnail!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: pastelPrimary,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: pastelCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              backgroundColor: pastelAccent,
                              label: Text(
                                (_product!.category ?? '').toUpperCase(),
                                style: TextStyle(
                                  color: pastelText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              'Stock: ${_product!.stock ?? 0}',
                              style: TextStyle(
                                color: pastelText.withAlpha(180),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _product!.title ?? 'No Title',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: pastelText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Brand: ${(_product!.brand ?? '').isNotEmpty ? _product!.brand : "Generic"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: pastelText.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${(_product!.price ?? 0.0).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: pastelText,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_product!.rating ?? 0.0}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: pastelText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: pastelCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: pastelText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _product!.description ?? 'Tidak ada deskripsi',
                          style: TextStyle(
                            fontSize: 14,
                            color: pastelText.withAlpha(200),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
