import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/product_provider.dart';
import 'screens/list_product_screen.dart';
import 'screens/detail_product_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'models/product_model.dart';

void main() {
  runApp(const MyApp());
}

// Konfigurasi GoRouter untuk navigasi antar halaman
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const ListProductScreen()),
    GoRoute(
      path: '/detail/:id',
      builder: (c, s) => DetailProductScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (c, s) => EditProductScreen(product: s.extra as Product),
    ),
    GoRoute(path: '/add', builder: (c, s) => const AddProductScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
      child: MaterialApp.router(
        title: 'GiaMart Catalog',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
