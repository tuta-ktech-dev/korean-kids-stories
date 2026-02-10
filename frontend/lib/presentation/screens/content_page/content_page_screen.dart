import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'content_page_view.dart';

@RoutePage()
class ContentPageScreen extends StatelessWidget {
  const ContentPageScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return ContentPageView(slug: slug);
  }
}
