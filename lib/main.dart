import 'package:flutter/material.dart';

import 'screens/product_list_screen.dart';
import 'state/cart_controller.dart';

void main() {
  runApp(const CloudProductExplorerApp());
}

class CloudProductExplorerApp extends StatefulWidget {
  const CloudProductExplorerApp({super.key});

  @override
  State<CloudProductExplorerApp> createState() =>
      _CloudProductExplorerAppState();
}

class _CloudProductExplorerAppState extends State<CloudProductExplorerApp> {
  final CartController _cart = CartController();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CartScope sits above MaterialApp so every pushed route shares the cart.
    return CartScope(
      controller: _cart,
      child: MaterialApp(
        title: 'Cloud Product Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
