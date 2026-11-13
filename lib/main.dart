import 'package:flutter/material.dart';

import 'screens/product_list_screen.dart';

void main() {
  runApp(const CloudProductExplorerApp());
}

class CloudProductExplorerApp extends StatelessWidget {
  const CloudProductExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Product Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}
