import 'package:flutter/material.dart';

/// Network image on a white card with a spinner while loading and a
/// placeholder icon when offline, so a missing thumbnail never shows
/// a red error box.
class NetworkImageBox extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: padding,
        child: url.isEmpty
            ? const _Placeholder()
            : Image.network(
                url,
                fit: fit,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const _Placeholder(),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}
