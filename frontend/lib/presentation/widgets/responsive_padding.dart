import 'package:flutter/material.dart';

/// Wraps child with horizontal padding and max-width centering for iPad/large screens.
/// On tablets (width >= 600), constrains content to [maxWidth] and centers it.
/// Tablet (>=840): uses 720, small tablet (600-840): uses [maxWidth].
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.horizontalPadding = 20,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;

    if (isWide) {
      // Tablet: use more space (720px) for better use of screen
      final effectiveMax = width >= 840 ? 720.0 : maxWidth;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMax),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}
