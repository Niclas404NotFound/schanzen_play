import 'package:flutter/foundation.dart';

import 'web_server.dart';

class ServerController extends ChangeNotifier {
  ServerController._();
  static final ServerController instance = ServerController._();

  LocalWebServer? _server;
  bool _isLoading = false;
  int _port = 8080;

  bool get isRunning => _server?.isRunning ?? false;
  bool get isLoading => _isLoading;
  int get port => _port;

  Future<void> start(int port) async {
    if (_isLoading || isRunning) return;
    _isLoading = true;
    notifyListeners();

    try {
      final server = LocalWebServer(port: port);
      await server.start(); // throws if the port is in use
      _server = server;
      _port = port;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stop({bool force = false}) async {
    if (_isLoading || !isRunning) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _server?.stop(force: force);
      _server = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
