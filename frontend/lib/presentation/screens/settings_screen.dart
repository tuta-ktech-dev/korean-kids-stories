import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../components/buttons/settings_item.dart';
import '../components/cards/settings_section.dart';
import '../widgets/report_bottom_sheet.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text('설정', style: AppTheme.headingMedium(context)),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Section
          SettingsSection(
            title: '계정',
            children: [
              SettingsItem(
                icon: Icons.person_outline,
                title: '프로필 수정',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.lock_outline,
                title: '비밀번호 변경',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Report Section
          SettingsSection(
            title: '신고 및 문의',
            children: [
              SettingsItem(
                icon: Icons.report_problem_outlined,
                title: '앱 문제 신고',
                iconColor: Colors.orange,
                onTap: () => showReportSheet(
                  context,
                  type: ReportType.app,
                  targetId: 'app',
                  targetTitle: 'Korean Kids Stories App',
                ),
              ),
              SettingsItem(
                icon: Icons.help_outline,
                title: '문의하기',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App Section
          SettingsSection(
            title: '앱 정보',
            children: [
              SettingsItem(
                icon: Icons.info_outline,
                title: '버전',
                trailing: Text('1.0.0', style: AppTheme.bodyMedium(context)),
              ),
              SettingsItem(
                icon: Icons.star_outline,
                title: '앱 평가하기',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.share_outlined,
                title: '친구에게 공유',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Danger Zone
          SettingsSection(
            title: '위험 구역',
            children: [
              SettingsItem(
                icon: Icons.logout,
                title: '로그아웃',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
              SettingsItem(
                icon: Icons.delete_forever,
                title: '계정 삭제',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: '로그아웃',
      content: '정말 로그아웃하시겠습니까?',
      confirmText: '로그아웃',
      onConfirm: () {
        // TODO: Call logout API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃되었습니다', style: AppTheme.bodyMedium(context))),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('계정 삭제', style: AppTheme.headingMedium(context)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말 계정을 삭제하시겠습니까?',
              style: AppTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              '• 모든 읽기 기록이 삭제됩니다\n• 저장된 북마크가 삭제됩니다\n• 이 작업은 되돌릴 수 없습니다',
              style: AppTheme.bodyMedium(context).copyWith(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: AppTheme.bodyLarge(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('계속'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('최종 확인', style: AppTheme.headingMedium(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '계정 삭제를 확인하려면 "삭제"를 입력하세요',
              style: AppTheme.bodyMedium(context),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '삭제',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: AppTheme.bodyLarge(context)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == '삭제') {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('계정이 삭제되었습니다', style: AppTheme.bodyMedium(context)),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"삭제"를 정확히 입력해주세요', style: AppTheme.bodyMedium(context)),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('계정 삭제'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTheme.headingMedium(context)),
        content: Text(content, style: AppTheme.bodyLarge(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: AppTheme.bodyLarge(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
