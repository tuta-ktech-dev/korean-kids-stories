import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/reader_cubit/reader_cubit.dart';
import '../../../injection.dart';
import 'reader_view.dart';

@RoutePage()
class ReaderScreen extends StatelessWidget {
  final String storyId;
  final String chapterId;

  const ReaderScreen({
    super.key,
    @PathParam('storyId') required this.storyId,
    @PathParam('chapterId') required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReaderCubit>()..loadChapter(chapterId),
      child: ReaderView(storyId: storyId),
    );
  }
}
