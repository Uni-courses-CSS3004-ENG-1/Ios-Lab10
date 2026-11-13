import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/error_view.dart';
import '../widgets/product_tile.dart';

enum _LoadState { loading, success, error }

/// Product feed with the three production UI states:
/// loading spinner, success list, and error-with-retry.
class ProductListScreen extends StatefulWidget {
  final ProductService? service;

  const ProductListScreen({super.key, this.service});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductService _service = widget.service ?? ProductService();

  _LoadState _state = _LoadState.loading;
  List<Product> _products = const [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    // Only close the client we created ourselves.
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _state = _LoadState.loading);
    try {
      final products = await _service.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _state = _LoadState.success;
      });
    } on ProductFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = _LoadState.error;
      });
    }
  }

  void _openDetail(Product product) {
    // Detail screen is wired up in a follow-up commit.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Product Explorer')),
      body: switch (_state) {
        _LoadState.loading => const Center(child: CircularProgressIndicator()),
        _LoadState.error => ErrorView(
          message: _errorMessage,
          onRetry: _loadProducts,
        ),
        _LoadState.success => ListView.separated(
          itemCount: _products.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 112),
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductTile(
              product: product,
              onTap: () => _openDetail(product),
            );
          },
        ),
      },
    );
  }
}
