import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/splash_screen.dart';
import 'localization/app_localizations.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable online font downloads: rely 100% on locally bundled zero-latency font assets
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Firebase core services
  try {
    await FirebaseService.instance.initialize();
  } catch (e) {
    debugPrint('[FirebaseService] Startup initialization note: $e');
  }

  runApp(
    const ProviderScope(
      child: AmarKushtiaApp(),
    ),
  );

  // Run non-critical background maintenance after the first frame has painted
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseService.instance.seedDatabaseIfEmpty();
  });
}

class AmarKushtiaApp extends ConsumerWidget {
  const AmarKushtiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Amar Kushtia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: currentLocale,
      supportedLocales: const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

