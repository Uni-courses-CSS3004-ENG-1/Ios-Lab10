import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/cart_controller.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/photo_carousel.dart';
import 'cart_screen.dart';
import '../widgets/rating_stars.dart';
import '../widgets/share_link_sheet.dart';

/// Master-detail target: large image, category badge, rating, full
/// description, and a sticky "Add to Cart" bar.
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  void _addToCart(BuildContext context) {
    final cart = CartScope.read(context)..add(product);
    // Captured now: the SnackBar may outlive this screen.
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Added to cart (${cart.quantityOf(product.id)} in cart)',
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => navigator.push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => showShareLinkSheet(context, product),
          ),
          const CartIconButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PhotoCarousel(
            imageUrls: product.galleryImages,
            heroTag: 'product_image_${product.id}',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryBadge(category: product.category),
                const SizedBox(height: 12),
                Text(product.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                RatingStars(
                  rating: product.rating,
                  reviewCount: product.reviewCount,
                  size: 20,
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(product.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
      // Sticky bottom bar: stays visible while the description scrolls.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () => _addToCart(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
