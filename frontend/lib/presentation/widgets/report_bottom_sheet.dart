import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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

  String get _typeLabel {
    switch (widget.type) {
      case ReportType.story:
        return '이야기 신고';
      case ReportType.chapter:
        return '챕터 신고';
      case ReportType.app:
        return '앱 문제 신고';
      case ReportType.question:
        return '질문 신고';
      case ReportType.other:
        return '기타 신고';
    }
  }

  String get _typeHint {
    switch (widget.type) {
      case ReportType.story:
        return '이야기의 어떤 문제가 있나요?';
      case ReportType.chapter:
        return '챕터의 어떤 문제가 있나요?';
      case ReportType.app:
        return '앱에서 어떤 문제가 발생했나요?';
      case ReportType.question:
        return '질문의 어떤 문제가 있나요?';
      case ReportType.other:
        return '어떤 문제가 있나요?';
    }
  }

  Future<void> _submitReport() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신고 내용을 입력해주세요', style: AppTheme.bodyMedium(context)),
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
          content: Text('로그인 후 신고해 주세요', style: AppTheme.bodyMedium(context)),
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
            success ? '신고가 접수되었습니다. 검토 후 조치하겠습니다.' : '신고 접수에 실패했습니다.',
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
                _typeLabel,
                style: AppTheme.headingMedium(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (widget.targetTitle != null) ...[
            Text(
              '대상: ${widget.targetTitle}',
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reason input
          Text(
            '신고 내용',
            style: AppTheme.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _typeHint,
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('신고하기'),
            ),
          ),
          const SizedBox(height: 8),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
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
