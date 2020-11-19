import 'dart:collection';

import 'package:flouter/src/route_information.dart';
import 'package:flouter/src/typedef.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class UriRouterDelegate extends RouterDelegate<Uri> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final List<Uri> initialUris;

  UriRouteManager _uriRouteManager;

  UriRouterDelegate({this.initialUris, @required Map<RegExp, PageBuilder> pages, PageBuilder pageNotFound}) {
    _uriRouteManager = UriRouteManager(
      routes: pages,
      pageNotFound: pageNotFound,
    );
    _uriRouteManager.addListener(notifyListeners);

    for (final uri in initialUris ?? [Uri(path: '/')]) {
      _uriRouteManager.pushUri(uri);
    }
    _uriRouteManager._skipNext = true;
  }

  Uri get currentConfiguration => _uriRouteManager.uris.isNotEmpty ? _uriRouteManager.uris.last : null;

  @override
  Future<void> setNewRoutePath(Uri uri) {
    return _uriRouteManager.pushUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _uriRouteManager,
      child: Consumer<UriRouteManager>(
        builder: (context, uriRouteManager, _) => Navigator(
          key: navigatorKey,
          pages: [
            for (final page in uriRouteManager.pages) page,
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }

            if (uriRouteManager.routes.isNotEmpty) {
              uriRouteManager.removeLastUri();
              return true;
            }

            return false;
          },
        ),
      ),
    );
  }
}

class UriRouteManager extends ChangeNotifier {
  static UriRouteManager of(BuildContext context) => Provider.of<UriRouteManager>(context, listen: false);

  UriRouteManager({@required this.routes, @required this.pageNotFound});

  final Map<RegExp, PageBuilder> routes;
  final PageBuilder pageNotFound;

  final _internalPages = <Page>[];
  final _internalUris = <Uri>[];

  bool _skipNext = false;
  bool _shouldUpdate = true;

  List<Page> get pages => UnmodifiableListView(_internalPages);

  List<Uri> get uris => UnmodifiableListView(_internalUris);

  Future<void> _setNewRoutePath(Uri uri) {
    if (_skipNext) {
      _skipNext = false;
      return SynchronousFuture(null);
    }

    bool _findRoute = false;
    for (var i = 0; i < routes.keys.length; i++) {
      final key = routes.keys.elementAt(i);
      if (key.hasMatch(uri.path)) {
        if (_internalUris.contains(uri)) {
          final position = _internalUris.indexOf(uri);
          final _urisLengh = _internalUris.length;
          for (var start = position; start < _urisLengh - 1; start++) {
            _internalPages.removeLast();
            _internalUris.removeLast();
          }
          _findRoute = true;
          break;
        }
        final match = key.firstMatch(uri.path);
        _internalPages.add(routes[key](FlouterRouteInformation(uri, match)));
        _internalUris.add(uri);
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      _internalPages.add(
        pageNotFound?.call(FlouterRouteInformation(uri, null)) ??
            MaterialPage(child: Scaffold(body: Container(child: Center(child: Text('Page not found'))))),
      );
      _internalUris.add(uri);
    }
    if (_shouldUpdate) {
      notifyListeners();
    }
    return SynchronousFuture(null);
  }

  @experimental
  Future<void> pushMultipleUri(List<Uri> uris) async {
    _shouldUpdate = false;
    for (final uri in uris) {
      await pushUri(uri);
    }
    _shouldUpdate = true;
  }

  Future<void> pushUri(Uri uri) => _setNewRoutePath(uri);

  Future<void> clearAndPushUri(Uri uri) {
    _internalPages.clear();
    _internalUris.clear();
    return pushUri(uri);
  }

  Future<void> clearAndPushMultipleUri(List<Uri> uris) {
    _internalPages.clear();
    _internalUris.clear();
    return pushMultipleUri(uris);
  }

  void removeUri(Uri uri) {
    final index = _internalUris.indexOf(uri);
    _internalPages.removeAt(index);
    _internalUris.removeAt(index);
    notifyListeners();
  }

  void removeLastUri() {
    _internalPages.removeLast();
    _internalUris.removeLast();
    notifyListeners();
  }
}
