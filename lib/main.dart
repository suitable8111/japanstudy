import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/word_provider.dart';
import 'providers/sentence_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/kana_provider.dart';
import 'providers/radio_provider.dart';
import 'providers/history_provider.dart';
import 'providers/ranking_provider.dart';
import 'providers/tts_settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/level_test_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final ttsSettings = TtsSettingsProvider();
  await ttsSettings.loadSettings();

  final themeProvider = ThemeProvider();
  await themeProvider.loadSettings();

  runApp(JapanStudyApp(ttsSettings: ttsSettings, themeProvider: themeProvider));
}

class JapanStudyApp extends StatelessWidget {
  final TtsSettingsProvider ttsSettings;
  final ThemeProvider themeProvider;

  const JapanStudyApp({super.key, required this.ttsSettings, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ttsSettings),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
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
        ChangeNotifierProxyProvider<TtsSettingsProvider, KanaProvider>(
          create: (_) => KanaProvider(),
          update: (_, ttsSettings, kanaProvider) {
            kanaProvider!.updateTtsSettings(ttsSettings);
            return kanaProvider;
          },
        ),
        ChangeNotifierProxyProvider<TtsSettingsProvider, QuizProvider>(
          create: (_) => QuizProvider(),
          update: (_, ttsSettings, quizProvider) {
            quizProvider!.updateTtsSettings(ttsSettings);
            return quizProvider;
          },
        ),
        ChangeNotifierProxyProvider<TtsSettingsProvider, RadioProvider>(
          create: (_) => RadioProvider(),
          update: (_, ttsSettings, radioProvider) {
            radioProvider!.updateTtsSettings(ttsSettings);
            return radioProvider;
          },
        ),
        ChangeNotifierProxyProvider<TtsSettingsProvider, LevelTestProvider>(
          create: (_) => LevelTestProvider(),
          update: (_, ttsSettings, levelTestProvider) {
            levelTestProvider!.updateTtsSettings(ttsSettings);
            return levelTestProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'JLPT 일기장',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.primaryColor,
              brightness: Brightness.dark,
            ),
            fontFamily: 'NotoSans',
          ),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    final historyProvider = context.read<HistoryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      historyProvider.setUid(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.user != null) {
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}
