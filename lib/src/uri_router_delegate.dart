import 'dart:collection';

import 'package:flouter/src/route_information.dart';
import 'package:flouter/src/typedef.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

/// a [RouterDelegate] based on [Uri]
class FlouterRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();

  late FlouterRouteManager _uriRouteManager;

  FlouterRouterDelegate({
    List<Uri>? initialUris,
    required Map<RegExp, PageBuilder> routes,
    PageBuilder? pageNotFound,
  }) {
    final _initialUris = initialUris ?? <Uri>[Uri(path: '/')];
    _uriRouteManager = FlouterRouteManager(
      routes: routes,
      pageNotFound: pageNotFound,
    );
    for (final uri in _initialUris) {
      _uriRouteManager.pushUri(uri);
    }
    _uriRouteManager._skipNext = true;
  }

  /// get the current route [Uri]
  /// this is show by the browser if your app run in the browser
  Uri? get currentConfiguration =>
      _uriRouteManager.uris.isNotEmpty ? _uriRouteManager.uris.last : null;

  /// add a new [Uri] and the corresponding [Page] on top of the navigator
  @override
  Future<void> setNewRoutePath(Uri uri) {
    return _uriRouteManager.pushUri(uri);
  }

  /// @nodoc
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _uriRouteManager,
      child: Consumer<FlouterRouteManager>(
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

/// allow you to interact with the List of [pages]
class FlouterRouteManager extends ChangeNotifier {
  static FlouterRouteManager of(BuildContext context) =>
      Provider.of<FlouterRouteManager>(context, listen: false);

  FlouterRouteManager({required this.routes, required this.pageNotFound});

  final Map<RegExp, PageBuilder> routes;
  final PageBuilder? pageNotFound;

  final _internalPages = <Page>[];
  final _internalUris = <Uri>[];

  bool _skipNext = false;
  bool _shouldUpdate = true;

  /// give you a read only access
  /// to the [List] of [Page] you have in your navigator
  List<Page> get pages => UnmodifiableListView(_internalPages);

  /// give you a read only access
  /// to the [List] of [Uri] you have in your navigator
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
        final route = routes[key]!;
        _internalPages.add(route(FlouterRouteInformation(uri, match)));
        _internalUris.add(uri);
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      var page = pageNotFound?.call(FlouterRouteInformation(uri, null));
      if (page == null) {
        page = MaterialPage(
          child: Scaffold(
            body: Container(
              child: Center(
                child: Text('Page not found'),
              ),
            ),
          ),
        );
      }
      _internalPages.add(page);
      _internalUris.add(uri);
    }
    if (_shouldUpdate) {
      notifyListeners();
    }
    return SynchronousFuture(null);
  }

  /// allow you to push multiple [Uri] at once
  @experimental
  Future<void> pushMultipleUri(List<Uri> uris) async {
    _shouldUpdate = false;
    for (final uri in uris) {
      await pushUri(uri);
    }
    _shouldUpdate = true;
  }

  /// allow you one [Uri]
  Future<void> pushUri(Uri uri) => _setNewRoutePath(uri);

  /// allow you clear the list of [pages] and then push an [Uri]
  Future<void> clearAndPushUri(Uri uri) {
    _internalPages.clear();
    _internalUris.clear();
    return pushUri(uri);
  }

  /// allow you clear the list of [pages] and then push multiple [Uri] at once
  Future<void> clearAndPushMultipleUri(List<Uri> uris) {
    _internalPages.clear();
    _internalUris.clear();
    return pushMultipleUri(uris);
  }

  /// allow you to remove a specific [Uri] and the corresponding [Page]
  void removeUri(Uri uri) {
    final index = _internalUris.indexOf(uri);
    _internalPages.removeAt(index);
    _internalUris.removeAt(index);
    notifyListeners();
  }

  /// allow you to remove the last [Uri] and the corresponding [Page]
  void removeLastUri() {
    _internalPages.removeLast();
    _internalUris.removeLast();
    notifyListeners();
  }
}
