import 'package:cloud_product_explorer/screens/product_list_screen.dart';
import 'package:cloud_product_explorer/services/product_service.dart';
import 'package:cloud_product_explorer/state/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _body = '''
[{"id": 7, "title": "Test Jacket", "price": 55.5, "description": "Warm",
  "category": "men's clothing", "image": "",
  "rating": {"rate": 4.5, "count": 10}}]
''';

Future<CartController> _openDetail(WidgetTester tester) async {
  final cart = CartController();
  final service = ProductService(
    client: MockClient((_) async => http.Response(_body, 200)),
  );
  await tester.pumpWidget(
    CartScope(
      controller: cart,
      child: MaterialApp(home: ProductListScreen(service: service)),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Test Jacket'));
  await tester.pumpAndSettle();
  return cart;
}

Finder _badge(String count) =>
    find.descendant(of: find.byType(Badge), matching: find.text(count));

void main() {
  testWidgets('Add to Cart updates the badge and the cart screen', (
    tester,
  ) async {
    final cart = await _openDetail(tester);

    expect(find.byType(Badge), findsOneWidget);
    expect(_badge('1'), findsNothing);

    await tester.tap(find.text('Add to Cart'));
    await tester.pump();
    await tester.tap(find.text('Add to Cart'));
    await tester.pump();

    expect(cart.totalCount, 2);
    expect(_badge('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('My Cart (2)'), findsOneWidget);
    expect(find.text('Test Jacket'), findsOneWidget);
    expect(find.text('\$111.00'), findsNWidgets(2)); // line subtotal + total
  });

  testWidgets('quantity stepper changes quantity and total', (tester) async {
    final cart = await _openDetail(tester);
    await tester.tap(find.text('Add to Cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(cart.quantityOf(7), 2);
    expect(find.text('My Cart (2)'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(cart.quantityOf(7), 1);
  });

  testWidgets('delete button removes the item and Undo restores it', (
    tester,
  ) async {
    final cart = await _openDetail(tester);
    await tester.tap(find.text('Add to Cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Remove from cart'));
    await tester.pumpAndSettle();

    expect(cart.isEmpty, isTrue);
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(cart.quantityOf(7), 1);
    expect(find.text('Test Jacket'), findsOneWidget);
  });

  testWidgets('swipe left deletes the item', (tester) async {
    final cart = await _openDetail(tester);
    await tester.tap(find.text('Add to Cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('cart_7')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    expect(cart.isEmpty, isTrue);
  });

  testWidgets('Clear All asks for confirmation and empties the cart', (
    tester,
  ) async {
    final cart = await _openDetail(tester);
    await tester.tap(find.text('Add to Cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    expect(find.text('Clear cart?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear All'));
    await tester.pumpAndSettle();

    expect(cart.isEmpty, isTrue);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
