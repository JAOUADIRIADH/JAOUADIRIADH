import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/yoyo_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final selectedLanguage = prefs.getString('language') ?? 'fr';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => YoyoProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            isDarkMode: isDarkMode,
            language: selectedLanguage,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      title: 'Yoyo Assistant',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''), // Français
        Locale('en', ''), // Anglais
        Locale('es', ''), // Espagnol
        Locale('de', ''), // Allemand
        Locale('it', ''), // Italien
        Locale('pt', ''), // Portugais
        Locale('ru', ''), // Russe
        Locale('zh', ''), // Chinois
        Locale('ja', ''), // Japonais
        Locale('ar', ''), // Arabe
      ],
      locale: Locale(settingsProvider.language),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
