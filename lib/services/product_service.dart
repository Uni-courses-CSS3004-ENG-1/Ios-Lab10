import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Error with a message that is safe to show directly in the UI.
class ProductFetchException implements Exception {
  final String message;
  const ProductFetchException(this.message);

  @override
  String toString() => message;
}

/// Talks to the Fake Store REST API.
class ProductService {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const Duration timeout = Duration(seconds: 10);

  final http.Client _client;

  /// [client] can be injected for tests; defaults to a real HTTP client.
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  /// Downloads the product feed.
  ///
  /// Throws [ProductFetchException] with a human-readable message for every
  /// failure mode: no internet, timeout, HTTP 404/500, or malformed JSON.
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/products'))
          .timeout(timeout);

      switch (response.statusCode) {
        case 200:
          final decoded = jsonDecode(response.body);
          if (decoded is! List) {
            throw const FormatException('Expected a JSON array');
          }
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList();
        case 404:
          throw const ProductFetchException(
            'Products not found (404). The store endpoint may have moved.',
          );
        case >= 500:
          throw ProductFetchException(
            'Server error (${response.statusCode}). Please try again later.',
          );
        default:
          throw ProductFetchException(
            'Unexpected response (${response.statusCode}).',
          );
      }
    } on ProductFetchException {
      rethrow;
    } on TimeoutException {
      throw const ProductFetchException(
        'The server took longer than 10 seconds to respond.',
      );
    } on SocketException {
      throw const ProductFetchException(
        'No internet connection. Check Wi-Fi or turn off Airplane mode.',
      );
    } on http.ClientException {
      throw const ProductFetchException(
        'Could not reach the store. Check your connection.',
      );
    } on FormatException {
      throw const ProductFetchException(
        'Received invalid data from the server.',
      );
    }
  }

  void dispose() => _client.close();
}
