import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/bookmark_cubit/bookmark_cubit.dart';
import '../../cubits/favorite_cubit/favorite_cubit.dart';
import '../../cubits/review_cubit/review_cubit.dart';
import '../../cubits/story_detail_cubit/story_detail_cubit.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../injection.dart';
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
      context.read<BookmarkCubit>().loadBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StoryDetailCubit(
            storyId: widget.storyId,
            storyRepository: getIt<StoryRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => ReviewCubit(
            storyId: widget.storyId,
            reviewRepository: getIt<ReviewRepository>(),
          ),
        ),
      ],
      child: StoryDetailView(storyId: widget.storyId),
    );
  }
}
