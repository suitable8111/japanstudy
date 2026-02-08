import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
import 'providers/sentence_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/history_provider.dart';
import 'providers/tts_settings_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ttsSettings = TtsSettingsProvider();
  await ttsSettings.loadSettings();

  runApp(JapanStudyApp(ttsSettings: ttsSettings));
}

class JapanStudyApp extends StatelessWidget {
  final TtsSettingsProvider ttsSettings;

  const JapanStudyApp({super.key, required this.ttsSettings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ttsSettings),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
        ChangeNotifierProxyProvider<TtsSettingsProvider, WordProvider>(
          create: (_) => WordProvider(),
          update: (_, ttsSettings, wordProvider) {
            wordProvider!.updateTtsSettings(ttsSettings);
            return wordProvider;
          },
        ),
        ChangeNotifierProxyProvider<TtsSettingsProvider, SentenceProvider>(
          create: (_) => SentenceProvider(),
          update: (_, ttsSettings, sentenceProvider) {
            sentenceProvider!.updateTtsSettings(ttsSettings);
            return sentenceProvider;
          },
        ),
        ChangeNotifierProxyProvider<TtsSettingsProvider, QuizProvider>(
          create: (_) => QuizProvider(),
          update: (_, ttsSettings, quizProvider) {
            quizProvider!.updateTtsSettings(ttsSettings);
            return quizProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: '日本語勉強',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667eea),
            brightness: Brightness.dark,
          ),
          fontFamily: 'NotoSans',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
