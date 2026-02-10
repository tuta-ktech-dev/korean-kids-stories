import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/story_detail_cubit/story_detail_cubit.dart';
import 'story_detail_view.dart';

@RoutePage()
class StoryDetailScreen extends StatelessWidget {
  final String storyId;

  const StoryDetailScreen({super.key, @PathParam('id') required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryDetailCubit(storyId: storyId),
      child: StoryDetailView(storyId: storyId),
    );
  }
}
