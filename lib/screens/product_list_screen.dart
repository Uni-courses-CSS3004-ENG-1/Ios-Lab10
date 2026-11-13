import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

import '../widgets/cart_icon_button.dart';
import '../widgets/error_view.dart';
import '../widgets/product_tile.dart';
import 'product_detail_screen.dart';

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
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    // _state already starts as loading, so fetch directly.
    _fetch();
  }

  @override
  void dispose() {
    // Only close the client we created ourselves.
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  /// Retry Connection: back to the spinner and fetch again.
  /// Ignored while a request is already in flight.
  Future<void> _loadProducts() async {
    if (_isFetching) return;
    setState(() => _state = _LoadState.loading);
    await _fetch();
  }

  /// Pull-to-refresh: keep the current list on screen while reloading.
  /// If the refresh fails but we already have data, show a SnackBar
  /// instead of throwing the user onto the error screen.
  Future<void> _refresh() async {
    try {
      final products = await _service.fetchProducts();
      if (!mounted) return;
      setState(() => _products = products);
    } on ProductFetchException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _fetch() async {
    _isFetching = true;
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
    } finally {
      _isFetching = false;
    }
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Product Explorer'),
        actions: const [CartIconButton()],
      ),
      body: switch (_state) {
        _LoadState.loading => const Center(child: CircularProgressIndicator()),
        _LoadState.error => ErrorView(
          message: _errorMessage,
          onRetry: _loadProducts,
        ),
        _LoadState.success when _products.isEmpty => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 160),
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Center(child: Text('No products yet. Pull down to refresh.')),
            ],
          ),
        ),
        _LoadState.success => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            // Always scrollable so pull-to-refresh works on short lists.
            physics: const AlwaysScrollableScrollPhysics(),
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
        ),
      },
    );
  }
}
