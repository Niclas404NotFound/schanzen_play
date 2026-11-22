import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../route_handler.dart';

class HomeRoute extends RouteHandler {
  late final String _html;

  @override
  Future<void> init() async {
    _html = await rootBundle.loadString('assets/html/index.html');
  }

  @override
  Future<void> handle(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(_html);
  }
}
