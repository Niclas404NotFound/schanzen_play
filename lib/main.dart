import 'package:flutter/material.dart';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
