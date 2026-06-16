import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_navigation_provider.dart';
import 'providers/publication_provider.dart';
import 'screens/splash_screen.dart';
import 'services/openalex_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final openAlexConfig = OpenAlexConfig();
  await openAlexConfig.load();

  runApp(MyApp(openAlexConfig: openAlexConfig));
}

class MyApp extends StatelessWidget {
  final OpenAlexConfig openAlexConfig;

  const MyApp({super.key, required this.openAlexConfig});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OpenAlexConfig>.value(value: openAlexConfig),
        ChangeNotifierProvider(
          create: (context) => PublicationProvider(
            config: context.read<OpenAlexConfig>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JournalAI',
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
