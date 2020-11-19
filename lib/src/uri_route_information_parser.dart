import 'package:flutter/widgets.dart';

/// parse the route information accordingly to the [Uri]
class UriRouteInformationParser extends RouteInformationParser<Uri> {
  /// transform [RouteInformation.location] to [Uri]
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async =>
      Uri.parse(routeInformation.location);

  /// transform [Uri] to [RouteInformation]
  @override
  RouteInformation restoreRouteInformation(Uri uri) =>
      RouteInformation(location: Uri.decodeComponent(uri.toString()));
}
