import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_provider.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({Key? key}) : super(key: key);

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  final Color pastelBg = const Color(0xFFF7F3E9);
  final Color pastelCard = const Color(0xFFFFFDF9);
  final Color pastelPrimary = const Color(0xFFB4C5E4);
  final Color pastelAccent = const Color(0xFFFFCBCB);
  final Color pastelText = const Color(0xFF4A4E69);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: pastelBg,
      appBar: AppBar(
        backgroundColor: pastelPrimary,
        elevation: 0,
        title: Text(
          'GiaMart Catalog',
          style: TextStyle(color: pastelText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[200], // Sesuaikan warna pastel
        child: const Icon(Icons.add),
        onPressed: () {
          // Mengarahkan ke halaman form tambah produk menggunakan GoRouter
          context.push('/add');
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk (contoh: phone, watch)...',
                    hintStyle: TextStyle(color: pastelText.withAlpha(128)),
                    prefixIcon: Icon(Icons.search, color: pastelText),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: pastelText),
                      onPressed: () {
                        _searchController.clear();
                        productProvider.fetchProducts();
                      },
                    ),
                    filled: true,
                    fillColor: pastelCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    productProvider.searchProducts(value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productProvider.categoryList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        bool isSelected =
                            productProvider.selectedCategory.isEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: isSelected,
                            selectedColor: pastelAccent,
                            backgroundColor: pastelCard,
                            labelStyle: TextStyle(
                              color: pastelText,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              productProvider.fetchProducts();
                            },
                          ),
                        );
                      }

                      String category = productProvider.categoryList[index - 1];
                      bool isSelected =
                          productProvider.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: pastelAccent,
                          backgroundColor: pastelCard,
                          labelStyle: TextStyle(
                            color: pastelText,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            productProvider.filterByCategory(category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productProvider.loading
                ? Center(child: CircularProgressIndicator(color: pastelText))
                : productProvider.products.isEmpty
                ? Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(color: pastelText, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return InkWell(
                        onTap: () {
                          context.push('/detail/${product.id}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: pastelCard,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
                                    color: pastelBg,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      imageUrl: product.thumbnail ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: pastelPrimary,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title ?? 'No Title',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: pastelText,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.category ?? '',
                                      style: TextStyle(
                                        color: pastelText.withAlpha(150),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${(product.price ?? 0.0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: pastelText,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
