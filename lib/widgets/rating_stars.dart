import 'package:flutter/material.dart';

/// Five stars (full / half / empty) followed by "3.9 (120)".
class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(5, (i) {
      final IconData icon;
      if (rating >= i + 1) {
        icon = Icons.star_rounded;
      } else if (rating >= i + 0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_outline_rounded;
      }
      return Icon(icon, size: size, color: Colors.amber);
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)} ($reviewCount)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
