import 'package:flutter/material.dart';

import '../screens/cart_screen.dart';
import '../state/cart_controller.dart';

/// AppBar cart icon with a live item-count badge; opens [CartScreen].
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = CartScope.of(context).totalCount;

    return IconButton(
      tooltip: 'Cart',
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
