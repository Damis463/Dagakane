import 'package:flutter/material.dart';
import 'package:soninkara_media/pages/home.dart';
import 'package:soninkara_media/pages/screen_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soninkara_media/widgets/publicite.dart'; // 🧠 indispensable pour 'fr_FR'

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important pour attendre l'init locale

  await initializeDateFormatting(
    'fr_FR',
    null,
  ); // 🔑 Initialise les données pour les dates en français

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soninkara Média',
      theme: ThemeData(primarySwatch: Colors.brown),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => HomePage(),
        '/publicite': (context) => PubliciteWidget(),
      },
    );
  }
}
