import 'package:flutter/widgets.dart';

/// parse the route information accordingly to the [Uri]
class FlouterRouteInformationParser extends RouteInformationParser<Uri> {
  /// transform [RouteInformation.location] to [Uri]
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.location;
    return Uri.parse(location ?? '');
  }

  /// transform [Uri] to [RouteInformation]
  @override
  RouteInformation restoreRouteInformation(Uri uri) =>
      RouteInformation(location: Uri.decodeComponent(uri.toString()));
}
