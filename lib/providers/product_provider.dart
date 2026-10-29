import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  List<Product> _products = [];
  List<String> _categoryList = [];
  bool _loading = false;
  String? _error;
  int _total = 0;
  String _selectedCategory = '';

  // Perubahan yang disimpan di aplikasi (server DummyJSON tidak menyimpan)
  final Map<int, Product> _edited = {};
  final Set<int> _deleted = {};
  final List<Product> _added = [];
  int _nextLocalId = 1000;

  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  String get selectedCategory => _selectedCategory;

  bool _isLocal(int id) => _added.any((p) => p.id == id);

  // Dipakai layar detail: ambil versi lokal kalau produk sudah diubah/ditambah
  Product? localProduct(int id) {
    if (_edited.containsKey(id)) return _edited[id];
    for (final p in _added) {
      if (p.id == id) return p;
    }
    return null;
  }

  // Menjalankan satu permintaan ke server, lalu menerapkan perubahan lokal
  Future<void> _load(
    Future<ProductsResponse> Function() request, {
    bool withAdded = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await request();
      var list = (res.products ?? [])
          .where((p) => !_deleted.contains(p.id))
          .map((p) => _edited[p.id] ?? p)
          .toList();
      if (withAdded) list = [..._added, ...list];
      _products = list;
      _total = res.total ?? list.length;
    } catch (e) {
      _error = 'Gagal memuat data. Periksa koneksi internet.';
    }
    _loading = false;
    notifyListeners();
  }

  // GET /products
  Future<void> fetchProducts({int limit = 30, int skip = 0}) {
    _selectedCategory = '';
    return _load(
      () => _api.getAllProducts(limit: limit, skip: skip),
      withAdded: skip == 0,
    );
  }

  // GET /products/category-list
  Future<void> fetchCategories() async {
    try {
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (e) {
      // Kalau gagal, daftar kategori dibiarkan kosong
    }
  }

  // GET /products/search?q=
  Future<void> searchProducts(String query) {
    if (query.trim().isEmpty) return fetchProducts();
    return _load(() => _api.searchProducts(query));
  }

  // GET /products/category/{nama}
  Future<void> filterByCategory(String category) {
    _selectedCategory = category;
    return _load(() => _api.getProductsByCategory(category));
  }

  // GET /products?sortBy=...&order=...
  Future<void> sortProducts(String sortBy, String order) {
    return _load(() => _api.sortProducts(sortBy, order));
  }

  // POST /products/add (mock). Hasilnya disimpan di aplikasi.
  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      final result = await _api.addProduct(data);
      // Server selalu membalas id yang sama (195), jadi beri id lokal sendiri
      result.id = _nextLocalId++;
      result.title = data['title'] ?? result.title;
      result.price = (data['price'] as num?)?.toDouble() ?? result.price;
      _added.insert(0, result);
      _products.insert(0, result);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // PUT /products/{id} (mock). Hasilnya disimpan di aplikasi.
  Future<bool> updateProduct(
    Product original,
    Map<String, dynamic> data,
  ) async {
    final id = original.id;
    if (id == null) return false;
    try {
      final local = _isLocal(id);
      // Produk buatan lokal tidak ada di server, jadi tidak dikirim
      if (!local) await _api.updateProduct(id, data);
      original.title = data['title'] ?? original.title;
      original.price = (data['price'] as num?)?.toDouble() ?? original.price;
      if (!local) _edited[id] = original;
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) _products[idx] = original;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // DELETE /products/{id} (mock). Produk dihapus dari daftar di aplikasi.
  Future<bool> deleteProduct(int id) async {
    try {
      if (_isLocal(id)) {
        _added.removeWhere((p) => p.id == id);
      } else {
        await _api.deleteProduct(id);
        _deleted.add(id);
        _edited.remove(id);
      }
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
