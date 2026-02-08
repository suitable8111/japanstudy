import 'package:flutter_test/flutter_test.dart';
import 'package:japanstudy/main.dart';
import 'package:japanstudy/providers/tts_settings_provider.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(JapanStudyApp(ttsSettings: TtsSettingsProvider()));
    expect(find.text('日本語勉強'), findsOneWidget);
    expect(find.text('1단계: 단어 외우기'), findsOneWidget);
  });
}
