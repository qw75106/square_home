import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/launcher_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      navigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SquareHomeApp());
}

class SquareHomeApp extends StatelessWidget {
  const SquareHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LauncherProvider()..init(),
      child: MaterialApp(
        title: 'Square Home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'sans-serif',
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
