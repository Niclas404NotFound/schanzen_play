import 'dart:io';

abstract class RouteHandler {
  Future<void> init() async {}

  Future<void> handle(HttpRequest request);
}
