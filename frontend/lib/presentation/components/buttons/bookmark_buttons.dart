import 'package:flutter/material.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/theme/app_theme.dart';

class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;
  final String? tooltip;

  const BookmarkButton({
    super.key,
    this.isBookmarked = false,
    this.onTap,
    this.tooltip,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  @override
  void didUpdateWidget(BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _isBookmarked = widget.isBookmarked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isBookmarked = !_isBookmarked);
        widget.onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isBookmarked
              ? AppTheme.primaryColor(context).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: _isBookmarked ? AppTheme.primaryColor(context) : AppTheme.textMutedColor(context),
          size: 24,
        ),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const FavoriteButton({
    super.key,
    this.isFavorite = false,
    this.onTap,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFavorite = !_isFavorite);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isFavorite ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFavorite
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : AppTheme.textMutedColor(context),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class NoteButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasNote;

  const NoteButton({
    super.key,
    this.onTap,
    this.hasNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasNote
              ? Colors.amber.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          hasNote ? Icons.edit_note : Icons.note_add_outlined,
          color: hasNote ? Colors.amber : AppTheme.textMutedColor(context),
          size: 24,
        ),
      ),
    );
  }
}

class NoteBottomSheet extends StatefulWidget {
  final String? initialNote;
  final Function(String)? onSave;

  const NoteBottomSheet({
    super.key,
    this.initialNote,
    this.onSave,
  });

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMutedColor(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.edit_note, color: AppTheme.primaryColor(context)),
              const SizedBox(width: 12),
              Text(
                context.l10n.addNote,
                style: AppTheme.headingMedium(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Note input
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: context.l10n.noteHint,
              hintStyle: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.l10n.cancel,
                    style: AppTheme.bodyLarge(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave?.call(_controller.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(context.l10n.saveNote),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Helper to show note sheet
void showNoteSheet(
  BuildContext context, {
  String? initialNote,
  Function(String)? onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NoteBottomSheet(
      initialNote: initialNote,
      onSave: onSave,
    ),
  );
}
