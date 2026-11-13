import 'dart:async';
import 'dart:io';

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

Widget _app(ProductService service, [CartController? cart]) => CartScope(
  controller: cart ?? CartController(),
  child: MaterialApp(home: ProductListScreen(service: service)),
);

void main() {
  testWidgets('shows a spinner, then the product feed', (tester) async {
    final completer = Completer<http.Response>();
    final service = ProductService(client: MockClient((_) => completer.future));

    await tester.pumpWidget(_app(service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(http.Response(_body, 200));
    await tester.pumpAndSettle();

    expect(find.text('Test Jacket'), findsOneWidget);
    expect(find.text('\$55.50'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('offline shows error, Retry Connection recovers', (tester) async {
    var online = false;
    final service = ProductService(
      client: MockClient((_) async {
        if (!online) throw const SocketException('airplane mode');
        return http.Response(_body, 200);
      }),
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.text('Retry Connection'), findsOneWidget);
    expect(find.textContaining('No internet connection'), findsOneWidget);

    online = true;
    await tester.tap(find.text('Retry Connection'));
    await tester.pumpAndSettle();

    expect(find.text('Retry Connection'), findsNothing);
    expect(find.text('Test Jacket'), findsOneWidget);
  });

  testWidgets('tapping a product opens detail with carousel and share', (
    tester,
  ) async {
    final service = ProductService(
      client: MockClient((_) async => http.Response(_body, 200)),
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Jacket'));
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
    expect(find.text("MEN'S CLOTHING"), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    expect(find.text('narxoz://store/product/7'), findsOneWidget);
    expect(find.text('Copy Deep Link'), findsOneWidget);
  });

  testWidgets('empty response shows an empty state', (tester) async {
    final service = ProductService(
      client: MockClient((_) async => http.Response('[]', 200)),
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.textContaining('No products yet'), findsOneWidget);
  });
}
