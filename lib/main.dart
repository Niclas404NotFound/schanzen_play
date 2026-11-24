import 'package:flutter/material.dart';

import './themes.dart';

import './screens/main_screen.dart';

import './server/web_server.dart';

void main() {
  runApp(const App());

  // startWebServer().then((server) {
  //  debugPrint(
  //      'Server running at http://${server.address.address}:${server.port}');
  // }).catchError((e) {
  //   debugPrint('Failed to start server: $e');
  // });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Flutter App',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: currentMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
