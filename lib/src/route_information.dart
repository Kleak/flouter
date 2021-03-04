/// Let you access the current [uri] and the [match] to get information from it
class FlouterRouteInformation {
  final Uri uri;
  final RegExpMatch? match;

  FlouterRouteInformation(this.uri, this.match);
}
