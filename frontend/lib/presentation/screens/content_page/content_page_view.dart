import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/responsive_padding.dart';
import '../../../injection.dart';
import '../../../data/repositories/content_page_repository.dart';

class ContentPageView extends StatefulWidget {
  const ContentPageView({super.key, required this.slug});

  final String slug;

  @override
  State<ContentPageView> createState() => _ContentPageViewState();
}

class _ContentPageViewState extends State<ContentPageView> {
  ContentPage? _page;
  bool _loading = true;
  String? _error;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final repo = getIt<ContentPageRepository>();
    final locale = Localizations.localeOf(context).languageCode;
    final page = await repo.getPage(widget.slug, locale: locale);
    if (mounted) {
      setState(() {
        _page = page;
        _loading = false;
        _error = page == null ? 'Page not found' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          _page?.title ?? _slugToTitle(widget.slug),
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      style: AppTheme.bodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ResponsivePadding(
                  maxWidth: 720,
                  horizontalPadding: 24,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Html(
                    data: _page?.content ?? '',
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                      ),
                      'h2': Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(bottom: 8),
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 12),
                      ),
                      'ul': Style(
                        margin: Margins.only(bottom: 12),
                        padding: HtmlPaddings.only(left: 20),
                      ),
                      'li': Style(
                        margin: Margins.only(bottom: 4),
                      ),
                    },
                  ),
                ),
                ),
    );
  }

  String _slugToTitle(String slug) {
    switch (slug) {
      case 'privacy':
        return context.l10n.privacyPolicy;
      case 'terms':
        return context.l10n.termsOfService;
      default:
        return slug;
    }
  }
}
