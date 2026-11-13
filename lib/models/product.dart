/// Domain model for a single product returned by
/// `https://fakestoreapi.com/products`.
///
/// Sample payload:
/// ```json
/// {
///   "id": 1,
///   "title": "Fjallraven - Foldsack No. 1 Backpack",
///   "price": 109.95,
///   "description": "Your perfect pack for everyday use...",
///   "category": "men's clothing",
///   "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
///   "rating": { "rate": 3.9, "count": 120 }
/// }
/// ```
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  /// Builds a [Product] from decoded JSON.
  ///
  /// Every numeric field goes through `num` before being converted, so the
  /// API may send `109` or `109.95` without throwing
  /// `type 'int' is not a subtype of type 'double'`. Missing or `null`
  /// fields fall back to safe defaults instead of crashing the whole feed.
  factory Product.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    final ratingMap = rating is Map ? rating : const <String, dynamic>{};

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'uncategorized',
      imageUrl: json['image'] as String? ?? '',
      rating: (ratingMap['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Deep link that opens this product inside the app.
  String get deepLink => 'narxoz://store/product/$id';

  /// Images for the detail carousel.
  ///
  /// Fake Store API exposes a single image per product, so the gallery
  /// shows it three times with different framing (see `PhotoCarousel`).
  List<String> get galleryImages => List.filled(3, imageUrl);
}
