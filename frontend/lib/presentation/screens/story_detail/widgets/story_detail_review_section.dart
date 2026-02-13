import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/review.dart';
import '../../../cubits/review_cubit/review_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'story_detail_theme.dart';

class StoryDetailReviewSection extends StatefulWidget {
  final String storyId;
  final String? category;
  final VoidCallback? onReviewChanged;

  const StoryDetailReviewSection({
    super.key,
    required this.storyId,
    this.category,
    this.onReviewChanged,
  });

  @override
  State<StoryDetailReviewSection> createState() =>
      _StoryDetailReviewSectionState();
}

class _StoryDetailReviewSectionState extends State<StoryDetailReviewSection> {
  @override
  Widget build(BuildContext context) {
    final theme = StoryDetailTheme.of(context, widget.category);

    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is ReviewInitial || state is ReviewLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is ReviewError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              state.message,
              style: AppTheme.caption(context).copyWith(color: Colors.red),
            ),
          );
        }

        final loaded = state as ReviewLoaded;
        final reviews = loaded.allReviews;

        // Guest-only: show read-only reviews, prompt for Parent Zone to add
        final authContent = _LoginPrompt(accentColor: theme.color);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              context.l10n.reviewsTitle,
              style: AppTheme.headingMedium(context),
            ),
            const SizedBox(height: 16),
            authContent,
            const SizedBox(height: 24),
            if (reviews.isEmpty)
              _EmptyState(accentColor: theme.color)
            else
              ...reviews.map(
                (r) => _ReviewCard(
                  key: ValueKey(r.id),
                  review: r,
                  accentColor: theme.color,
                ),
              ),
          ],
        );
      },
    );
  }

  // Kept for when Parent Zone enables reviews
  // ignore: unused_element
  Future<void> _handleDelete(BuildContext context) async {
    final cubit = context.read<ReviewCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteReview),
        content: Text(context.l10n.deleteReviewConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.deleteReview,
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await cubit.deleteReview();
    if (mounted) widget.onReviewChanged?.call();
  }
}

// Kept for when Parent Zone enables reviews
// ignore: unused_element
class _MyReviewSummary extends StatelessWidget {
  final Review review;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyReviewSummary({
    required this.review,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.yourReview,
                  style: AppTheme.caption(
                    context,
                  ).copyWith(color: AppTheme.textMutedColor(context)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 20,
                      color: i < review.rating
                          ? accentColor
                          : AppTheme.textMutedColor(context),
                    ),
                  ),
                ),
                if (review.comment != null &&
                    review.comment!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.comment!,
                    style: AppTheme.bodyMedium(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(context.l10n.editReview),
              ),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(context.l10n.deleteReview),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final Color accentColor;

  const _LoginPrompt({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined, color: accentColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.loginToReview,
              style: AppTheme.bodyMedium(
                context,
              ).copyWith(color: AppTheme.textMutedColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accentColor;

  const _EmptyState({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.star_outline_rounded,
                size: 40,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noReviewsYet,
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.beFirstToReview,
              style: AppTheme.caption(
                context,
              ).copyWith(color: AppTheme.textMutedColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String storyId;
  final int initialRating;
  final String initialComment;
  final bool isEditing;
  final Color accentColor;
  final VoidCallback onSubmitted;
  final VoidCallback? onCancel;

  const _ReviewForm({
    required this.storyId,
    required this.initialRating,
    required this.initialComment,
    required this.isEditing,
    required this.accentColor,
    required this.onSubmitted,
    required this.onCancel,
  });

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void didUpdateWidget(_ReviewForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating ||
        oldWidget.initialComment != widget.initialComment) {
      _rating = widget.initialRating;
      _commentController.text = widget.initialComment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) return;
    final cubit = context.read<ReviewCubit>();
    setState(() => _isSubmitting = true);
    final ok = await cubit.submitReview(
      _rating,
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) widget.onSubmitted();
  }

  Future<void> _delete() async {
    final cubit = context.read<ReviewCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteReview),
        content: Text(context.l10n.deleteReviewConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.deleteReview),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    await cubit.deleteReview();
    setState(() => _isSubmitting = false);
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing
                ? context.l10n.editReview
                : context.l10n.writeReview,
            style: AppTheme.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.yourRating, style: AppTheme.caption(context)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    _rating >= star
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: _rating >= star
                        ? widget.accentColor
                        : AppTheme.textMutedColor(context),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.optionalComment, style: AppTheme.caption(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(hintText: context.l10n.optionalComment),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.onCancel != null) ...[
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onCancel,
                  child: Text(context.l10n.cancel),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Text(context.l10n.submitReview),
                ),
              ),
              if (widget.isEditing && widget.onCancel != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _isSubmitting ? null : _delete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                  ),
                  child: Text(context.l10n.deleteReview),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final Color accentColor;

  const _ReviewCard({
    super.key,
    required this.review,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (review.userName?.isNotEmpty == true
                            ? review.userName!.substring(0, 1).toUpperCase()
                            : '?')
                        .substring(0, 1),
                    style: AppTheme.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700, color: accentColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? context.l10n.defaultUser,
                      style: AppTheme.bodyLarge(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: i < review.rating
                              ? accentColor
                              : AppTheme.textMutedColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.created),
                style: AppTheme.caption(
                  context,
                ).copyWith(color: AppTheme.textMutedColor(context)),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment!, style: AppTheme.bodyMedium(context)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
