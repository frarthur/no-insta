import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/inbox_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent DM experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent system bars to blend with Instagram's dark UI.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const InstaliteApp());
}

class InstaliteApp extends StatelessWidget {
  const InstaliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instalite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const InboxScreen(),
    );
  }
}
