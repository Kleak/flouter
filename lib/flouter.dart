import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef PushNewRoute = Future<void> Function(Uri);

class FlouterInformations {
  final Uri uri;
  final RegExpMatch match;
  final PushNewRoute push;

  const FlouterInformations({@required this.uri, this.match, @required this.push});
}

typedef PageBuilder = Page Function(FlouterInformations);

class UriRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async => Uri.parse(routeInformation.location);

  @override
  RouteInformation restoreRouteInformation(Uri uri) => RouteInformation(location: Uri.decodeComponent(uri.toString()));
}

class UriRouterDelegate extends RouterDelegate<Uri> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final _pages = <Page>[];
  final _uris = <Uri>[];
  final List<Uri> initialUris;
  final Map<RegExp, PageBuilder> pages;
  final PageBuilder pageNotFound;

  bool _skipNext = false;

  UriRouterDelegate({this.initialUris, @required this.pages, this.pageNotFound}) {
    for (final uri in initialUris ?? [Uri(path: '/')]) {
      setNewRoutePath(uri);
    }
    _skipNext = true;
  }

  Uri get currentConfiguration => _uris.isNotEmpty ? _uris.last : null;

  @visibleForTesting
  List<Page> get internalPages => UnmodifiableListView(_pages);

  @visibleForTesting
  List<Uri> get internalUris => UnmodifiableListView(_uris);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
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
    if (_skipNext) {
      _skipNext = false;
      return;
    }

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
        final informations = FlouterInformations(uri: uri, match: key.firstMatch(uri.path), push: setNewRoutePath);
        _pages.add(pages[key](informations));
        _uris.add(uri);
        notifyListeners();
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      final informations = FlouterInformations(uri: uri, match: null, push: setNewRoutePath);
      _pages.add(
        pageNotFound?.call(informations) ??
            MaterialPage(child: Scaffold(body: Container(child: Center(child: Text('Page not found'))))),
      );
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
