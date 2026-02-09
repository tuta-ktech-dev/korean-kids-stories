import 'package:flutter_test/flutter_test.dart';
import 'package:korean_kids_stories/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(KoreanKidsStoriesApp());

    // Verify Korean welcome text appears
    expect(find.textContaining('안녕하세요'), findsOneWidget);
  });
}
