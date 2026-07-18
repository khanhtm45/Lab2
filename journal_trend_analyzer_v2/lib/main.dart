import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase/firebase_config.dart';
import 'firebase/messaging_service.dart';
import 'firebase/crashlytics_service.dart';
import 'firebase/remote_config_service.dart';
import 'l10n/app_strings.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/publication_provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'screens/splash_screen.dart';
import 'services/app_preferences.dart';
import 'services/openalex_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await FirebaseConfig.initialize();
    await CrashlyticsService.initialize();
    await MessagingService.initialize();
    await RemoteConfigService.initialize();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase for development
  }

  final openAlexConfig = OpenAlexConfig();
  await openAlexConfig.load();

  final appPreferences = AppPreferences();
  await appPreferences.load();

  runApp(
    MyApp(
      openAlexConfig: openAlexConfig,
      appPreferences: appPreferences,
    ),
  );
}

class MyApp extends StatelessWidget {
  final OpenAlexConfig openAlexConfig;
  final AppPreferences appPreferences;

  const MyApp({
    super.key,
    required this.openAlexConfig,
    required this.appPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OpenAlexConfig>.value(value: openAlexConfig),
        ChangeNotifierProvider<AppPreferences>.value(value: appPreferences),
        ChangeNotifierProvider(
          create: (context) => PublicationProvider(
            config: context.read<OpenAlexConfig>(),
            preferences: context.read<AppPreferences>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: Consumer<AppPreferences>(
        builder: (context, prefs, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings(prefs.language).appTitle,
            themeMode: prefs.themeMode,
            theme: buildAppTheme(),
            darkTheme: buildAppTheme(brightness: Brightness.dark),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
