import 'dart:io';
import 'route_handler.dart';
import 'routes/home_route.dart';

class LocalWebServer {
  final int port;
  final InternetAddress address;

  HttpServer? _server;
  bool _isInitialized = false;

  late final Map<String, RouteHandler> _routes;

  LocalWebServer({
    this.port = 8080,
    InternetAddress? address,
  }) : address = address ?? InternetAddress.anyIPv4 {
    _routes = {
      'GET /': HomeRoute(),
    };
  }

  bool get isRunning => _server != null;

  Future<void> start() async {
    if (_server != null) return;

    if (!_isInitialized) {
      for (final handler in _routes.values) {
        await handler.init();
      }
      _isInitialized = true;
    }

    _server = await HttpServer.bind(address, port);
    _server!.listen(_handleRequest);
  }

  Future<void> stop({bool force = false}) async {
    await _server?.close(force: force);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final routeKey = '${request.method} ${request.uri.path}';
    final handler = _routes[routeKey];

    try {
      if (handler != null) {
        await handler.handle(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.text
          ..write('404 Not Found');
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.text
        ..write('500 Internal Server Error');
    } finally {
      await request.response.close();
    }
  }
}
