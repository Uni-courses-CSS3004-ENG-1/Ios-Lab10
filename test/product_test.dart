import 'package:cloud_product_explorer/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a full Fake Store API payload', () {
      final product = Product.fromJson({
        'id': 1,
        'title': 'Backpack',
        'price': 109.95,
        'description': 'Everyday pack',
        'category': "men's clothing",
        'image': 'https://fakestoreapi.com/img/1.jpg',
        'rating': {'rate': 3.9, 'count': 120},
      });

      expect(product.id, 1);
      expect(product.title, 'Backpack');
      expect(product.price, 109.95);
      expect(product.description, 'Everyday pack');
      expect(product.category, "men's clothing");
      expect(product.imageUrl, 'https://fakestoreapi.com/img/1.jpg');
      expect(product.rating, 3.9);
      expect(product.reviewCount, 120);
    });

    test('accepts integer price and rating without a cast error', () {
      final product = Product.fromJson({
        'id': 2,
        'price': 15,
        'rating': {'rate': 4, 'count': 7},
      });

      expect(product.price, isA<double>());
      expect(product.price, 15.0);
      expect(product.rating, isA<double>());
      expect(product.rating, 4.0);
    });

    test('falls back to safe defaults for missing or null fields', () {
      final product = Product.fromJson({
        'id': null,
        'title': null,
        'price': null,
        'rating': null,
      });

      expect(product.id, 0);
      expect(product.title, 'Untitled product');
      expect(product.price, 0.0);
      expect(product.description, '');
      expect(product.category, 'uncategorized');
      expect(product.imageUrl, '');
      expect(product.rating, 0.0);
      expect(product.reviewCount, 0);
    });

    test('builds the deep link and a 3-image gallery', () {
      final product = Product.fromJson({'id': 42, 'image': 'a.jpg'});

      expect(product.deepLink, 'narxoz://store/product/42');
      expect(product.galleryImages, ['a.jpg', 'a.jpg', 'a.jpg']);
    });
  });
}
