import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';

/// Opens a modal bottom sheet with the product's deep link
/// (`narxoz://store/product/{id}`) and a copy-to-clipboard button.
Future<void> showShareLinkSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ShareLinkSheet(product: product),
  );
}

class ShareLinkSheet extends StatelessWidget {
  final Product product;

  const ShareLinkSheet({super.key, required this.product});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: product.deepLink));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Deep link copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share product', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      product.deepLink,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy link',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () => _copy(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_all_rounded),
                label: const Text('Copy Deep Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
