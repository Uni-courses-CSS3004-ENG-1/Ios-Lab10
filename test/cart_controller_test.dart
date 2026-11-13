import 'package:cloud_product_explorer/models/product.dart';
import 'package:cloud_product_explorer/state/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(int id, double price) => Product.fromJson({
  'id': id,
  'title': 'P$id',
  'price': price,
});

void main() {
  late CartController cart;
  late int notifications;

  setUp(() {
    cart = CartController();
    notifications = 0;
    cart.addListener(() => notifications++);
  });

  test('add increments quantity and totals', () {
    cart.add(_product(1, 10));
    cart.add(_product(1, 10));
    cart.add(_product(2, 2.5));

    expect(cart.items, hasLength(2));
    expect(cart.quantityOf(1), 2);
    expect(cart.totalCount, 3);
    expect(cart.totalPrice, 22.5);
    expect(notifications, 3);
  });

  test('decrement lowers quantity and drops the line at zero', () {
    cart.add(_product(1, 10));
    cart.add(_product(1, 10));

    cart.decrement(1);
    expect(cart.quantityOf(1), 1);

    cart.decrement(1);
    expect(cart.isEmpty, isTrue);
  });

  test('remove deletes the line and restore brings it back', () {
    cart.add(_product(1, 10));
    cart.add(_product(1, 10));

    final removed = cart.remove(1);
    expect(cart.isEmpty, isTrue);
    expect(removed?.quantity, 2);

    cart.restore(removed!);
    expect(cart.quantityOf(1), 2);
  });

  test('clear empties the cart', () {
    cart.add(_product(1, 10));
    cart.add(_product(2, 5));

    cart.clear();
    expect(cart.isEmpty, isTrue);
    expect(cart.totalPrice, 0);
  });
}
