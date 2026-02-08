import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
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
        ChangeNotifierProxyProvider<TtsSettingsProvider, WordProvider>(
          create: (_) => WordProvider(),
          update: (_, ttsSettings, wordProvider) {
            wordProvider!.updateTtsSettings(ttsSettings);
            return wordProvider;
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
