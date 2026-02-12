import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/services/pocketbase_service.dart';
import '../../injection.dart';

enum ReportType { story, chapter, app, question, other }

class ReportBottomSheet extends StatefulWidget {
  final ReportType type;
  final String targetId;
  final String? targetTitle;

  const ReportBottomSheet({
    super.key,
    required this.type,
    required this.targetId,
    this.targetTitle,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  String _typeLabel(BuildContext context) {
    switch (widget.type) {
      case ReportType.story:
        return context.l10n.reportStory;
      case ReportType.chapter:
        return context.l10n.reportChapter;
      case ReportType.app:
        return context.l10n.reportApp;
      case ReportType.question:
        return context.l10n.reportQuestion;
      case ReportType.other:
        return context.l10n.reportOther;
    }
  }

  String _typeHint(BuildContext context) {
    switch (widget.type) {
      case ReportType.story:
        return context.l10n.reportStoryHint;
      case ReportType.chapter:
        return context.l10n.reportChapterHint;
      case ReportType.app:
        return context.l10n.reportAppHint;
      case ReportType.question:
        return context.l10n.reportQuestionHint;
      case ReportType.other:
        return context.l10n.reportGeneralHint;
    }
  }

  Future<void> _submitReport() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reportContentRequired, style: AppTheme.bodyMedium(context)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final repo = getIt<ReportRepository>();
    // Require login to report
    if (!getIt<PocketbaseService>().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reportLoginRequired, style: AppTheme.bodyMedium(context)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await repo.submitReport(
      type: _reportTypeString,
      reason: _reasonController.text.trim(),
      targetId: widget.targetId,
      targetTitle: widget.targetTitle,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? context.l10n.reportSuccess : context.l10n.reportFailed,
            style: AppTheme.bodyMedium(context),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String get _reportTypeString {
    switch (widget.type) {
      case ReportType.story:
        return 'story';
      case ReportType.chapter:
        return 'chapter';
      case ReportType.app:
        return 'app';
      case ReportType.question:
        return 'question';
      case ReportType.other:
        return 'other';
    }
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
              Icon(
                Icons.report_problem_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _typeLabel(context),
                style: AppTheme.headingMedium(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (widget.targetTitle != null) ...[
            Text(
              context.l10n.reportTarget(widget.targetTitle!),
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reason input
          Text(
            context.l10n.reportContent,
            style: AppTheme.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _typeHint(context),
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

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(context.l10n.reportSubmit),
            ),
          ),
          const SizedBox(height: 8),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.cancel,
                style: AppTheme.bodyLarge(context).copyWith(
                  color: AppTheme.textMutedColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

// Helper to show report sheet
void showReportSheet(
  BuildContext context, {
  required ReportType type,
  required String targetId,
  String? targetTitle,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReportBottomSheet(
      type: type,
      targetId: targetId,
      targetTitle: targetTitle,
    ),
  );
}
