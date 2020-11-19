import 'package:flutter/widgets.dart';

class UriRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async => Uri.parse(routeInformation.location);

  @override
  RouteInformation restoreRouteInformation(Uri uri) => RouteInformation(location: Uri.decodeComponent(uri.toString()));
}
