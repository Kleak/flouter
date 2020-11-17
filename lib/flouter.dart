import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef PushNewRoute = Future<void> Function(Uri);
typedef PageBuilder = Page Function(Uri, PushNewRoute);

class UriRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async => Uri.parse(routeInformation.location);

  @override
  RouteInformation restoreRouteInformation(Uri uri) => RouteInformation(location: uri.path);
}

class UriRouterDelegate extends RouterDelegate<Uri> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final _pages = <Page>[];
  final _uris = <Uri>[];
  final Page initialPage;
  final Map<RegExp, PageBuilder> pages;
  final PageBuilder pageNotFound;

  Page currentPage;

  UriRouterDelegate({this.initialPage, @required this.pages, @required this.pageNotFound});

  Uri get currentConfiguration => _uris.isNotEmpty ? _uris.last : null;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_pages.isEmpty) initialPage,
        for (final page in _pages) page,
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_pages.isNotEmpty) {
          removeLastRoute();
          return true;
        }

        return false;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Uri uri) async {
    bool _findRoute = false;
    for (var i = 0; i < pages.keys.length; i++) {
      final key = pages.keys.elementAt(i);
      if (key.hasMatch(uri.path)) {
        if (_uris.contains(uri)) {
          final position = _uris.indexOf(uri);
          final _urisLengh = _uris.length;
          for (var start = position; start < _urisLengh - 1; start++) {
            _pages.removeLast();
            _uris.removeLast();
          }
          _findRoute = true;
          notifyListeners();
          break;
        }
        _pages.add(pages[key](uri, setNewRoutePath));
        _uris.add(uri);
        notifyListeners();
        _findRoute = true;
      }
    }
    if (!_findRoute) {
      _pages.add(pageNotFound(uri, setNewRoutePath));
      _uris.add(uri);
      notifyListeners();
    }
  }

  Future<void> removeRouteAtIndex(int index) async {
    _pages.removeAt(index);
    _uris.removeAt(index);
    notifyListeners();
  }

  Future<void> removeLastRoute() async {
    _pages.removeLast();
    _uris.removeLast();
    notifyListeners();
  }
}
