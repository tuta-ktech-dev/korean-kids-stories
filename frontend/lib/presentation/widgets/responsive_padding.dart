import 'package:flutter/material.dart';

/// Wraps child with horizontal padding and max-width centering for iPad/large screens.
/// On tablets (width >= 600), constrains content to [maxWidth] and centers it.
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
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
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
