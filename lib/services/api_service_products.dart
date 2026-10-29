import 'package:dio/dio.dart';

import '../models/product_model.dart';

class ApiServiceProducts {
  // Base URL DummyJSON sesuai docs https://dummyjson.com/docs/products
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // GET /products (default 30 item)
  Future<ProductsResponse> getAllProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    final res = await _dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponse.fromJson(res.data);
  }

  // GET /products/{id}
  Future<Product> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data);
  }

  // GET /products/search?q=phone
  Future<ProductsResponse> searchProducts(String query) async {
    final res = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    return ProductsResponse.fromJson(res.data);
  }

  // GET /products?limit=10&skip=10&select=title,price
  Future<ProductsResponse> getProductsPaginated({
    int limit = 10,
    int skip = 0,
    String? select,
  }) async {
    final Map<String, dynamic> params = {'limit': limit, 'skip': skip};
    if (select != null) params['select'] = select;
    final res = await _dio.get('/products', queryParameters: params);
    return ProductsResponse.fromJson(res.data);
  }

  // GET /products?sortBy=title&order=asc
  Future<ProductsResponse> sortProducts(String sortBy, String order) async {
    final res = await _dio.get(
      '/products',
      queryParameters: {'sortBy': sortBy, 'order': order},
    );
    return ProductsResponse.fromJson(res.data);
  }

  // GET /products/categories
  Future<List<Category>> getCategories() async {
    final res = await _dio.get('/products/categories');
    return (res.data as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /products/category-list
  Future<List<String>> getCategoryList() async {
    final res = await _dio.get('/products/category-list');
    return (res.data as List).map((e) => e.toString()).toList();
  }

  // GET /products/category/smartphones
  Future<ProductsResponse> getProductsByCategory(String category) async {
    final res = await _dio.get('/products/category/$category');
    return ProductsResponse.fromJson(res.data);
  }

  // POST /products/add (mock, tidak tersimpan permanen)
  Future<Product> addProduct(Map<String, dynamic> data) async {
    final res = await _dio.post('/products/add', data: data);
    return Product.fromJson(res.data);
  }

  // PUT /products/{id} (mock)
  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/products/$id', data: data);
    return Product.fromJson(res.data);
  }

  // PATCH /products/{id} (mock)
  Future<Product> patchProduct(int id, Map<String, dynamic> partialData) async {
    final res = await _dio.patch('/products/$id', data: partialData);
    return Product.fromJson(res.data);
  }

  // DELETE /products/{id} (mock)
  Future<Product> deleteProduct(int id) async {
    final res = await _dio.delete('/products/$id');
    return Product.fromJson(res.data);
  }
}
