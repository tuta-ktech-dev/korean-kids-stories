import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'story_detail_view.dart';

@RoutePage()
class StoryDetailScreen extends StatelessWidget {
  final String storyId;

  const StoryDetailScreen({super.key, @PathParam('id') required this.storyId});

  @override
  Widget build(BuildContext context) {
    return StoryDetailView(storyId: storyId);
  }
}
