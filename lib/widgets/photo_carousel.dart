import 'package:flutter/material.dart';

import 'network_image_box.dart';

/// Swipeable gallery built on [PageView.builder] with a "1 / 3" counter
/// and animated dot indicators.
///
/// Only the first page is wrapped in a [Hero] with [heroTag], so the
/// thumbnail from the feed flies into page one.
class PhotoCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String heroTag;
  final double height;

  const PhotoCarousel({
    super.key,
    required this.imageUrls,
    required this.heroTag,
    this.height = 320,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Fake Store API returns one image per product, so each page gets a
  // different background and zoom to read as a distinct shot.
  static const List<Color> _backgrounds = [
    Colors.white,
    Color(0xFFF3F4F8),
    Color(0xFFFFF8EC),
  ];
  static const List<EdgeInsets> _paddings = [
    EdgeInsets.all(24),
    EdgeInsets.all(48),
    EdgeInsets.all(8),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imageUrls.length;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final image = ColoredBox(
                color: _backgrounds[index % _backgrounds.length],
                child: NetworkImageBox(
                  url: widget.imageUrls[index],
                  padding: _paddings[index % _paddings.length],
                ),
              );
              return index == 0
                  ? Hero(tag: widget.heroTag, child: image)
                  : image;
            },
          ),
          // Page counter: "1 / 3"
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1} / $count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Animated dots: the active dot stretches into a pill.
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
