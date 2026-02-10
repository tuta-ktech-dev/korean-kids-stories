import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/favorite_cubit/favorite_cubit.dart';
import '../../cubits/story_detail_cubit/story_detail_cubit.dart';
import 'story_detail_view.dart';

@RoutePage()
class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, @PathParam('id') required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _loadedFavorites = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedFavorites &&
        context.read<AuthCubit>().state is Authenticated) {
      _loadedFavorites = true;
      context.read<FavoriteCubit>().loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryDetailCubit(storyId: widget.storyId),
      child: StoryDetailView(storyId: widget.storyId),
    );
  }
}
