import 'dart:async';
import 'dart:io';

import 'package:cloud_product_explorer/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _sampleBody = '''
[
  {"id": 1, "title": "Backpack", "price": 109.95, "description": "d",
   "category": "men's clothing", "image": "a.jpg",
   "rating": {"rate": 3.9, "count": 120}},
  {"id": 2, "title": "Shirt", "price": 22, "description": "d",
   "category": "men's clothing", "image": "b.jpg",
   "rating": {"rate": 4, "count": 259}}
]
''';

ProductService _serviceReturning(http.Response response) =>
    ProductService(client: MockClient((_) async => response));

void main() {
  group('ProductService.fetchProducts', () {
    test('parses a 200 response into products', () async {
      final products = await _serviceReturning(http.Response(_sampleBody, 200))
          .fetchProducts();

      expect(products, hasLength(2));
      expect(products.first.title, 'Backpack');
      expect(products.last.price, 22.0);
    });

    test('requests GET /products', () async {
      late Uri requested;
      final service = ProductService(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response('[]', 200);
        }),
      );

      await service.fetchProducts();
      expect(requested.toString(), 'https://fakestoreapi.com/products');
    });

    test('maps 404 to a readable error', () {
      expect(
        _serviceReturning(http.Response('', 404)).fetchProducts(),
        throwsA(
          isA<ProductFetchException>().having(
            (e) => e.message,
            'message',
            contains('404'),
          ),
        ),
      );
    });

    test('maps 500 to a server error', () {
      expect(
        _serviceReturning(http.Response('', 500)).fetchProducts(),
        throwsA(
          isA<ProductFetchException>().having(
            (e) => e.message,
            'message',
            contains('Server error (500)'),
          ),
        ),
      );
    });

    test('maps malformed JSON to an invalid-data error', () {
      expect(
        _serviceReturning(http.Response('{oops', 200)).fetchProducts(),
        throwsA(
          isA<ProductFetchException>().having(
            (e) => e.message,
            'message',
            contains('invalid data'),
          ),
        ),
      );
    });

    test('maps SocketException (airplane mode) to an offline error', () {
      final service = ProductService(
        client: MockClient((_) => throw const SocketException('offline')),
      );

      expect(
        service.fetchProducts(),
        throwsA(
          isA<ProductFetchException>().having(
            (e) => e.message,
            'message',
            contains('No internet connection'),
          ),
        ),
      );
    });

    test('maps a timeout to a timeout error', () {
      final service = ProductService(
        client: MockClient((_) => throw TimeoutException('slow')),
      );

      expect(
        service.fetchProducts(),
        throwsA(
          isA<ProductFetchException>().having(
            (e) => e.message,
            'message',
            contains('10 seconds'),
          ),
        ),
      );
    });
  });
}
