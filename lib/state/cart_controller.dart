import 'package:flutter/widgets.dart';

import '../models/product.dart';

/// One line in the cart: a product and how many of it.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

/// App-wide cart state. Widgets read it through [CartScope] and rebuild
/// automatically when [notifyListeners] fires.
class CartController extends ChangeNotifier {
  // Keyed by product id; LinkedHashMap keeps insertion order for the UI.
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  /// Total number of units (what the AppBar badge shows).
  int get totalCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice => _items.values.fold(0, (sum, i) => sum + i.subtotal);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  /// Adds one unit, or bumps the quantity if already in the cart.
  void add(Product product) {
    final current = quantityOf(product.id);
    _items[product.id] = CartItem(product: product, quantity: current + 1);
    notifyListeners();
  }

  /// Removes one unit; drops the line when it reaches zero.
  void decrement(int productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = CartItem(
        product: item.product,
        quantity: item.quantity - 1,
      );
    }
    notifyListeners();
  }

  /// Deletes the whole line and returns it (for Undo).
  CartItem? remove(int productId) {
    final removed = _items.remove(productId);
    if (removed != null) notifyListeners();
    return removed;
  }

  /// Puts a removed line back (Undo after delete).
  void restore(CartItem item) {
    _items[item.product.id] = item;
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

/// Makes the [CartController] available to the whole widget tree.
/// `CartScope.of(context)` also subscribes the caller to cart changes.
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found above this widget.');
    return scope!.notifier!;
  }

  /// Reads the cart without subscribing. Use in callbacks (onPressed).
  static CartController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found above this widget.');
    return scope!.notifier!;
  }
}
